module mobee;

import std::io;

<* Entity type. *>
struct Entity {
	<* Entity state. *>
	ElementState state;
	<* Components marker, each set bit specifies that the component exists in the entity. *>
	sz[COMPONENTS_MARKER_SIZE] components;
	<* Tags marker, each set bit specifies that the tag exists in the entity. *>
	sz[TAGS_MARKER_SIZE] tags;
	<* Relations marker, each set bit specifies that the relation exists in the entity. *>
	sz[RELATIONS_MARKER_SIZE] relations;
	<* One-to-many relation marker, each bit specifies that the entity relation has
	   several target entities (several parents, children and so on). *>
	sz[RELATIONS_MARKER_SIZE] many;
	<* Reference to the parent block. *>
	Block* block;
	<* The index of the entity in the collection (chunk index for its components). *>
	sz chunk_idx;
	<* Archetype reference which entity belongs to. Is null for entities without components/tags/relations. *>
	Archetype* archetype;
	<* Entity index in the archetype collection (for fast removing). *>
	sz arch_idx;
}

<* Adds component to the entity by type and initializer.
   If entity already has a component it will be replaced by new one.
   @param entity   : "Pointer to the entity."
   @param $Type    : "Component type."
   @param #init    : "Component initialization block."
   @return           "Pointer to the entity." *>
macro Entity* add_component(Entity* entity, $Type, #init) @private @safemacro {
	if (try Component* c = components_get(&entity.block.world.components, $Type::typeid)) {
		$Type* ptr = ($Type*)(entity.block.chunks + entity.block.world.chunk_size * entity.chunk_idx + c.offset);
		*ptr = #init;												/* Storing value in the chunk. */
		
		marker_set(COMPONENTS_MARKER_SIZE, &entity.components, c.idx);	/* Setting marker bit.		   */

		archetyping(entity);
	}

	return entity;
}

<* Sets previously added component value in the entity by its type and initializer.
   @param entity : "Pointer to the entity."
   @param $Type  : "Component type."
   @param #init  : "Component initialization block."
   @return         "Pointer to the entity." *>
macro Entity* set_component(Entity* entity, $Type, #init) @private @safemacro {
	if (try Component* c = components_get(&entity.block.world.components, $Type::typeid)) {
		$Type* ptr = ($Type*)(entity.block.chunks + entity.block.world.chunk_size * entity.chunk_idx + c.offset);
		*ptr = #init;
	}
	
	return entity;
}

<* Gets reference to the component value by its type.
   @param $Type : "Component type."
   @return "Pointer to the component."
   @return? NOT_FOUND : "Component was not found (added)." *>
macro void*? Entity.get_mut(&self, $Type) {
	if (try Component* c = components_get(&self.block.world.components, $Type::typeid)) {
		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			$Type* ptr = ($Type*)(self.block.chunks + self.block.world.chunk_size * self.chunk_idx + c.offset);
			return ptr;
		}
	}

	return NOT_FOUND~;
}

<* Gets component value by its type.
   @param $Type : "Component type."
   @return "Component value."
   @return? NOT_FOUND : "Component was not found (added)." *>
macro Entity.get(&self, $Type) {
	if (try Component* c = components_get(&self.block.world.components, $Type::typeid)) {
		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			$Type* ptr = ($Type*)(self.block.chunks + self.block.world.chunk_size * self.chunk_idx + c.offset);
			return *ptr;
		}
	}

	return NOT_FOUND~;
}

<* Gets reference to the component value by its type.
   @param $Type : "Component type." *>
macro Entity.get_mut_1(&self, $Type; @body(ptr)) @safemacro {
	if (try Component* c = components_get(&self.block.world.components, $Type::typeid)) {
		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			@body(($Type*)(self.block.chunks + self.block.world.chunk_size * self.chunk_idx + c.offset));
		}
	}
}

<* Gets component value by its type.
   @param $Type : "Component type." *>
macro Entity.get_1(&self, $Type; @body(value)) @safemacro {
	if (try Component* c = components_get(&self.block.world.components, $Type::typeid)) {
		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			$Type* ptr = ($Type*)(self.block.chunks + self.block.world.chunk_size * self.chunk_idx + c.offset);
			@body(*ptr);
		}
	}
}

<* Step through each component pointer (mutable reference) of the entity.
   @param type : "Type (typeid) of the component."
   @param ptr  : "Pointer to the component value." *>
macro Entity.each(&self; @body(type, ptr)) @safemacro {
	/* If entity has no components, return. */
	if (marker_is_all_unset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &self.components)) return;

	World* world = self.block.world;

	for (sz idx = 0; idx < world.components.count; idx++) {
		Component* c = &world.components.types[idx];

		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			void* ptr = self.block.chunks + world.chunk_size * self.chunk_idx + c.offset;
			@body(c.type, ptr);
		}
	};
}

<* Removes components from entity of all passed types.
   @param ... : "Component types."
   @return		"Pointer to the entity." *>
macro Entity* Entity.remove(&self, ...) {
	$for var $i = 0; $i < $vaarg.len; $i++:
		var $Type = $vaarg[$i];

		$if $defined($Type):
			if (try sz idx = component_index(&self.block.world.components, $Type::typeid)) {
				marker_unset(COMPONENTS_MARKER_SIZE, &self.components, idx);
			}
		$endif
	$endfor

	archetyping(self);
	
	return self;
}

<* Checks if the entity has all components of passed types.
   @param ... : "Component types."
   @return		"True if entity has all components, otherwise - false." *>
macro bool Entity.has(&self, ...) {
	$for var $i = 0; $i < $vaarg.len; $i++:
		var $Type = $vaarg[$i];

		$if $defined($Type):
			if (try sz idx = component_index(&self.block.world.components, $Type::typeid)) {
				if (!marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, idx)) return false;
			} else {
				return false;
			}
		$endif
	$endfor

	return true;
}

<* Tags entity with all passed tag types.
   @param ... : "Tag types."
   @return      "Pointer to the entity." *>
macro Entity* Entity.tag(&self, ...) {
	$for var $i = 0; $i < $vaarg.len; $i++:
		var $Type = $vaarg[$i];

		$if $defined($Type):
			if (try sz idx = tag_index(&self.block.world.tags, $Type::typeid)) {
				marker_set(TAGS_MARKER_SIZE, &self.tags, idx);
			}
		$endif
	$endfor

	archetyping(self);

	return self;
}

<* Removes tags from entity of all passed types.
   @param ... : "Tag types."
   @return      "Pointer to the entity." *>
macro Entity* Entity.untag(&self, ...) {
	$for var $i = 0; $i < $vaarg.len; $i++:
		var $Type = $vaarg[$i];

		$if $defined($Type):
			if (try sz idx = tag_index(&self.block.world.tags, $Type::typeid)) {
				marker_unset(TAGS_MARKER_SIZE, &self.tags, idx);
			}
		$endif
	$endfor

	archetyping(self);

	return self;
}

<* Checks if the entity is tagged with all passed tag types.
   @param ... : "Tag types."
   @return      "True if entity is tagged with all types, otherwise - false." *>
macro bool Entity.tagged(&self, ...) {
	$for var $i = 0; $i < $vaarg.len; $i++:
		var $Type = $vaarg[$i];

		$if $defined($Type):
			if (try sz idx = tag_index(&self.block.world.tags, $Type::typeid)) {
				if (!marker_is_set(TAGS_MARKER_SIZE, &self.tags, idx)) return false;
			} else {
				return false;
			}
		$endif
	$endfor

	return true;
}

<* Despawns entity. *>
fn void Entity.despawn(&self) @inline {
	despawn_entity(self.block.world, self);
}

<* Checks if the entity has been deleted.
   @return "True if entity is deleted, otherwise - false." *>
fn bool Entity.deleted(&self) @inline => self.state & DELETED != 0;

<* Checks if the entity is deferred for despawning at the perform stage.
   @return "True if entity will be despawned, otherwise - false." *>
fn bool Entity.despawning(&self) @inline => self.state & DESPAWNING != 0;

<* Checks if the entity is deferred for archetyping at the perform stage.
   @return "True if entity will be archetyped, otherwise - false." *>
fn bool Entity.archetyping(&self) @inline => self.state & ARCHETYPING != 0;

<* Checks if the entity belongs to dynamic lifetime block.
   @return "True if entity is dynamic, otherwise - false." *>
fn bool Entity.is_dynamic(&self) @inline => self.block.lifetime == DYNAMIC;

<* Checks if the entity belongs to static lifetime block.
   @return "True if entity is static, otherwise - false." *>
fn bool Entity.is_static(&self) @inline => self.block.lifetime == STATIC;

<* Bind the entity to appropriate archetype.
   @param entity : "Pointer to the entity." *>
fn void archetyping(Entity* entity) @private {
	World* world = entity.block.world;

	if (world.approach != ARCHETYPE) return;

	if (world.running && !world.performing) {
		if (entity.state & ARCHETYPING == 0) {
			world.deferred.archetyping.push(entity);
			entity.state |= ARCHETYPING;
		}

		return;
	}

	archetype_remove(entity);

	/* If entity has components, or tags, or relations then bind archetype to it. */
	if (marker_is_any_set(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &entity.components) ||
		marker_is_any_set(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &entity.tags) ||
		marker_is_any_set(MAX_RELATIONS_COUNT, RELATIONS_MARKER_SIZE, &entity.relations)) {
		/* Find appropriate archetype or new one. */
		Archetype* archetype = get_archetype(world, &entity.components, &entity.tags, &entity.relations);

		entity.archetype = archetype;
		entity.arch_idx = archetype.entities.len();
		archetype.entities.push(entity);
	}
}
