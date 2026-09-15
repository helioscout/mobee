module mobee;

import std::io;
import std::core::mem::allocators;

<* World type, main container of the sapce. The world is built of blocks. *>
struct World {
	<* Query match approach. *>
	Approach approach;
	<* Registered component types. *>
	Components components;
	<* Registered tag types. *>
	Tags tags;
	<* Registered resource types. *>
	Resources resources;
	<* Registered relation types. *>
	Relations relations;
	<* All mounted systems. *>
	Systems systems;
	<* Systems split by phase for running in the pipeline. *>
	Schedule schedule;
	<* Archetypes collection of the world. *>
	Archetypes archetypes;
	<* Blocks for entities with dynamic lifetime. *>
	Blocks dynamics;
	<* Blocks for entities with static lifetime. *>
	Blocks statics;
	<* Indicates that the world is running. *>
	bool running;
	<* Indicates that START phase has already executed. *>
	bool started;
	<* Indicates that the world is in performing stage (runs deferred actions). *>
	bool performing;
	<* Deferred actions for the world. *>
	Deferred deferred;
	<* Components + Relations chunk size in bytes. *>
	sz chunk_size;
	<* Arena allocator for dynamic arrays of relations targets. *>
	DynamicArenaAllocator arena;
}

<* Gets world blocks count for specific (default: all) lifetimes.
   @param lifetime : "Blocks lifetime flag." *>
fn sz World.size(&self, char lifetime = 0b00000011) {
	sz size;

	if (lifetime & Lifetime.DYNAMIC) size += self.dynamics.len();
	if (lifetime & Lifetime.STATIC)  size += self.statics.len();
	
	return size;
}

<* Gets world blocks count for specific lifetimes (comma-separated arguments). *>
macro sz World.size_of(&self, ...) {
	char $lifetime;
	
	$for var $i = 0; $i < $vaarg.len; $i++:
		$if @typeid($vaarg[$i]) == Lifetime::typeid:
			$lifetime |= $vaarg[$i];
		$endif
	$endfor

	return self.size($lifetime);
}

<* Initializes the world.
   @param world : "Pointer to the world." *>
fn void world_init(World* world) @private {
	world.systems.init(mem);
	world.dynamics.init(mem);
	world.statics.init(mem);

	world.schedule.start.init(mem);
	world.schedule.pre_update.init(mem);
	world.schedule.update.init(mem);
	world.schedule.post_update.init(mem);
	
	if (world.approach == ARCHETYPE) {
		world.archetypes.init(mem);
		world.deferred.despawning.init(mem);
		world.deferred.archetyping.init(mem);
	}

	/* Register builtin relations. */
	world.register(RELATION, ChildOf);
	world.register(RELATION, ParentOf);
	world.register(RELATION, RelationOf);

	world.arena.init(mem, ARENA_PAGE_SIZE);
}

<* Registers element type for the world.
   @param element : "World element kind."
   @param $Type   : "Element (component/tag/resource/relation) type."
   @return          "Pointer to the world for chain calls." *>
macro World* World.register(&self, Element element, $Type) {
	if (self.running) return self;
	
	switch (element) {
		case COMPONENT:
			if (tags_has(&self.tags, $Type::typeid) || relations_has(&self.relations, $Type::typeid)) {
				abort(ERR_TYPE_ALREADY_REGISTERED);
			}
				
			components_add(&self.components, $Type::typeid,
				{ .type = $Type::typeid, .size = $Type::size, .alignment = $Type::alignment,
				  .idx = self.components.count });
				
		case TAG:
			if (components_has(&self.components, $Type::typeid) || relations_has(&self.relations, $Type::typeid)) {
				abort(ERR_TYPE_ALREADY_REGISTERED);
			}
				
			tags_add(&self.tags, $Type::typeid, { .type = $Type::typeid, .idx = self.tags.count });
			
		case RESOURCE:
			resources_add(&self.resources, $Type::typeid,
				{ .type = $Type::typeid, .size = $Type::size, .alignment = $Type::alignment,
				  .idx = self.resources.count });
				
		case RELATION:
			if (components_has(&self.components, $Type::typeid) || tags_has(&self.tags, $Type::typeid)) {
				abort(ERR_TYPE_ALREADY_REGISTERED);
			}

			relations_add(&self.relations, $Type::typeid,
				{ .type = $Type::typeid, .size = $Type::size, .alignment = $Type::alignment,
				  .idx = self.relations.count });
			
		case SYSTEM: break;
	}

	return self;
}

<* Mownts new system to the world.
   @param name       : "Name of the system. It must be unique. Used for getting the system from the world." 
   @param query      : "Components, tags and relations list that should match while the system query. You can also separate types using `components`, `tags` and `relations` params of this proc. Using both approaches simultaneously, or crossing or duplicating types in different params is safe."
   @param components : "Components list that should match while the system query."
   @param tags       : "Tags list that should match while the system query."
   @param relations  : "Relations list that should match while the system query."
   @param without    : "Components, tags and relations list that should not be added to the entity, so system query will match entities only without them, even if these components, tags or relations were included into main query list."
   @param phase      : "System running phase, order in the pipeline. By default equals UPDATE."
   @param lifetime   : "Entities lifetime flag to optimize queries and do not process lifetimes that you want to avoid for current system. Includes all lifetimes (0b00000011) by default. Not used in ARCHETYPE approach."
   @param callback   : "Callback function that will be invoked each step of the world progress."
   @return             "Pointer to the world for chain calls." *>
fn World* World.mount(&self, String name = "", typeid[] query = {}, typeid[] components = {}, typeid[] tags = {},
	typeid[] relations = {}, typeid[] without = {}, Phase phase = UPDATE, char lifetime = 0b00000011,
	SystemCallback callback = null) {
	if (name && self.has_system(name)) abort(ERR_SYSTEM_ALREADY_MOUNTED);
	if (!name && phase == MANUAL) abort(ERR_MANUAL_SYSTEM_NAME_NOT_PROVIDED);
	if (callback == null) abort(ERR_CALLBACK_NOT_PROVIDED);
	if (!self.running) abort(ERR_WORLD_IS_NOT_RUNNING);

	System* system = mem::new(System, {
		.name = name, .callback = callback, .state = ENABLED,
		.lifetime = lifetime == 0 ? 0b00000011 : lifetime, .phase = phase });

	@pool() {
		Types _components;
		Types _tags;
		Types _relations;

		_components.init(tmem, MAX_COMPONENTS_COUNT);
		_tags.init(tmem, MAX_TAGS_COUNT);
		_relations.init(tmem, MAX_RELATIONS_COUNT);

		_components.push_all(components);
		_tags.push_all(tags);
		_relations.push_all(relations);
		
		if (query.len > 0) {
			foreach (type : query) {
				if (components_has(&self.components, type))    { _components.push(type); }
				else if (tags_has(&self.tags, type))		   { _tags.push(type);		 }
				else if (relations_has(&self.relations, type)) { _relations.push(type);  }
			}
		}
	
		if (_components.len() == 0 && _tags.len() == 0 && _relations.len() == 0 && without.len == 0) {
			/* Task is a system without query, it will just run with nil entities list. */
			system.state |= IS_TASK;
		} else {
			/* Initialize bits in the new system components marker. */
			if (_components.len() > 0) {
				foreach (type : _components) {
					if (try sz idx = component_index(&self.components, type)) {
						marker_set(COMPONENTS_MARKER_SIZE, &system.components, idx);
					}
				}

				system.state |= HAS_COMPONENTS;
			}

			/* Initialize bits in the new system tags marker. */
			if (_tags.len() > 0) {
				foreach (type : _tags) {
					if (try sz idx = tag_index(&self.tags, type)) {
						marker_set(TAGS_MARKER_SIZE, &system.tags, idx);
					}
				}

				system.state |= HAS_TAGS;
			}

			/* Initialize bits in the new system relations marker. */
			if (_relations.len() > 0) {
				foreach (type : _relations) {
					if (try sz idx = relation_index(&self.relations, type)) {
						marker_set(RELATIONS_MARKER_SIZE, &system.relations, idx);
					}
				}

				system.state |= HAS_RELATIONS;
			}

			if (without.len > 0) {
				bool has_components, has_tags, has_relations;

				foreach (type : without) {
					if (try sz idx = component_index(&self.components, type)) {
						marker_set(COMPONENTS_MARKER_SIZE, &system.without_components, idx);
						has_components = true;
					} else if (try sz idx = tag_index(&self.tags, type)) {
						marker_set(TAGS_MARKER_SIZE, &system.without_tags, idx);
						has_tags = true;
					} else if (try sz idx = relation_index(&self.relations, type)) {
						marker_set(RELATIONS_MARKER_SIZE, &system.without_relations, idx);
						has_relations = true;
					}
				}

				if (has_components) system.state |= HAS_WITHOUT_COMPONENTS;
				if (has_tags)		system.state |= HAS_WITHOUT_TAGS;
				if (has_relations)  system.state |= HAS_WITHOUT_RELATIONS;
			}
		}

		if (self.approach == ITERATION) system.entities.init(mem);

		switch (phase) {
			case START:		  self.schedule.start.push(system);
			case PRE_UPDATE:  self.schedule.pre_update.push(system);
			case UPDATE:	  self.schedule.update.push(system);
			case POST_UPDATE: self.schedule.post_update.push(system);
		}
	
		self.systems.push(system);
	};
	
	return self;
}

<* Unmounts the system from the world.
   @param name : "System name."
   @return       "Pointer to the world for chain calls." *>
fn World* World.unmount(&self, String name) {
	if (try idx = get_system_index(self, name)) {
		System* system = self.systems[idx];
		
		self.schedule.start.remove_unordered_at(idx);
		self.schedule.pre_update.remove_unordered_at(idx);
		self.schedule.update.remove_unordered_at(idx);
		self.schedule.post_update.remove_unordered_at(idx);
		self.systems.remove_unordered_at(idx);
		
		free_system(system);
		free(system);
	}
	
	return self;
}

<* Runs the world, but at first constructs all neccessary data from registered elements.
   World must has at least one registered component, but can has no tags, resources, or relations.
   @return "Pointer to the world for chain calls." *>
fn World* World.run(&self) {
	if (self.components.count == 0) abort(ERR_WORLD_HAS_NO_COMPONENTS);
	if (self.running) return self;

	components_adjust(&self.components);

	if (self.components.size > STACK_BUFFER_SIZE) abort(ERR_COMPONENTS_SIZE_INVALID);

	relations_adjust(self);

	self.chunk_size = self.components.size + self.relations.size;
	
	if (self.resources.count > 0) {
		resources_adjust(&self.resources);

		if (self.resources.size > STACK_BUFFER_SIZE) abort(ERR_RESOURCES_SIZE_INVALID);

		self.resources.storage = malloc(self.resources.size);
	}
	
	self.running = true;

	return self;
}

<* Spawns new entity into the world.
   @param lifetime : "Entity lifetime (default: Lifetime.DYNAMIC)."
   @return           "Pointer to new entity." *>
fn Entity* World.spawn(&self, Lifetime lifetime = DYNAMIC) {
	if (!self.running) abort(ERR_WORLD_IS_NOT_RUNNING);

	Entity* entity = block_insert(get_sparse_block(self, lifetime));

	return entity;
}

<* Despawns entity from the world.
   @param world  : "Pointer to the world."
   @param entity : "Reference to the entity." *>
fn void despawn_entity(World* world, Entity* entity) @private {
	if (entity.deleted()) return;
	
	if (world.approach == ARCHETYPE && world.running && !world.performing) {
		/* Prevent pushing to list several times. */
		if (!entity.despawning()) {
			world.deferred.despawning.push(entity);
			entity.state |= DESPAWNING;
		}
	} else {
		block_delete(entity.block, entity.chunk_idx);
		entity.state |= DELETED;
	}
}

<* Despawns entities from the world.
   @param entities : "References to the entities."
   @return "Pointer to the world for chain calls." *>
fn World* World.despawn(&self, Entity*... entities) {
	foreach (entity : entities) {
		despawn_entity(self, entity);
	}

	return self;
}

<* Creates new empty block in the world.
   @param world    : "Pointer to the world."
   @param lifetime : "Block lifetime."
   @return           "Pointer to newly created block." *>
fn Block* new_block(World* world, Lifetime lifetime) @local {
	Block* block = mem::new(Block);
	block.world = world;

	switch (lifetime) {
		case DYNAMIC:
			block.lifetime = DYNAMIC;
			block.size = DYNAMIC_CHUNK_SIZE;
			world.dynamics.push(block);
		case STATIC:
			block.lifetime = STATIC;
			block.size = STATIC_CHUNK_SIZE;
			world.statics.push(block);
	}

	block_init(block);

	return block;
}

<* Gets reference to the resource value by its type.
   @param $Type : "Resource type."
   @return        "Pointer to the resource."
   @return? NOT_FOUND : "Resource was not found (registered)." *>
macro void*? World.get_mut(&self, $Type) {
	if (try Resource* r = resources_get(&self.resources, $Type::typeid)) {
		$Type* ptr = ($Type*)(self.resources.storage + r.offset);
		return ptr;
	}

	return NOT_FOUND~;
}

<* Gets resource value by its type.
   @param $Type : "Resource type."
   @return        "Resource value"
   @return? NOT_FOUND : "Resource was not found (registered)." *>
macro World.get(&self, $Type) {
	if (try Resource* r = resources_get(&self.resources, $Type::typeid)) {
		$Type* ptr = ($Type*)(self.resources.storage + r.offset);
		return *ptr;
	}

	return NOT_FOUND~;
}

<* Gets reference to the resource value by its type.
   @param $Type : "Resource type." *>
macro World.get_mut_1(&self, $Type; @body(ptr)) @safemacro {
	if (try Resource* r = resources_get(&self.resources, $Type::typeid)) {
		@body(($Type*)(self.resources.storage + r.offset));
	}
}

<* Gets resource value by its type.
   @param $Type : "Resource type." *>
macro World.get_1(&self, $Type; @body(value)) @safemacro {
	if (try Resource* r = resources_get(&self.resources, $Type::typeid)) {
		$Type* ptr = ($Type*)(self.resources.storage + r.offset);
		@body(*ptr);
	}
}

<* Sets resource value by its type and initializer.
   @param world : "Pointer to the world."
   @param $Type : "Resource type."
   @param #init : "Resource initialization block."
   @return        "Pointer to the world for chain calls." *>
macro World* set_resource(World* world, $Type, #init) @private @safemacro {
	/* Storage for resources is allocated in run method. */
	if (!world.running) abort(ERR_WORLD_IS_NOT_RUNNING);
	
	if (try Resource* r = resources_get(&world.resources, $Type::typeid)) {
		$Type* ptr = ($Type*)(world.resources.storage + r.offset);
		*ptr = #init;
	}

	return world;
}

<* Step through each entity reference in the world.
   @param lifetime : "Entities lifetime flag." *>
macro World.each(&self, char lifetime = 0b00000011; @body(entity, lifetime)) @safemacro {
	if (lifetime & Lifetime.DYNAMIC) {
		foreach (block : self.dynamics) {
			EntitiesIterator iter = block_iter();

			while (block_next(block, &iter)) {
				@body(iter.entity, Lifetime.DYNAMIC);
			}
		}
	}

	if (lifetime & Lifetime.STATIC) {
		foreach (block : self.statics) {
			EntitiesIterator iter = block_iter();

			while (block_next(block, &iter)) {
				@body(iter.entity, Lifetime.STATIC);
			}
		}
	}
}

<* Checks if system with specific name was mounted.
   @param name : "System name."
   @return       "True if system exists, otherwise - false." *>
fn bool World.has_system(&self, String name) {
	if (name == "") abort(ERR_SYSTEM_NAME_NOT_PROVIDED);

	foreach (system : self.systems) {
		if (system.name == name) return true;
	}

	return false;
}

<* Gets reference to the system by its name.
   @param name : "System name."
   @return       "Pointer to the system."
   @return? NOT_FOUND : "System was not found (mounted)." *>
fn System*? World.get_system(&self, String name) {
	if (name == "") abort(ERR_SYSTEM_NAME_NOT_PROVIDED);

	foreach (system : self.systems) {
		if (system.name == name) return system;
	}

	return NOT_FOUND~;
}

<* Gets system index by its name.
   @param world : "Pointer to the world."
   @param name  : "System name."
   @return        "System index."
   @return? NOT_FOUND : "System was not found (mounted)." *>
fn sz? get_system_index(World* world, String name) @private {
	if (name == "") abort(ERR_SYSTEM_NAME_NOT_PROVIDED);

	foreach (idx, system : world.systems) {
		if (system.name == name) return idx;
	}

	return NOT_FOUND~;
}

<* Progress one step of the world life. Runs all mounted systems for all phases. *>
fn void World.progress(&self) {
	if (!self.running) abort(ERR_WORLD_IS_NOT_RUNNING);
	
	if (self.approach == ARCHETYPE) {
		/* Run systems with START phase, we should do it only once. */
		if (!self.started) {
			step_archetype(self, &self.schedule.start);
			self.started = true;
		}
	
		step_archetype(self, &self.schedule.pre_update);
		step_archetype(self, &self.schedule.update);
		step_archetype(self, &self.schedule.post_update);

		self.perform();
	} else if (self.approach == ITERATION) {
		foreach (system : self.systems) {
			if (!is_task(system)) system.entities.clear();
		}

		self.each(; Entity* entity, Lifetime lifetime) {
			foreach (system : self.systems) {
				if (system.enabled() && !is_task(system) && system.lifetime & lifetime) {
					if ((system_has_no_tags(system) ||
						 marker_is_subset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &entity.tags, &system.tags)) &&
						
						(system_has_no_components(system) ||
						 marker_is_subset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &entity.components, &system.components)) &&

						(system_has_no_relations(system) ||
						 marker_is_subset(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE, &entity.relations, &system.relations)) &&

						(system_has_no_without_tags(system) ||
						 marker_is_all_unset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE,
							&&marker_and(TAGS_MARKER_SIZE, &entity.tags, &system.without_tags))) &&

						(system_has_no_without_components(system) ||
						 marker_is_all_unset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE,
							&&marker_and(COMPONENTS_MARKER_SIZE, &entity.components, &system.without_components))) &&

						(system_has_no_without_relations(system) ||
						 marker_is_all_unset(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE,
							&&marker_and(RELATIONS_MARKER_SIZE, &entity.relations, &system.without_relations)))) {
						/* Add pointer to entity into system collection of entities for current system call. */
						system.entities.push(entity);
					}
				}
			}
		};

		if (!self.started) {
			step_iteration(self, &self.schedule.start);
			self.started = true;
		}

		step_iteration(self, &self.schedule.pre_update);
		step_iteration(self, &self.schedule.update);
		step_iteration(self, &self.schedule.post_update);
	}
}

<* Progress one step of the world life for one phase and ARCHETYPE approach.
   @param world   : "Pointer to the world."
   @param systems : "Collection of the systems of particular phase." *>
fn void step_archetype(World* world, Systems* systems) @local @inline {
	foreach (system : *systems) {
		if (system.enabled()) {
			if (is_task(system)) {
				system.callback(null, world);
			} else {
				foreach (archetype : world.archetypes) {
					if (archetype.entities.len() > 0 &&
						(system_has_no_tags(system) ||
						 marker_is_subset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &archetype.tags, &system.tags)) &&

						(system_has_no_components(system) ||
						 marker_is_subset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &archetype.components, &system.components)) &&

						(system_has_no_relations(system) ||
						 marker_is_subset(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE, &archetype.relations, &system.relations)) &&

						(system_has_no_without_tags(system) ||
						 marker_is_all_unset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE,
							&&marker_and(TAGS_MARKER_SIZE, &archetype.tags, &system.without_tags))) &&

						(system_has_no_without_components(system) ||
						 marker_is_all_unset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE,
							&&marker_and(COMPONENTS_MARKER_SIZE, &archetype.components, &system.without_components))) &&

						(system_has_no_without_relations(system) ||
						 marker_is_all_unset(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE,
							&&marker_and(RELATIONS_MARKER_SIZE, &archetype.relations, &system.without_relations)))) {
					   	/* Call system callback for matched archetype. */
						system.callback(&archetype.entities, world);
					}
				}
			}
		}
	}
}

<* Progress one step of the world life for one phase and ITERATION approach.
   @param world   : "Pointer to the world."
   @param systems : "Collection of the systems of particular phase." *>
fn void step_iteration(World* world, Systems* systems) @local @inline {
	foreach (system : systems) {
		if (system.enabled()) {
			system.callback(is_task(system) ? null : &system.entities, world);
		}
	}
}

<* Perform deferred actions for the world. *>
fn void World.perform(&self) {
	self.performing = true;

	/* Perform deferred despawning. */
	foreach (entity : self.deferred.despawning) {
		despawn_entity(self, entity);
		archetype_remove(entity);
	}

	self.deferred.despawning.clear();

	/* Perform deferred archetyping. */
	foreach (entity : self.deferred.archetyping) {
		if (entity.archetyping() && !entity.deleted()) {
			archetyping(entity);
			entity.state &= ~ARCHETYPING;
		}
	}

	self.deferred.archetyping.clear();

	// @pool() {
	// 	Archetypes released;
	// 	released.init(tmem, 0);

	// 	/* We need to delete empty archetypes. */
	// 	foreach (archetype : self.archetypes) {
	// 		if (try_free_archetype(archetype)) released.push(archetype);
	// 	}

	// 	if (released.size > 0) self.archetypes.remove_all_from(&released);
	// };

	self.performing = false;
}

<* Execute system by its name.
   @param name : "System name."
   @return       "Pointer to the world for chain calls." *>
fn World* World.execute(&self, String name) {
	if (try System* system = self.get_system(name) && system.enabled()) {
		if (is_task(system)) {
			system.callback(null, self);
		} else {
			foreach (archetype : self.archetypes) {
				if (archetype.entities.len() > 0 &&
					(system_has_no_tags(system) ||
					 marker_is_subset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &archetype.tags, &system.tags)) &&

					(system_has_no_components(system) ||
					 marker_is_subset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &archetype.components, &system.components)) &&

					(system_has_no_relations(system) ||
					 marker_is_subset(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE, &archetype.relations, &system.relations)) &&

					(system_has_no_without_tags(system) ||
					 marker_is_all_unset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE,
						&&marker_and(TAGS_MARKER_SIZE, &archetype.tags, &system.without_tags))) &&

					(system_has_no_without_components(system) ||
					 marker_is_all_unset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE,
						&&marker_and(COMPONENTS_MARKER_SIZE, &archetype.components, &system.without_components))) &&

					(system_has_no_without_relations(system) ||
					 marker_is_all_unset(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE,
						&&marker_and(RELATIONS_MARKER_SIZE, &archetype.relations, &system.without_relations)))) {
				   	/* Call system callback for matched archetype. */
					system.callback(&archetype.entities, self);
				}
			}
		}
	}

	return self;
}

<* Checks if systems are enabled.
   @param names : "System names."
   @return        "True if all systems are enabled, otherwise - false." *>
fn bool World.enabled(&self, String... names) @inline {
	foreach (name : names) {
		if (try System* system = self.get_system(name)) {
			if (!system.enabled()) return false;
		} else {
			return false;
		}
	}

	return true;
}

<* Enables systems.
   @param names : "System names."
   @return        "Pointer to the world for chain calls." *>
fn World* World.enable(&self, String... names) @inline {
	foreach (name : names) {
		if (try System* system = self.get_system(name)) {
			system.enable();
		}
	}

	return self;
}

<* Disables one or several systems.
   @param names : "System names."
   @return        "Pointer to the world for chain calls." *>
fn World* World.disable(&self, String... names) @inline {
	foreach (name : names) {
		if (try System* system = self.get_system(name)) {
			system.disable();
		}
	}

	return self;
}

<* Frees object memory.
   @param object : "Object to be freed, for example, entities slice." *>
fn void World.free(&self, any object) {
	if (try entities = anycast(object, Entity*[])) {
		alloc::free(&self.arena, entities.ptr);
	}
}

<* Creates new archetype.
   @param world      : "Pointer to the world."
   @param components : "Pointer to components bitset."
   @param tags       : "Pointer to tags bitset."
   @param relations  : "Pointer to relations bitset." *>
fn Archetype* new_archetype(World* world, sz[COMPONENTS_MARKER_SIZE]* components,
	sz[TAGS_MARKER_SIZE]* tags, sz[RELATIONS_MARKER_SIZE]* relations) @local {
	Archetype* archetype = mem::new(Archetype, {
		.components = marker_clone(COMPONENTS_MARKER_SIZE, components),
		.tags =		  marker_clone(TAGS_MARKER_SIZE, tags),
		.relations =  marker_clone(RELATIONS_MARKER_SIZE, relations)
	});

	archetype_init(archetype);
	world.archetypes.push(archetype);

	return archetype;
}

<* Gets archetype by query match bitsets.
   @param world      : "Pointer to the world."
   @param components : "Pointer to components bitset."
   @param tags       : "Pointer to tags bitset."
   @param relations  : "Pointer to relations bitset."
   @return             "Pointer to archetype." *>
fn Archetype* get_archetype(World* world, sz[COMPONENTS_MARKER_SIZE]* components,
	sz[TAGS_MARKER_SIZE]* tags, sz[RELATIONS_MARKER_SIZE]* relations) @private {
	foreach (archetype : world.archetypes) {
		if (marker_equals(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &archetype.components, components) &&
			marker_equals(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &archetype.tags, tags) &&
			marker_equals(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE, &archetype.relations, relations)) {
			return archetype;
		}
	}

	return new_archetype(world, components, tags, relations);
}

<* Gets the reference to block that is available to insert new entities,
   has free rows or newly created one.
   @param world    : "Pointer to the world."
   @param lifetime : "Block lifetime."
   @return           "Pointer to available block." *>
fn Block* get_sparse_block(World* world, Lifetime lifetime) @local @inline {
	Blocks* blocks = get_blocks(world, lifetime);

	/* The newest block is normally the only partially filled one. Searching backward
	   avoids walking every older full block for each spawned entity. */
	for (sz idx = blocks.len(); idx > 0;) {
		Block* block = (*blocks)[--idx];
		if (block_has_free_rows(block)) return block;
	}

	return new_block(world, lifetime);
}

<* Gets the reference to block that is totally free.
   @param world    : "Pointer to the world."
   @param lifetime : "Block lifetime."
   @return           "Pointer to free block." *>
fn Block* get_free_block(World* world, Lifetime lifetime) @local @inline @unused {
	Blocks* blocks = get_blocks(world, lifetime);

	foreach (block : blocks) {
		if (block_is_free(block)) return block;
	}

	return new_block(world, lifetime);
}

<* Gets blocks collection by its lifetime.
   @param world    : "Pointer to the world."
   @param lifetime : "Block lifetime."
   @return           "Pointer to blocks collection" *>
fn Blocks* get_blocks(World* world, Lifetime lifetime) @local @inline {
	switch (lifetime) {
		case DYNAMIC: return &world.dynamics;
		case STATIC:  return &world.statics;
	}

	return null;
}

<* Free all world resources.
   @param world : "Pointer to the world." *>
fn void free_world(World* world) @private {
	foreach (system : world.systems) {
		free_system(system);
		free(system);
	}

	foreach (archetype : world.archetypes) {
		free_archetype(archetype);
		free(archetype);
	}

	foreach (block : world.dynamics) {
		free_block(block);
		free(block);
	}

	foreach (block : world.statics) {
		free_block(block);
		free(block);
	}

	world.systems.free();
	world.archetypes.free();
	world.dynamics.free();
	world.statics.free();
	world.schedule.start.free();
	world.schedule.pre_update.free();
	world.schedule.update.free();
	world.schedule.post_update.free();
	world.deferred.despawning.free();
	world.deferred.archetyping.free();

	free(world.resources.storage);

	world.arena.free();
}
