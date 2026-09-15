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

<* Relate the entity with the target one using relation type and relationship data.
   Relation data will be overwritten if it was passed.
   It's safe to relate with same target entity several times.
   @param $Type  : "Relation type."
   @param target : "Pointer to relationship target entity."
   @param #init  : "Relation initialization block (relationship data)."
   @return         "Pointer to the entity." *>
macro Entity* Entity.relate(&self, $Type, Entity* target, #init = ...) @safemacro {
	if (self == target) return self;
	
	World* world = self.block.world;

	if (try Relation* r = relations_get(&world.relations, $Type::typeid)) {
		bool related = marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, r.idx);	/* Already related by Type */
		bool many    = marker_is_set(RELATIONS_MARKER_SIZE, &self.many, r.idx);			/* to many entities.       */
		char* chunk_ptr = self.block.chunks + world.chunk_size * self.chunk_idx;
		char* ptr_target = chunk_ptr + r.target_offset;
		$Type* ptr_relation = ($Type*)(chunk_ptr + r.offset);
		
		/* Store relation value in the chunk (or replace previous one if needed). */
		$if $defined(#init):
			/* If initialization block was passed by programmer, relation data whould always be replaced/set. */
			*ptr_relation = #init;
		$else
			/* Otherwise, - we initialize relation data by default value. */
			if (!related) *ptr_relation = {};
		$endif

		if (related) {
			/* If already related then target will be a pointer to a list of pointers to entities. */
			Entities** t = (Entities**)ptr_target;

			if (many) {
				/* If already has many targets then we just push into existing list,
				   if the target entity has not been added before. */
				if (!(*t).contains(target)) (*t).push(target);
			} else {
				Entity* existing = *((Entity**)ptr_target);
				/* If entity was related with current target before, we do nothing. */
				if (existing == target) return self;

				Entities* entities = alloc::new(&world.arena, Entities, {});
				entities.init(&world.arena);
				/* If already related to one entity we copy it's pointer and pointer to target entity
				   to newly created list and store a pointer to that list in the chunk. */
				entities.push_all({ existing, target });
				*t = entities;

				marker_set(RELATIONS_MARKER_SIZE, &self.many, r.idx);
			}
		} else {
			/* If had no relations before we store pointer to target entity in the chunk. */
			Entity** t = (Entity**)ptr_target;
			*t = target;

			marker_set(RELATIONS_MARKER_SIZE, &self.relations, r.idx);
			archetyping(self);
		}

		$switch $Type:
			$case ParentOf: if (!target.is_child_of(self))  relate_relative_of(target, self, child_of: true);
			$case ChildOf:  if (!target.is_parent_of(self)) relate_relative_of(target, self, parent_of: true);
		$endswitch

		if (r.idx != world.relations.idx_relation_of) relate_relative_of(target, self, relation_of: true);
	}
	
	return self;
}

<* We require this function to avoid relation macro recursion. *>
fn void relate_relative_of(Entity* entity, Entity* target,
	bool child_of = false, bool parent_of = false, bool relation_of = false) @private {
	World* world = entity.block.world;
	sz idx @noinit;

	switch {
		case child_of:    idx = world.relations.idx_child_of;
		case parent_of:   idx = world.relations.idx_parent_of;
		case relation_of: idx = world.relations.idx_relation_of;
	}
	
	sz target_offset = world.relations.types[idx].target_offset;
	sz offset = world.relations.types[idx].offset;

	bool related = marker_is_set(RELATIONS_MARKER_SIZE, &entity.relations, idx);
	bool many    = marker_is_set(RELATIONS_MARKER_SIZE, &entity.many, idx);
	char* chunk_ptr = entity.block.chunks + world.chunk_size * entity.chunk_idx;
	char* ptr_target = chunk_ptr + target_offset;

	/* Store default relation value in the chunk (will replace previous one). */
	switch {
		case child_of:
			ChildOf* ptr_relation = (ChildOf*)(chunk_ptr + offset);
			*ptr_relation = {};
		case parent_of:
			ParentOf* ptr_relation = (ParentOf*)(chunk_ptr + offset);
			*ptr_relation = {};
		case relation_of:
			RelationOf* ptr_relation = (RelationOf*)(chunk_ptr + offset);
			*ptr_relation = {};
	}

	if (related) {
		/* If already related then target will be a pointer to a list of pointers to entities. */
		Entities** t = (Entities**)ptr_target;

		if (many) {
			/* If already has many targets then we just push into existing list,
			   if the target entity has not been added before. */
			if (!(*t).contains(target)) (*t).push(target);
		} else {
			Entity* existing = *((Entity**)ptr_target);
			/* If entity was related with current target before, we do nothing. */
			if (existing == target) return;

			Entities* entities = alloc::new(&world.arena, Entities, {});
			entities.init(&world.arena);
			/* If already related to one entity we copy it's pointer and pointer to target entity
			   to newly created list and store a pointer to that list in the chunk. */
			entities.push_all({ existing, target });
			*t = entities;

			marker_set(RELATIONS_MARKER_SIZE, &entity.many, idx);
		}
	} else {
		/* If had no relations before we store pointer to target entity in the chunk. */
		Entity** t = (Entity**)ptr_target;
		*t = target;

		marker_set(RELATIONS_MARKER_SIZE, &entity.relations, idx);
		archetyping(entity);
	}

	if (!relation_of) relate_relative_of(target, entity, relation_of: true);
}

<* Set entity's ChildOf relation with any number of targets (parents).
   @param ...   : "One or more parent entities."
   @param #init : "Relation initialization block (relationship data)."
   @return        "Pointer to the entity." *>
macro Entity* Entity.child_of(&self, ..., #init = ...) @safemacro {
	$for var $i = 0; $i < $vaarg.len; $i++:
		$if $defined(#init):
			self.relate(ChildOf, $vaarg[$i], #init);
		$else
			self.relate(ChildOf, $vaarg[$i]);
		$endif
	$endfor

	return self;
}

<* Set entity's ParentOf relation with any number of targets (children).
   @param ...   : "One or more child entities."
   @param #init : "Relation initialization block (relationship data)."
   @return        "Pointer to the entity." *>
macro Entity* Entity.parent_of(&self, ..., #init = ...) @safemacro {
	$for var $i = 0; $i < $vaarg.len; $i++:
		$if $defined(#init):
			self.relate(ParentOf, $vaarg[$i], #init);
		$else
			self.relate(ParentOf, $vaarg[$i]);
		$endif
	$endfor
	
	return self;
}

<* Checks if the entity has ChildOf relation with (is a child of) all passed parent entities.
   @param ... : "Pointers to the parent entities."
   @return      "True if the entity is child of all parents, otherwise - false."*>
macro bool Entity.is_child_of(&self, ...) @safemacro {
	$switch:
		$case $vaarg.len == 0: return false;
		$case $vaarg.len == 1: return is_child_of_one(self, $vaarg[0]);
		$default:              return is_child_of_many(self, ...$vaarg);
	$endswitch
}

<* Checks if the entity has ChildOf relation with (is a child of) another one.
   @param entity : "Pointer to the (child) entity."
   @param parent : "Pointer to the parent entity."
   @return         "True if the entity is child of parent, otherwise - false."*>
fn bool is_child_of_one(Entity* entity, Entity* parent) @private {
	if (entity == parent) return false;

	World* world = entity.block.world;
	sz idx = world.relations.idx_child_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.relations, idx)) {
		char* ptr_target = entity.block.chunks + world.chunk_size * entity.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.many, idx)) {
			Entities** target = (Entities**)ptr_target;
			return (*target).contains(parent);
		} else {
			Entity** target = (Entity**)ptr_target;
			return *target == parent;
		}
	}

	return false;
}

<* Checks if the entity has ChildOf relation with (is a child of) all passed parent entities.
   @param entity  : "Pointer to the (child) entity."
   @param parents : "Pointers to the parent entities."
   @return          "True if the entity is child of all parents, otherwise - false."*>
fn bool is_child_of_many(Entity* entity, Entity*... parents) @private {
	World* world = entity.block.world;
	sz idx = world.relations.idx_child_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.relations, idx)) {
		char* ptr_target = entity.block.chunks + world.chunk_size * entity.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.many, idx)) {
			Entities** target = (Entities**)ptr_target;

			foreach (parent : parents) {
				if (!(*target).contains(parent)) return false;;
			}
		} else {
			Entity** target = (Entity**)ptr_target;

			/* This case exists only for checking if programmer passed a list of the same entity pointer. */
			foreach (parent : parents) {
				if (*target != parent) return false;
			}
		}

		return true;
	}

	return false;
}

<* Checks if the entity has ParentOf relation with (is a parent of) all passed child entities.
   @param ... : "Pointers to the child entities."
   @return      "True if the entity is parent of all children, otherwise - false."*>
macro bool Entity.is_parent_of(&self, ...) @safemacro {
	$switch:
		$case $vaarg.len == 0: return false;
		$case $vaarg.len == 1: return is_parent_of_one(self, $vaarg[0]);
		$default:              return is_parent_of_many(self, ...$vaarg);
	$endswitch
}

<* Checks if the entity has ParentOf relation with (is a parent of) another one.
   @param entity : "Pointer to the (parent) entity."
   @param child  : "Pointer to the child entity."
   @return         "True if the entity is parent of child, otherwise - false."*>
fn bool is_parent_of_one(Entity* entity, Entity* child) @private {
	if (entity == child) return false;

	World* world = entity.block.world;
	sz idx = world.relations.idx_parent_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.relations, idx)) {
		char* ptr_target = entity.block.chunks + world.chunk_size * entity.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.many, idx)) {
			Entities** target = (Entities**)ptr_target;
			return (*target).contains(child);
		} else {
			Entity** target = (Entity**)ptr_target;
			return *target == child;
		}
	}

	return false;
}

<* Checks if the entity has ParentOf relation with (is a parent of) all passed child entities.
   @param entity    : "Pointer to the (parent) entity."
   @param children  : "Pointers to the child entities."
   @return            "True if the entity is parent of all children, otherwise - false."*>
fn bool is_parent_of_many(Entity* entity, Entity*... children) @private {
	World* world = entity.block.world;
	sz idx = world.relations.idx_parent_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.relations, idx)) {
		char* ptr_target = entity.block.chunks + world.chunk_size * entity.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.many, idx)) {
			Entities** target = (Entities**)ptr_target;

			foreach (child : children) {
				if (!(*target).contains(child)) return false;
			}
		} else {
			Entity** target = (Entity**)ptr_target;

			/* This case exists only for checking if programmer passed a list of the same entity pointer. */
			foreach (child : children) {
				if (*target != child) return false;
			}
		}

		return true;
	}

	return false;
}

<* Checks if the entity has ChildOf relation to some other. *>
fn bool Entity.is_child(&self) {
	return marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, self.block.world.relations.idx_child_of);
}

<* Checks if the entity has ParentOf relation to some other. *>
fn bool Entity.is_parent(&self) {
	return marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, self.block.world.relations.idx_parent_of);
}

<* Checks if the entity has relation of specified type,
   and, if provided, with every of listed target entities.
   @param $Type   : "Relation type."
   @param targets : "Zero or more target entities."
   @return          "True if the entity has relations, otherwise - false." *>
macro bool Entity.related(&self, $Type, Entity*... targets) {
	World* world = self.block.world;

	if (try sz idx = relation_index(&world.relations, $Type::typeid)) {
		bool related = marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx);
		/* If we haven't to check targets, just return relation sign for entity. */
		if (targets.len == 0) return related;

		if (related) {
			char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
							 + world.relations.types[idx].target_offset;

			if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
				Entities** target = (Entities**)ptr_target;
				
				foreach (t : targets) {
					if (!(*target).contains(t)) return false;
				}

				return true;
			} else {
				Entity** target = (Entity**)ptr_target;

				/* This case exists only for checking if programmer passed a list of the same entity pointer. */
				foreach (t : targets) {
					if (*target != t) return false;
				}

				return true;
			}
		}
	}

	return false;
}

<* Checks if an entity has relationships with other entities (is their relations target).
   @return "True if entity has relationships, otherwise - false." *>
fn bool Entity.is_relation(&self) @inline {
	return marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, self.block.world.relations.idx_relation_of);
}

<* Checks if the entity has RelationOf relation (is it's relation target) with every listed ones.
   @param entities : "Pointers to the (related) entities."
   @return           "True if entity has relations, otherwise - false." *>
fn bool Entity.is_relation_of(&self, Entity*... entities) {
	World* world = self.block.world;
	sz idx = world.relations.idx_relation_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;
		
		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** target = (Entities**)ptr_target;
			
			foreach (entity : entities) {
				if (!(*target).contains(entity)) return false;
			}

			return true;
		} else {
			Entity** target = (Entity**)ptr_target;

			/* This case exists only for checking if programmer passed a list of the same entity pointer. */
			foreach (entity : entities) {
				if (*target != entity) return false;
			}

			return true;
		}
	}
	
	return false;
}

<* Removes all entity relations with all (or only listed, if passed) target entities by specified type.
   @param type    : "Relation type."
   @param targets : "Pointers to relationship target entities."
   @return          "Pointer to the entity." *>
fn Entity* Entity.unrelate(&self, typeid type, Entity*... targets) {
	World* world = self.block.world;

	if (try sz idx = relation_index(&world.relations, type) &&
	    marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		/* If entity has many relation target entities. */
		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** target = (Entities**)ptr_target;

			/* If unrelate with all target entities. */
			if (targets.len == 0) {
				@pool() {
					Entity*[] entities = (*target).to_tarray();

					(*target).clear();

					foreach (entity : entities) {
						unrelate_reverse(world, type, idx, self, entity);
					}
				};

				(*target).free();
				alloc::free(&world.arena, *target);

				marker_unset(RELATIONS_MARKER_SIZE, &self.many, idx);
				marker_unset(RELATIONS_MARKER_SIZE, &self.relations, idx);
				archetyping(self);
			/* Or unrelate with each of passed target entities. */
			} else {
				foreach (entity : targets) {
					if (try sz index = (*target).index_of(entity)) {
						(*target).remove_unordered_at(index);
						unrelate_reverse(world, type, idx, self, entity);
					}
				}

				/* How much target entities remain after unrelating. We need save this value
				   because the pointer to target can change in the first if statement. */
				sz remainder = (*target).len();

				/* If there is one entity left, we ned to set it as a target. */
				if (remainder == 1) {
					Entity** t = (Entity**)ptr_target;
					*t = (**target)[0];
				}

				/* If there is no necessity in the list, no many targets. */
				if (remainder <= 1) {
					(*target).free();
					alloc::free(&world.arena, *target);

					marker_unset(RELATIONS_MARKER_SIZE, &self.many, idx);
				}

				/* If there is no one related targets (so no relation) any more. */
				if (remainder == 0) {
					marker_unset(RELATIONS_MARKER_SIZE, &self.relations, idx);
					archetyping(self);
				}
			}
		/* If entity related with only one target entity. */
		} else {
			Entity** target = (Entity**)ptr_target;

			if (targets.len == 0 || array::contains(targets, *target)) {
				marker_unset(RELATIONS_MARKER_SIZE, &self.relations, idx);
				archetyping(self);

				unrelate_reverse(world, type, idx, self, *target);
			}
		}
	}

	return self;
}

<* Remove entity's reverese relations to target (dependency relations target -> entity).
   @param world  : "Pointer to the world."
   @param type   : "(Main) relation type."
   @param idx    : "(Main) relation index."
   @param entity : "Pointer to the entity (main relation owner)."
   @param target : "Pointer to the target entity (dependecy relations owner)." *>
fn void unrelate_reverse(World* world, typeid type, sz idx, Entity* entity, Entity* target) @private {
	switch (type) {
		case ParentOf: if (target.is_child_of(entity))  target.unrelate(ChildOf, entity);
		case ChildOf:  if (target.is_parent_of(entity)) target.unrelate(ParentOf, entity);
	}

	/* Only if there is no other relations with target entity we remove reverse relation (link). */
	if (idx != world.relations.idx_relation_of && target.relation_of_count(entity) == 0) {
		target.unrelate(RelationOf, entity);
	}
}

<* Count of dependencies on relationships with another entity,
   how much times entity appears as relation target for another entity.
   @param entity : "Pointer to the (related) entity."
   @return         "Count of dependencies." *>
fn sz Entity.relation_of_count(&self, Entity* entity) {
	if (self == entity) return 0;

	World* world = self.block.world;
	sz count = 0;

	for (sz idx = 0; idx < world.relations.count; idx++) {
		if (idx == world.relations.idx_relation_of) continue;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.relations, idx)) {
			char* ptr_target = entity.block.chunks + world.chunk_size * entity.chunk_idx
							 + world.relations.types[idx].target_offset;

			if (marker_is_set(RELATIONS_MARKER_SIZE, &entity.many, idx)) {
				Entities** target = (Entities**)ptr_target;
				if ((*target).contains(self)) count += 1;
			} else {
				Entity** target = (Entity**)ptr_target;
				if (*target == self) count += 1;
			}
		}
	}

	return count;
}

<* Gets pointer to the relation instance (relationship data) of specified type.
   @param $Type : "Relation type."
   @return        "Pointer to the relation instance."
   @return? NOT_FOUND : "Relation was not found." *>
macro void*? Entity.relation(&self, $Type) {
	World* world = self.block.world;

	if (try sz idx = relation_index(&world.relations, $Type::typeid) &&
		marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		return ($Type*)(self.block.chunks + world.chunk_size * self.chunk_idx + world.relations.types[idx].offset);
	}

	return NOT_FOUND~;
}

<* Gets entity relation target entity (one to one) of specified type.
   Even if a relation has many targets, only first will be returned.
   @param $Type : "Relation type."
   @return        "Pointer to the target entity."
   @return? NOT_FOUND : "Relation was not found." *>
macro Entity*? Entity.target(&self, $Type) {
	World* world = self.block.world;

	if (try sz idx = relation_index(&world.relations, $Type::typeid) &&
		marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** targets = (Entities**)ptr_target;
			return (**targets)[0];
		} else {
			Entity** target = (Entity**)ptr_target;
			return *target;
		}
	}

	return NOT_FOUND~;
}

<* Gets entity relation target entities (one to many) of specified type.
   Even if a relation has one target, it will be wrapped into a slice.
   If you didn't pass an alocator, you should call world.free(&targets)
   for returned slice if you want to save more memory.
   @param $Type     : "Relation type."
   @param allocator : "Allocator for an array, world.arena by default."
   @return            "Slice of the target entity pointers."
   @return? NOT_FOUND : "Relation was not found." *>
macro Entity*[]? Entity.targets(&self, $Type, Allocator allocator = null) {
	World* world = self.block.world;

	if (!allocator) allocator = &world.arena;

	if (try sz idx = relation_index(&world.relations, $Type::typeid) &&
		marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** t = (Entities**)ptr_target;
			return (*t).to_array(allocator);
		} else {
			Entity** t = (Entity**)ptr_target;
			Entity*[] targets = alloc::alloc_array(allocator, Entity*, 1);
			targets[0] = *t;

			return targets;
		}
	}

	return NOT_FOUND~;
}

<* Gets entity relationship data and targets (one to many) of specified type.
   Even if a relation has one target, it will be wrapped into slice.
   You should not to call world.free() in any case for macro results,
   but you must care by yourself about releasing memoty if you pass an allocator.
   @param $Type     : "Relation type."
   @param allocator : "Allocator for an array, world.arena by default."
   @param relation  : "Pointer to the relation value."
   @param targets   : "Slice of the target entity pointers." *>
macro Entity.relationship(&self, $Type, Allocator allocator = null; @body(relation, targets)) @safemacro {
	World* world = self.block.world;
	$Type* relation @noinit;
	Entity*[] targets @noinit;
	bool use_arena = !allocator;
	bool related = false;

	if (use_arena) allocator = &world.arena;

	if (try Relation* r = relations_get(&world.relations, $Type::typeid) &&
		marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, r.idx)) {
		char* chunk_ptr = self.block.chunks + world.chunk_size * self.chunk_idx;
		char* ptr_target = chunk_ptr + r.target_offset;
		relation = ($Type*)(chunk_ptr + r.offset);
		related = true;
		
		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, r.idx)) {
			Entities** t = (Entities**)ptr_target;
			targets = (*t).to_array(allocator);
		} else {
			Entity** t = (Entity**)ptr_target;
			targets = alloc::alloc_array(allocator, Entity*, 1);
			targets[0] = *t;
		}
	}
	
	@body(relation, targets);

	if (use_arena && related) alloc::free(allocator, targets.ptr);
}

<* Gets parent entity. If entity has many parents, only first will be returned.
   @return "Pointer to the parent entity."
   @return? NOT_FOUND : "Parent was not found." *>
fn Entity*? Entity.parent(&self) {
	World* world = self.block.world;
	sz idx = world.relations.idx_child_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** targets = (Entities**)ptr_target;
			return (**targets)[0];
		} else {
			Entity** target = (Entity**)ptr_target;
			return *target;
		}
	}

	return NOT_FOUND~;
}

<* Gets parent entities. If entity has one parent, it will be wrapped into slice.
   If you didn't pass an alocator, you should call world.free(&parents)
   for returned slice if you want to save more memory.
   @param allocator : "Allocator for an array, world.arena by default."
   @return            "Slice of the parent entity pointers."
   @return? NOT_FOUND : "Parents were not found." *>
macro Entity*[]? Entity.parents(&self, Allocator allocator = null) {
	World* world = self.block.world;
	sz idx = world.relations.idx_child_of;

	if (!allocator) allocator = &world.arena;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** t = (Entities**)ptr_target;
			return (*t).to_array(allocator);
		} else {
			Entity** t = (Entity**)ptr_target;
			Entity*[] targets = alloc::alloc_array(allocator, Entity*, 1);
			targets[0] = *t;

			return targets;
		}
	}

	return NOT_FOUND~;
}

<* Gets child entity. If entity has many children, only first will be returned.
   @return "Pointer to the child entity."
   @return? NOT_FOUND : "Child was not found." *>
fn Entity*? Entity.child(&self) {
	World* world = self.block.world;
	sz idx = world.relations.idx_parent_of;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** targets = (Entities**)ptr_target;
			return (**targets)[0];
		} else {
			Entity** target = (Entity**)ptr_target;
			return *target;
		}
	}

	return NOT_FOUND~;
}

<* Gets child entities. If entity has one child, it will be wrapped into slice.
   If you didn't pass an alocator, you should call world.free(&children)
   for returned slice if you want to save more memory.
   @param allocator : "Allocator for an array, world.arena by default."
   @return            "Slice of the child entity pointers."
   @return? NOT_FOUND : "Children were not found." *>
macro Entity*[]? Entity.children(&self, Allocator allocator = null) {
	World* world = self.block.world;
	sz idx = world.relations.idx_parent_of;

	if (!allocator) allocator = &world.arena;

	if (marker_is_set(RELATIONS_MARKER_SIZE, &self.relations, idx)) {
		char* ptr_target = self.block.chunks + world.chunk_size * self.chunk_idx
						 + world.relations.types[idx].target_offset;

		if (marker_is_set(RELATIONS_MARKER_SIZE, &self.many, idx)) {
			Entities** t = (Entities**)ptr_target;
			return (*t).to_array(allocator);
		} else {
			Entity** t = (Entity**)ptr_target;
			Entity*[] targets = alloc::alloc_array(allocator, Entity*, 1);
			targets[0] = *t;

			return targets;
		}
	}

	return NOT_FOUND~;
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
