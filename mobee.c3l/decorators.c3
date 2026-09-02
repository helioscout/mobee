module mobee;

import std::io;

<* Adds 2 components to the entity by type and instance (initializer).
   If entity already has a component it will be replaced by new one. *>
macro Entity.@add_2_components(&self, $Type1, #init1, $Type2, #init2) {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;

	World* world    = self.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	if (world.components.count != 2) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id   = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &self.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &self.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(self);

	return self;
}

<* Gets 2 component values by their types. *>
macro Entity.@get_2_components(&self, $Type1, $Type2; @body(value1, value2)) {
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

<* Gets 3 component values by their types. *>
macro Entity.@get_3_components(&self, $Type1, $Type2, $Type3; @body(value1, value2, value3)) {
	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;

	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;

	World* world    = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id   = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		}
	}

	@body(c1, c2, c3);
}

<* Gets 2 references to the 2 components values by their type. *>
macro Entity.@get_2_components_mut(&self, $Type1, $Type2; @body(ptr1, ptr2)) {
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

