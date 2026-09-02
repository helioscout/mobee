module mobee;

import std::io;

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
}

<* Registers element type for the world.
   @param element : "World element kind."
   @param $Type   : "Element (component/tag/resource) type."
   @return          "Pointer to the world for chain calls." *>
macro World* World.register(&self, Element element, $Type) {
	if (self.running) return self;
	
	switch (element) {
		case COMPONENT:
			components_add(&self.components, $Type::typeid,
				{ .type = $Type::typeid, .size = $Type::size, .alignment = $Type::alignment,
				  .idx = self.components.count });
		case TAG:
			tags_add(&self.tags, $Type::typeid, { .type = $Type::typeid, .idx = self.tags.count });
		case RESOURCE:
			resources_add(&self.resources, $Type::typeid,
				{ .type = $Type::typeid, .size = $Type::size, .alignment = $Type::alignment,
				  .idx = self.resources.count });
		case SYSTEM: break;
	}

	return self;
}

<* Mounts new system to the world.
   @param name       : "Name of the system. It must be unique. Used for getting the system from the world." 
   @param components : "Components list that should match while the system query."
   @param tags       : "Tags list that should match while the system query."
   @param phase      : "System running phase, order in the pipeline. By default equals UPDATE."
   @param lifetime   : "Entities lifetime flag to optimize queries and do not process lifetimes that you want to avoid for current system. Includes all lifetimes (0b00000011) by default. Not used in ARCHETYPE approach."
   @return             "Pointer to the world for chain calls." *>
fn World* World.mount(&self, String name = "", typeid[] components = {}, typeid[] tags = {},
	Phase phase = UPDATE, char lifetime = 0b00000011, SystemCallback callback = null) {
	if (name && self.has_system(name)) abort(ERR_SYSTEM_ALREADY_MOUNTED);
	if (!name && phase == MANUAL) abort(ERR_MANUAL_SYSTEM_NAME_NOT_PROVIDED);
	if (callback == null) abort(ERR_CALLBACK_NOT_PROVIDED);
	if (!self.running) abort(ERR_WORLD_IS_NOT_RUNNING);

	System* system = mem::new(System, {
		.name = name, .callback = callback, .state = ENABLED,
		.lifetime = lifetime == 0 ? 0b00000011 : lifetime, .phase = phase });

	if (components.len == 0 && tags.len == 0) {
		system.state |= ElementState.IS_TASK;
	} else {
		if (components.len > 0) {
			foreach (type : components) {
				if (try sz idx = component_index(&self.components, type)) {
					marker_set(COMPONENTS_MARKER_SIZE, &system.components, idx);
				}
			}

			system.state |= ElementState.HAS_COMPONENTS;
		}

		if (tags.len > 0) {
			foreach (type : tags) {
				if (try sz idx = tag_index(&self.tags, type)) {
					marker_set(TAGS_MARKER_SIZE, &system.tags, idx);
				}
			}

			system.state |= ElementState.HAS_TAGS;
		}
	}

	if (self.approach == ITERATION) system.entities.init(mem);

	switch (phase) {
		case START: self.schedule.start.push(system);
		case PRE_UPDATE: self.schedule.pre_update.push(system);
		case UPDATE: self.schedule.update.push(system);
		case POST_UPDATE: self.schedule.post_update.push(system);
	}
	
	self.systems.push(system);
	
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
   World must has at least one registered component, but can has no tags, resources.
   @return "Pointer to the world for chain calls." *>
fn World* World.run(&self) {
	if (self.components.count == 0) abort(ERR_WORLD_HAS_NO_COMPONENTS);
	if (self.running) return self;

	components_adjust(&self.components);

	if (self.components.size > STACK_BUFFER_SIZE) abort(ERR_COMPONENTS_SIZE_INVALID);

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
	if (!self.running) abort("Run the world first.");

	Entity* entity = block_insert(get_sparse_block(self, lifetime));

	return entity;
}

<* Despawns entity from the world.
   @param entity : "Reference to the entity." *>
fn void World.despawn(&self, Entity* entity) {
	if (entity.deleted()) return;
	
	if (self.approach == ARCHETYPE && self.running && !self.performing) {
		/* Prevent pushing to list several times. */
		if (!entity.despawning()) {
			self.deferred.despawning.push(entity);
			entity.state |= ElementState.DESPAWNING;
		}
	} else {
		block_delete(entity.block, entity.chunk_idx);
		entity.state |= ElementState.DELETED;
	}
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
macro void*? World.get(&self, $Type) {
	if (try Resource* r = resources_get(&self.resources, $Type::typeid)) {
		$Type* ptr = ($Type*)(self.resources.storage + r.offset);
		return ptr;
	}

	return NOT_FOUND~;
}

<* Sets resource value by its type and initializer.
   @param $Type : "Resource type."
   @param #init : "Resource initialization block."
   @return "Pointer to the world for chain calls." *>
macro World* World.@set(&self, $Type, #init) {
	if (try Resource* r = resources_get(&self.resources, $Type::typeid)) {
		$Type* ptr = ($Type*)(self.resources.storage + r.offset);
		*ptr = #init;
	}

	return self;
}

<* Sets resource value by its instance.
   @param $resource : "Resource instance."
   @return            "Pointer to the world for chain calls." *>
macro World* World.set(&self, $resource) {
	if (try Resource* r = resources_get(&self.resources, $Typeof($resource)::typeid)) {
		$Typeof($resource)* ptr = ($Typeof($resource)*)(self.resources.storage + r.offset);
		*ptr = $resource;
	}

	return self;
}

<* Step through each entity reference in the world.
   @param lifetime : "Entities lifetime flag." *>
macro World.@each(&self, char lifetime = 0b00000011; @body(entity, lifetime)) {
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
	if (name == "") abort("System name can't be empty.");

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
	if (name == "") abort("System name can't be empty.");

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
	if (name == "") abort("System name can't be empty.");

	foreach (idx, system : world.systems) {
		if (system.name == name) return idx;
	}

	return NOT_FOUND~;
}

<* Progress one step of the world life. Runs all mounted systems for all phases. *>
fn void World.progress(&self) {
	if (!self.running) abort("Run the world first.");
	
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

		self.@each(; Entity* entity, Lifetime lifetime) {
			foreach (system : self.systems) {
				if (system.enabled() && !is_task(system) && system.lifetime & lifetime) {
					if ((!system_has_tags(system) ||
						 marker_is_subset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &entity.tags, &system.tags)) &&
						(!system_has_components(system) ||
						 marker_is_subset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &entity.components, &system.components))) {
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
						(!system_has_tags(system) ||
						 marker_is_subset(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &archetype.tags, &system.tags)) &&
						(!system_has_components(system) ||
						 marker_is_subset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &archetype.components, &system.components))) {
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
		self.despawn(entity);
		archetype_remove(entity);
	}

	self.deferred.despawning.clear();

	/* Perform deferred archetyping. */
	foreach (entity : self.deferred.archetyping) {
		if (entity.archetyping() && !entity.deleted()) {
			archetyping(entity);
			entity.state &= ~ElementState.ARCHETYPING;
		}
	}

	self.deferred.archetyping.clear();

	/* We need to delete empty archetypes. */
	foreach (archetype : self.archetypes) {
		if (archetype.entities.len() == 0) free_archetype(archetype);
	}
	
	self.archetypes.remove_if(fn (archetype) => (*archetype).entities.len() == 0);

	self.performing = false;
}

<* Creates new archetype.
   @param world      : "Pointer to the world."
   @param components : "Pointer to components bitset."
   @param tags       : "Pointer to tags bitset." *>
fn Archetype* new_archetype(World* world, sz[COMPONENTS_MARKER_SIZE]* components,
	sz[TAGS_MARKER_SIZE]* tags) @local {
	Archetype* archetype = mem::new(Archetype);
	archetype.components = marker_clone(COMPONENTS_MARKER_SIZE, components);
	archetype.tags = marker_clone(TAGS_MARKER_SIZE, tags);

	archetype_init(archetype);
	world.archetypes.push(archetype);

	return archetype;
}

<* Gets archetype by query match bitsets.
   @param world      : "Pointer to the world."
   @param components : "Pointer to components bitset."
   @param tags       : "Pointer to tags bitset."
   @return             "Pointer to archetype." *>
fn Archetype* get_archetype(World* world, sz[COMPONENTS_MARKER_SIZE]* components,
	sz[TAGS_MARKER_SIZE]* tags) @private {
	foreach (archetype : world.archetypes) {
		if (marker_equals(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &archetype.components, components) &&
			marker_equals(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &archetype.tags, tags)) {
			return archetype;
		}
	}

	return new_archetype(world, components, tags);
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
}
