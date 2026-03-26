module moecs;

import std::io;

<* Entity type. *>
struct Entity {
	<* Entity state. *>
	ElementState state;
	<* Components marker, each set bit specifies that the component exists in the entity. *>
	usz[COMPONENTS_MARKER_SIZE] components;
	<* Tags marker, each set bit specifies that the tag exists in the entity. *>
	usz[TAGS_MARKER_SIZE] tags;
	<* Reference to the parent block. *>
	Block* block;
	<* The index of the entity in the collection (chunk index for its components). *>
	usz chunk_idx;
	<* Archetype reference which entity belongs to. Is null for entities without components/tags. *>
	Archetype* archetype;
	<* Entity index in the archetype collection (for fast removing). *>
	usz arch_idx;
}

<* Adds component to the entity by type and initializer.
   If entity already has a component it will be replaced by new one.
   @param $Type : "Component type."
   @param #init : "Component initialization block."
   @param $perform : "Perform archetyping of the entity. You should not change this parameter (inner logic)."
   @return "Pointer to the entity." *>
macro Entity* Entity.@add(&self, $Type, #init, bool $perform = true) {
	if (try usz idx = component_index(&self.block.world.components, $Type.typeid)) {
		self.@set($Type, #init);									/* Storing value in the chunk. */
		marker_set(COMPONENTS_MARKER_SIZE, &self.components, idx);	/* Setting marker bit.		   */
		if ($perform) archetyping(self);
	}

	return self;
}

<* Sets component value in the entity by its type and initializer.
   @param $Type : "Component type."
   @param #init : "Component initialization block."
   @return "Pointer to the entity." *>
macro Entity* Entity.@set(&self, $Type, #init) {
	if (try Component* c = components_get(&self.block.world.components, $Type.typeid)) {
		$Type* ptr = ($Type*)(self.block.chunks + self.block.world.components.size * self.chunk_idx + c.offset);
		*ptr = #init;
	}
	
	return self;
}

<* Add component to the entity by its instance. If entity already has a component it will be replaced by new one.
   @param $component : "Component instance."
   @param $perform : "Perform archetyping of the entity. You should not change this parameter (inner logic)."
   @return "Pointer to the entity." *>
macro Entity* Entity.add(&self, $component, bool $perform = true) {
	if (try usz idx = component_index(&self.block.world.components, $typeof($component).typeid)) {
		self.set($component);										/* Storing value in the chunk. */
		marker_set(COMPONENTS_MARKER_SIZE, &self.components, idx);	/* Setting marker bit.		   */
		if ($perform) archetyping(self);
	}

	return self;
}

<* Sets component in the entity by its instance.
   @param $component : "Component instance."
   @return "Pointer to the entity." *>
macro Entity* Entity.set(&self, $component) {
	if (try Component* c = components_get(&self.block.world.components, $typeof($component).typeid)) {
		$typeof($component)* ptr = ($typeof($component)*)(self.block.chunks
			+ self.block.world.components.size * self.chunk_idx + c.offset);
		*ptr = $component;
	}
	
	return self;
}

<* Gets reference to the component value by its type.
   @param $Type : "Component type."
   @return "Pointer to the component."
   @return? NOT_FOUND : "Component was not found (added)." *>
macro void*? Entity.get(&self, $Type) {
	if (try Component* c = components_get(&self.block.world.components, $Type.typeid)) {
		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			$Type* ptr = ($Type*)(self.block.chunks + self.block.world.components.size * self.chunk_idx + c.offset);
			return ptr;
		}
	}

	return NOT_FOUND~;
}

<* Gets references to all components of passed types.
   @param allocator : "Allocator for returning slice underlying array."
   @require $vacount > 0 : "You must pass at least one component type. To get references to all components use all() method instead."
   @return "Slice of any with pointers to component values." *>
macro any[] Entity.get_all(&self, Allocator allocator, ...) {
	any[$vacount]* values = (any[$vacount]*)allocator::malloc(allocator, any.sizeof * $vacount);
	usz idx = 0;	/* We need to know amount of really found component values. */

	$for var $i = 0; $i < $vacount; $i++:
		var $Type = $vaexpr[$i];
		
		$if $Type.kindof == TypeKind.STRUCT || $Type.kindof == TypeKind.TYPEDEF:
			if (try $Type* value = self.get($Type)) {
				(*values)[idx++] = value;
			}
		$endif
	$endfor
	
	/* If there are no components found, return empty slice. */
	return idx == 0 ? {} : (*values)[:idx];
}

<* Gets references to all components of passed types. Alocates using temporary allocator.
   Consider call this function inside @pool() { ... }; marco.
   @return "Slice of any with pointers to component values." *>
macro any[] Entity.tget_all(&self, ...) => self.get_all(tmem, $vasplat);

<* Gets references to all components set in the entity.
   @param allocator : "Allocator for returning slice underlying array."
   @return "Slice of any with pointers to all component values." *>
fn any[] Entity.all(&self, Allocator allocator) {
	ComponentPointers values;

	for (usz idx = 0; idx < self.block.world.components.count; idx++) {
		Component* c = &self.block.world.components.types[idx];
		
		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			void* ptr = self.block.chunks + self.block.world.components.size * self.chunk_idx + c.offset;
			values.push(any_make(ptr, c.type));
		}
	};

	return values.to_array(allocator);
}

<* Gets references to all components set in the entity. Alocates using temporary allocator.
   Consider call this function inside @pool() { ... }; marco.
   @return "Slice of any with pointers to all component values." *>
fn any[] Entity.tall(&self) => self.all(tmem);

<* Step through each component of the entity. Does not make any additional allocations.
   @param type : "Type (typeid) of the component."
   @param ptr : "Pointer to the component value." *>
macro Entity.@each(&self; @body(type, ptr)) {
	/* If entity has no components, return. */
	if (marker_is_all_unset(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &self.components)) return;

	for (usz idx = 0; idx < self.block.world.components.count; idx++) {
		Component* c = &self.block.world.components.types[idx];

		if (marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, c.idx)) {
			void* ptr = self.block.chunks + self.block.world.components.size * self.chunk_idx + c.offset;
			@body(c.type, ptr);
		}
	};
}

<* Removes component from entity by its type.
   @param type : "Component type id."
   @param perform : "Perform archetyping of the entity. You should not change this parameter (inner logic)."
   @return "Pointer to the entity." *>
fn Entity* Entity.remove(&self, typeid type, bool perform = true) {
	if (try usz idx = component_index(&self.block.world.components, type)) {
		marker_unset(COMPONENTS_MARKER_SIZE, &self.components, idx);
		if (perform) archetyping(self);
	}

	return self;
}

<* Removes components from entity of all passed types.
   @require $vacount > 0 : "You must pass at least one component type."
   @return "Pointer to the entity." *>
macro Entity* Entity.remove_all(&self, ...) {
	$for var $i = 0; $i < $vacount; $i++:
		var $Type = $vaexpr[$i];
		self.remove($Type.typeid, false);
	$endfor

	archetyping(self);

	return self;
}

<* Checks if the enity has a component.
   @param $Type : "Component type."
   @return "True if entity has a component, otherwise - false." *>
macro bool Entity.has(&self, $Type) {
	if (try usz idx = component_index(&self.block.world.components, $Type.typeid)) {
		return marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, idx);
	}

	return false;
}

<* Checks if the entity has all components of passed types.
   @param types : "Component types."
   @return "True if entity has all components, otherwise - false." *>
fn bool Entity.has_all(&self, typeid... types) {
	bool has = true;
	
	foreach (type : types) {
		if (try usz idx = component_index(&self.block.world.components, type)) {
			has = has && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, idx);
		} else {
			has = false;
		}
	}

	return has;
}

<* Tags entity with specified tag type.
   @param type : "Tag type id."
   @param perform : "Perform archetyping of the entity. You should not change this parameter (inner logic)."
   @return "Pointer to the entity." *>
fn Entity* Entity.tag(&self, typeid type, bool perform = true) {
	if (try usz idx = tag_index(&self.block.world.tags, type)) {
		marker_set(TAGS_MARKER_SIZE, &self.tags, idx);
		if (perform) archetyping(self);
	}

	return self;
}

<* Tags entity with all passed tag types.
   @require $vacount > 0 : "You must pass at least one tag type."
   @return "Pointer to the entity." *>
macro Entity* Entity.tag_all(&self, ...) {
	$for var $i = 0; $i < $vacount; $i++:
		var $Type = $vaexpr[$i];
		self.tag($Type.typeid, false);
	$endfor

	archetyping(self);

	return self;
}

<* Removes tag from entity.
   @param type : "Tag type id."
   @param perform : "Perform archetyping of the entity. You should not change this parameter (inner logic)."
   @return "Pointer to the entity." *>
fn Entity* Entity.untag(&self, typeid type, bool perform = true) {
	if (try usz idx = tag_index(&self.block.world.tags, type)) {
		marker_unset(TAGS_MARKER_SIZE, &self.tags, idx);
		if (perform) archetyping(self);
	}

	return self;
}

<* Removes tags from entity of all passed types.
   @require $vacount > 0 : "You must pass at least one tag type."
   @return "Pointer to the entity." *>
macro Entity* Entity.untag_all(&self, ...) {
	$for var $i = 0; $i < $vacount; $i++:
		var $Type = $vaexpr[$i];
		self.untag($Type.typeid, false);
	$endfor

	archetyping(self);

	return self;
}

<* Checks if the entity is tagged with specified tag type.
   @param type : "Tag type id."
   @return "True if the entity has tag, otherwise - false." *>
fn bool Entity.tagged(&self, typeid type) {
	if (try usz idx = tag_index(&self.block.world.tags, type)) {
		return marker_is_set(TAGS_MARKER_SIZE, &self.tags, idx);
	} else {
		return false;
	}
}

<* Checks if the entity is tagged with all passed tag types.
   @param types : "Tag types."
   @return "True if entity is tagged with all types, otherwise - false." *>
fn bool Entity.tagged_all(&self, typeid... types) {
	bool tagged = true;
	
	foreach (type : types) {
		if (try usz idx = tag_index(&self.block.world.tags, type)) {
			tagged = tagged && marker_is_set(TAGS_MARKER_SIZE, &self.tags, idx);
		} else {
			tagged = false;
		}
	}

	return tagged;
}

<* Despawns entity. *>
fn void Entity.despawn(&self) @inline {
	self.block.world.despawn(self);
}

<* Checks if the entity has been deleted.
   @return "True if entity is deleted, otherwise - false." *>
fn bool Entity.deleted(&self) @inline => self.state & ElementState.DELETED != 0;

<* Checks if the entity is deferred for despawning at the perform stage.
   @return "True if entity will be despawned, otherwise - false." *>
fn bool Entity.despawning(&self) @inline => self.state & ElementState.DESPAWNING != 0;

<* Checks if the entity is deferred for archetyping at the perform stage.
   @return "True if entity will be archetyped, otherwise - false." *>
fn bool Entity.archetyping(&self) @inline => self.state & ElementState.ARCHETYPING != 0;

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
		if (entity.state & ElementState.ARCHETYPING == 0) {
			world.deferred.archetyping.push(entity);
			entity.state |= ElementState.ARCHETYPING;
		}

		return;
	}

	archetype_remove(entity);

	/* If entity has components or tags, bind archetype to it. */
	if (marker_is_any_set(MAX_COMPONENTS_COUNT, COMPONENTS_MARKER_SIZE, &entity.components) ||
		marker_is_any_set(MAX_TAGS_COUNT, TAGS_MARKER_SIZE, &entity.tags)) {
		/* Find appropriate archetype or new one. */
		Archetype* archetype = get_archetype(world, &entity.components, &entity.tags);

		entity.archetype = archetype;
		entity.arch_idx = archetype.entities.push(entity);
	}
}
