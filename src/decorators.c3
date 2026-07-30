module mobee;

<* Gets 2 component values by their types. *>
macro Entity.@get_2(&self, $Type1, $Type2; @body(value1, value2)) {
	$Type1 c1 @noinit;
	$Type2 c2 @noinit;

	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;

	World* world    = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id   = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		}
	}

	@body(c1, c2);
}

<* Gets 2 references to the 2 components values by their type. *>
macro Entity.@get_2_mut(&self, $Type1, $Type2; @body(ptr1, ptr2)) {
	$Type1* c1 @noinit;
	$Type2* c2 @noinit;
	
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	
	World* world    = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id   = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2);
}

