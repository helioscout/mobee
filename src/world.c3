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
   @param lifetime : "Blocks lifetime flag."
*>
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

<* Initializes the world. *>
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
   @return          "Pointer to the world for chain calls."
*>
macro World* World.register(&self, Element element, $Type) {
	if (self.running) return self;
	
	switch (element) {
		case COMPONENT:
			components_add(&self.components, $Type.typeid,
				{ .type = $Type.typeid, .size = $Type.sizeof, .idx = self.components.count });
		case TAG:
			tags_add(&self.tags, $Type.typeid, { .type = $Type.typeid, .idx = self.tags.count });
		case RESOURCE:
			resources_add(&self.resources, $Type.typeid,
				{ .type = $Type.typeid, .size = $Type.sizeof, .idx = self.resources.count });
		case SYSTEM: break;
	}

	return self;
}

<* Mounts new system to the world.
   @param definition : "System definition."
   @return             "Pointer to the world for chain calls."
*>
fn World* World.mount(&self, SystemDefinition definition) {
	if (definition.name && self.has_system(definition.name)) panic("System with such name has already been mounted.");
	if (!definition.name && definition.phase == MANUAL) panic("Systems with MANUAL phase must have a name.");
	if (definition.callback == null) panic("Callback must be provided.");
	if (self.running) panic("You can't mount system to already running world.");

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
				if (idx != -1) marker_set(COMPONENTS_MARKER_SIZE, &system.components, idx);
			}

			system.state |= ElementState.HAS_COMPONENTS;
		}

		if (definition.tags.len > 0) {
			foreach (type : definition.tags) {
				usz idx = tag_index(&self.tags, type);
				if (idx != -1) marker_set(TAGS_MARKER_SIZE, &system.tags, idx);
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
   @return       "Pointer to the world for chain calls."
*>
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
   @return "Pointer to the world for chain calls."
*>
fn World* World.run(&self) {
	if (self.components.is_empty()) panic("The world has no registered components.");
	if (world.running) return self;

	components_adjust(&world.components);

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
   @return           "Pointer to new entity."
*>
fn Entity* World.spawn(&self, Lifetime lifetime = DYNAMIC) {
	if (!self.running) panic("Run the world first.");

	Entity* entity = block_insert(get_sparse_block(self, lifetime));

	return entity;
}

<* Despawns entity from the world.
   @param entity : "Reference to the entity."
*>
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
   @param lifetime : "Block lifetime."
   @return           "Pointer to newly created block."
*>
fn Block* new_block(World* world, Lifetime lifetime) @local {
	Block* block;

	switch (lifetime) {
		case DYNAMIC:
			block = mem::new(Block, { .lifetime = DYNAMIC, .world = world, .size = DYNAMIC_CHUNK_SIZE });
			self.dynamics.push(block);
		case STATIC:
			block = mem::new(StaticBlock, { .lifetime = STATIC, .world = world, .size = STATIC_CHUNK_SIZE });
			self.statics.push(block);
	}

	block_init(block);

	return block;
}

<* Gets reference to the resource value by its type.
   @param $Type : "Resource type."
   @return "Pointer to the resource."
   @return? NOT_FOUND : "Resource was not found (registered)."
*>
macro void*? World.get(&self, $Type) {
	if (try resource = self.resources.get_ref($Type.typeid)) {
		return resource.value.ptr;
	}

	return NOT_FOUND?;
}

<* Sets resource value by its type and initializer.
   @param $Type : "Resource type."
   @param #init : "Resource initialization block."
   @return "Pointer to the world for chain calls."
*>
macro World* World.@set(&self, $Type, #init) {
	if (try resource = self.resources.get_ref($Type.typeid) &&
		try $Type* value = anycast(resource.value, $Type)) {
		*value = #init;
	}

	return self;
}

<* Sets resource value by its instance.
   @param $resource : "Resource instance."
   @return "Pointer to the world for chain calls."
*>
macro World* World.set(&self, $resource) {
	if (try resource = self.resources.get_ref($typeof($resource).typeid) &&
		try $typeof($resource)* value = anycast(resource.value, $typeof($resource))) {
		*value = $resource;
	}

	return self;
}

<* Step through each entity reference in the world.
   @param lifetime : "Entities lifetime flag."
*>
macro World.@each(&self, char lifetime = 0b00000111; @body(entity, lifetime)) {
	if (lifetime & Lifetime.QUICK && self.use_quicks) {
		/* Iterate entities in the buffer. */
		for (usz idx = 0; idx < self.idx; idx++) {
			if (!self.deleted.contains(idx)) {	/* Omit deleted entities. */
				@body(&(*self.buffer)[idx], Lifetime.QUICK);
			}
		}

		foreach (block : self.quicks) {
			EntitiesIterator iter = block.iter();

			while (block.next(&iter)) {
				@body(iter.entity, Lifetime.QUICK);
			}
		}
	}

	if (lifetime & Lifetime.DYNAMIC) {
		foreach (block : self.dynamics) {
			EntitiesIterator iter = block.iter();

			while (block.next(&iter)) {
				@body(iter.entity, Lifetime.DYNAMIC);
			}
		}
	}

	if (lifetime & Lifetime.STATIC) {
		foreach (block : self.statics) {
			EntitiesIterator iter = block.iter();

			while (block.next(&iter)) {
				@body(iter.entity, Lifetime.STATIC);
			}
		}
	}
}

<* Checks if system with specific name was mounted.
   @param name : "System name."
   @return       "True if system exists, otherwise - false."
*>
fn bool World.has_system(&self, String name) {
	if (name == "") panic("System name can't be empty.");

	foreach (system : self.systems) {
		if (system.name == name) return true;
	}

	return false;
}

<* Gets reference to the system by its name.
   @param name : "System name."
   @return       "Pointer to the system."
   @return? NOT_FOUND : "System was not found (mounted)."
*>
fn System*? World.get_system(&self, String name) {
	if (name == "") panic("System name can't be empty.");

	foreach (system : self.systems) {
		if (system.name == name) return system;
	}

	return NOT_FOUND?;
}

<* Progress one step of the world life.
   Runs all mounted systems.
   @require self.running : "Run the world first."
*>
fn void World.progress(&self) {
	if (self.approach == ARCHETYPE) {
		foreach (system : self.systems) {
			if (system.enabled()) {
				foreach (archetype : self.archetypes) {
					if ((!system.has_tags() ||
							system.tags
								.and(archetype.tags)
								.xor(system.tags)
								.cardinality() == 0) &&
						(!system.has_components() ||
							system.components
								.and(archetype.components)
								.xor(system.components)
								.cardinality() == 0)) {
					   	/* Call system callback for matched archetype. */
						system.callback(archetype.entities, self);
					}
				}
			}
		}
		
		self.perform();
	} else if (self.approach == ITERATION) {
		/* Clear all systems entities collections. */
		foreach (system : self.systems) {
			if (system.enabled()) system.entities.clear();
		}
	
		self.@each(; Entity* entity, Lifetime lifetime) {
			foreach (system : self.systems) {
				if (system.enabled() &&						/* If system is enabled and                           */
					system.lifetime & lifetime) {			/* consider system lifetime.                          */
					if ((!system.has_tags() ||				/* If system query has no tags, or                    */
							system.tags						/* take system tags bits,                             */
								.and(entity.tags)			/* perform and (&) with entity tags bits              */
								.xor(system.tags)			/* and perform xor (^) with system tags bits.         */
								.cardinality() == 0) &&		/* Ensure that xor prove all system tags match.       */
						(!system.has_components() ||		/* If system query has no components, or              */
							system.components				/* take system components bits,                       */
								.and(entity.components)		/* perform and (&) with entity components bits        */
								.xor(system.components)		/* and perform xor (^) with system components bits.   */
								.cardinality() == 0)) {		/* Ensure that xor prove all system components match. */
						/* Add pointer to entity into system collection of entities for current system call.      */
						system.entities.push(entity);
					}
				}
			}
		};

		foreach (system : self.systems) {
			if (system.enabled()) system.callback(system.entities, self);
		}
	}
}

<* Perform deffered actions for the world. *>
fn void World.perform(&self) {
	self.performing = true;

	/* Perform deffered despawning. */
	foreach (entity : self.deffered.despawning) {
		self.despawn(entity);
		if (entity.archetype != null) entity.archetype.entities.remove_item(entity);
	}

	self.deffered.despawning.clear();

	/* Perform deffered archetyping. */
	foreach (entity : self.deffered.archetyping) {
		if (entity.state & ElementState.ARCHETYPING != 0 && !entity.deleted()) {
			entity.archetyping();
			entity.state &= ~ElementState.ARCHETYPING;
		}
	}

	self.deffered.archetyping.clear();

	/* We need to delete empty archetypes. */
	foreach (archetype : self.archetypes) {
		if (archetype.entities.len() == 0) archetype.entities.free();
	}
	
	self.archetypes.remove_if(fn (archetype) => (*archetype).entities.len() == 0);

	self.performing = false;
}

<* Creates new archetype.
   @param components : "Components bitset."
   @param tags : "Tags bitset."
*>
fn Archetype* World.new_archetype(&self, ComponentsMarker components, TagsMarker tags) @local {
	Archetype* archetype = mem::new(Archetype, { .components = components, .tags = tags });

	archetype.init();
	self.archetypes.push(archetype);

	return archetype;
}

<* Gets archetype by query match bitsets.
   @param components : "Components bitset."
   @param tags : "Tags bitset."
   @return "Pointer to archetype."
*>
fn Archetype* World.get_archetype(&self, ComponentsMarker components, TagsMarker tags) @private {
	foreach (archetype : self.archetypes) {
		if (archetype.components.xor(components).cardinality() == 0 &&
			archetype.tags.xor(tags).cardinality() == 0) {
			return archetype;
		}
	}

	return self.new_archetype(components, tags);
}

<* Gets the reference to block that is available to insert new entities,
   has free rows or newly created one.
   @param lifetime : "Block lifetime."
   @return           "Pointer to available block."
*>
fn Block* get_sparse_block(World* world, Lifetime lifetime) @local @inline {
	Blocks* blocks = get_blocks(world, lifetime);

	foreach (block : blocks) {
		if (block_has_free_rows(block)) return block;
	}

	return new_block(world, lifetime);
}

<* Gets the reference to block that is totally free.
   @param lifetime : "Block lifetime."
   @return           "Pointer to free block."
*>
fn Block* get_free_block(World* world, Lifetime lifetime) @local @inline @unused {
	Blocks* blocks = get_blocks(world, lifetime);

	foreach (block : blocks) {
		if (block_is_free(block)) return block;
	}

	return new_block(world, lifetime);
}

<* Gets blocks collection by its lifetime.
   @param lifetime : "Block lifetime."
   @return           "Pointer to blocks collection"
*>
fn Blocks* get_blocks(World* world, Lifetime lifetime) @local @inline {
	switch (lifetime) {
		case DYNAMIC: return &world.dynamics;
		case STATIC:  return &world.statics;
	}

	return null;
}
