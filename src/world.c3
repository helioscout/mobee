module moecs;

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
	<* Indicates that the world is in performing stage (runs deffered actions). *>
	bool performing;
	<* Deffered actions for the world. *>
	Deffered deffered;
}

<* Gets world blocks count for specific (default: all) lifetimes.
   @param lifetime : "Blocks lifetime flag." *>
fn usz World.size(&self, char lifetime = 0b00000011) {
	usz size;

	if (lifetime & Lifetime.DYNAMIC) size += self.dynamics.size;
	if (lifetime & Lifetime.STATIC)  size += self.statics.size;
	
	return size;
}

<* Gets world blocks count for specific lifetimes (comma-separated arguments). *>
macro usz World.size_of(&self, ...) {
	char $lifetime;
	
	$for var $i = 0; $i < $vacount; $i++:
		$if @typeid($vaexpr[$i]) == Lifetime.typeid:
			$lifetime |= $vaexpr[$i];
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
		world.deffered.despawning.init(mem);
		world.deffered.archetyping.init(mem);
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
			components_add(&self.components, $Type.typeid,
				{ .type = $Type.typeid, .size = $Type.sizeof, .alignment = $Type.alignof,
				  .idx = self.components.count });
		case TAG:
			tags_add(&self.tags, $Type.typeid, { .type = $Type.typeid, .idx = self.tags.count });
		case RESOURCE:
			resources_add(&self.resources, $Type.typeid,
				{ .type = $Type.typeid, .size = $Type.sizeof, .alignment = $Type.alignof,
				  .idx = self.resources.count });
		case SYSTEM: break;
	}

	return self;
}

<* Mounts new system to the world.
   @param definition : "System definition."
   @return             "Pointer to the world for chain calls." *>
fn World* World.mount(&self, SystemDefinition definition) {
	if (definition.name && self.has_system(definition.name)) abort("System with such name has already been mounted.");
	if (!definition.name && definition.phase == MANUAL) abort("Systems with MANUAL phase must have a name.");
	if (definition.callback == null) abort("Callback must be provided.");
	if (self.running) abort("You can't mount system to already running world.");

	System* system = mem::new(System,
		{ .name     = definition.name,
		  .callback = definition.callback,
		  .state    = ENABLED,
		  .lifetime = definition.lifetime == 0 ? 0b00000011 : definition.lifetime,
		  .phase    = definition.phase,
		  .component_types = @clone_slice(definition.components) });

	if (definition.components.len == 0 && definition.tags.len == 0) {
		system.state |= ElementState.IS_TASK;
	} else {
		if (definition.components.len > 0) {
			foreach (type : definition.components) {
				usz idx = component_index(&self.components, type);
				if (idx != usz.max) marker_set(COMPONENTS_MARKER_SIZE, &system.components, idx);
			}

			system.state |= ElementState.HAS_COMPONENTS;
		}

		if (definition.tags.len > 0) {
			foreach (type : definition.tags) {
				usz idx = tag_index(&self.tags, type);
				if (idx != usz.max) marker_set(TAGS_MARKER_SIZE, &system.tags, idx);
			}

			system.state |= ElementState.HAS_TAGS;
		}
	}

	system.entities.init(mem);

	switch (definition.phase) {
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
	if (try system = self.get_system(name)) {
		self.schedule.start.remove_item(system);
		self.schedule.pre_update.remove_item(system);
		self.schedule.update.remove_item(system);
		self.schedule.post_update.remove_item(system);
		self.systems.remove_item(system);
		
		free_system(system);
		free(system);
	}
	
	return self;
}

<* Runs the world, but at first constructs all neccessary data from registered elements.
   World must has at least one registered component, but can has no tags, resources.
   @return "Pointer to the world for chain calls." *>
fn World* World.run(&self) {
	if (self.components.count == 0) abort("The world has no registered components.");
	if (self.running) return self;

	components_adjust(&self.components);

	/* We must re-set all component markers for systems, because order of components
	   has been changed during adjustment and as a result components indexes changed. */
	foreach (system : self.systems) {
		if (system.component_types.len > 0) {
			marker_clear(COMPONENTS_MARKER_SIZE, &system.components);

			foreach (type : system.component_types) {
				usz idx = component_index(&self.components, type);
				marker_set(COMPONENTS_MARKER_SIZE, &system.components, idx);
			}
		}
	}

	if (self.resources.count > 0) {
		resources_adjust(&self.resources);

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
		self.deffered.despawning.push(entity);
		entity.state |= ElementState.DESPAWNING;
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
	Block* block;

	switch (lifetime) {
		case DYNAMIC:
			block = mem::new(Block, { .lifetime = DYNAMIC, .world = world, .size = DYNAMIC_CHUNK_SIZE });
			world.dynamics.push(block);
		case STATIC:
			block = mem::new(Block, { .lifetime = STATIC, .world = world, .size = STATIC_CHUNK_SIZE });
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
	Resource* r = resources_get(&self.resources, $Type.typeid);

	if (r != null) {
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
	Resource* r = resources_get(&self.resources, $Type.typeid);

	if (r != null) {
		$Type* ptr = ($Type*)(self.resources.storage + r.offset);
		*ptr = #init;
	}

	return self;
}

<* Sets resource value by its instance.
   @param $resource : "Resource instance."
   @return            "Pointer to the world for chain calls." *>
macro World* World.set(&self, $resource) {
	Resource* r = resources_get(&self.resources, $typeof($resource).typeid);

	if (r != null) {
		$typeof($resource)* ptr = ($typeof($resource)*)(self.resources.storage + r.offset);
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
				if (system.enabled() && system.lifetime & lifetime) {
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
					if ((!system_has_tags(system) ||
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

<* Perform deffered actions for the world. *>
fn void World.perform(&self) {
	self.performing = true;

	/* Perform deffered despawning. */
	foreach (entity : self.deffered.despawning) {
		self.despawn(entity);
		archetype_remove(entity);
	}

	self.deffered.despawning.clear();

	/* Perform deffered archetyping. */
	foreach (entity : self.deffered.archetyping) {
		if (entity.state & ElementState.ARCHETYPING != 0 && !entity.deleted()) {
			archetyping(entity);
			entity.state &= ~ElementState.ARCHETYPING;
		}
	}

	self.deffered.archetyping.clear();

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
fn Archetype* new_archetype(World* world, usz[COMPONENTS_MARKER_SIZE]* components,
	usz[TAGS_MARKER_SIZE]* tags) @local {
	Archetype* archetype = mem::new(Archetype, {
		.components = marker_clone(COMPONENTS_MARKER_SIZE, components),
		.tags = marker_clone(TAGS_MARKER_SIZE, tags) });

	archetype_init(archetype);
	world.archetypes.push(archetype);

	return archetype;
}

<* Gets archetype by query match bitsets.
   @param world      : "Pointer to the world."
   @param components : "Pointer to components bitset."
   @param tags       : "Pointer to tags bitset."
   @return             "Pointer to archetype." *>
fn Archetype* get_archetype(World* world, usz[COMPONENTS_MARKER_SIZE]* components,
	usz[TAGS_MARKER_SIZE]* tags) @private {
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

	foreach (block : blocks) {
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
