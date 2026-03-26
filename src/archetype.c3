module moecs;

<* Archetype for components/tags configuration. *>
struct Archetype {
	<* Components marker, each set bit specifies that the component exists in the archetype. *>
	usz[COMPONENTS_MARKER_SIZE] components;
	<* Tags marker, each set bit specifies that the tag exists in the archetype. *>
	usz[TAGS_MARKER_SIZE] tags;
	<* Entities that belongs to the archetype. Each entity clould be included only into one archetype. *>
	Entities entities;
}

<* Initializes the archetype.
   @param archetype : "Pointer to the achetype." *>
fn void archetype_init(Archetype* archetype) @private @inline {
	archetype.entities.init();
}

<* Removes entity from archetype.
   @param entity : "Pointer to the entity." *>
fn void archetype_remove(Entity* entity) @private @inline {
	if (entity.archetype != null) {
		if (try Entity* swapped = entity.archetype.entities.remove(entity.arch_idx)) {
			/* We need to correct swapped (if it was) entity index in the archetype collection. */
			swapped.arch_idx = entity.arch_idx;
		}

		entity.archetype = null;
	}
}

<* Free all archetype resources.
   @param archetype : "Pointer to the achetype." *>
fn void free_archetype(Archetype* archetype) @private @inline {
	archetype.entities.free();
}
