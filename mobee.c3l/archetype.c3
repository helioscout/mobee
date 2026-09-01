module mobee;

<* Archetype for components/tags configuration. *>
struct Archetype {
	<* Components marker, each set bit specifies that the component exists in the archetype. *>
	sz[COMPONENTS_MARKER_SIZE] components;
	<* Tags marker, each set bit specifies that the tag exists in the archetype. *>
	sz[TAGS_MARKER_SIZE] tags;
	<* Entities that belongs to the archetype. Each entity clould be included only into one archetype. *>
	Entities entities;
}

<* Initializes the archetype.
   @param archetype : "Pointer to the achetype." *>
fn void archetype_init(Archetype* archetype) @private @inline {
	archetype.entities.init(mem, 0);
}

<* Removes entity from archetype.
   @param entity : "Pointer to the entity." *>
fn void archetype_remove(Entity* entity) @private @inline {
	if (entity.archetype != null) {
		entity.archetype.entities.remove_unordered_at(entity.arch_idx);
		/* We need to correct moved (if it was) entity index in the archetype collection. */
		if (entity.archetype.entities.len() > 0 && entity.arch_idx < entity.archetype.entities.len()) {
			/* Last entity moved to removed one's position and we update it's index to removed one. */
			entity.archetype.entities[entity.arch_idx].arch_idx = entity.arch_idx;
		}
		
		entity.archetype = null;
	}
}

<* Free all archetype resources.
   @param archetype : "Pointer to the achetype." *>
fn void free_archetype(Archetype* archetype) @private @inline {
	archetype.entities.free();
}
