module mobee;

import std::io;

<* Adds up to 13 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* Entity.add(&self, ...) @safemacro {
	$switch $vaarg.len:
		$case 2:  return add_component(self, ...$vaarg);
		$case 4:  return add_2_components(self, ...$vaarg);
		$case 6:  return add_3_components(self, ...$vaarg);
		$case 8:  return add_4_components(self, ...$vaarg);
		$case 10: return add_5_components(self, ...$vaarg);
		$case 12: return add_6_components(self, ...$vaarg);
		$case 14: return add_7_components(self, ...$vaarg);
		$case 16: return add_8_components(self, ...$vaarg);
		$case 18: return add_9_components(self, ...$vaarg);
		$case 20: return add_10_components(self, ...$vaarg);
		$case 22: return add_11_components(self, ...$vaarg);
		$case 24: return add_12_components(self, ...$vaarg);
		$case 26: return add_13_components(self, ...$vaarg);
		$default: unreachable(ERR_WRONG_ARGS_COUNT);
	$endswitch

	return self;
}

<* Adds 2 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_2_components(Entity* entity, $Type1, #init1, $Type2, #init2) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 2) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 3 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_3_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = emtity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 3) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 4 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_4_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 4) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 5 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_5_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 5) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 6 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_6_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 6) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 7 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_7_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 7) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 8 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_8_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 8) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 9 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_9_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 9) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 10 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_10_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 10) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 11 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_11_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;
	$Type11 c11 = #init11;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 11) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id11) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c11, $Type11::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 12 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_12_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11, $Type12, #init12) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;
	$Type11 c11 = #init11;
	$Type12 c12 = #init12;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 12) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id11) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c11, $Type11::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id12) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c12, $Type12::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Adds 13 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* add_13_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11, $Type12, #init12, $Type13, #init13) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;
	$Type11 c11 = #init11;
	$Type12 c12 = #init12;
	$Type13 c13 = #init13;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 13) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id11) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c11, $Type11::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id12) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c12, $Type12::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		} else if (id == id13) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c13, $Type13::size);
			marker_set(COMPONENTS_MARKER_SIZE, &entity.components, i);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	archetyping(entity);

	return entity;
}

<* Sets up to 13 components values in the entity by their types and initializers. *>
macro Entity* Entity.set(&self, ...) @safemacro {
	$switch $vaarg.len:
		$case 2:  return set_component(self, ...$vaarg);
		$case 4:  return set_2_components(self, ...$vaarg);
		$case 6:  return set_3_components(self, ...$vaarg);
		$case 8:  return set_4_components(self, ...$vaarg);
		$case 10: return set_5_components(self, ...$vaarg);
		$case 12: return set_6_components(self, ...$vaarg);
		$case 14: return set_7_components(self, ...$vaarg);
		$case 16: return set_8_components(self, ...$vaarg);
		$case 18: return set_9_components(self, ...$vaarg);
		$case 20: return set_10_components(self, ...$vaarg);
		$case 22: return set_11_components(self, ...$vaarg);
		$case 24: return set_12_components(self, ...$vaarg);
		$case 26: return set_13_components(self, ...$vaarg);
		$default: unreachable(ERR_WRONG_ARGS_COUNT);
	$endswitch

	return self;
}

<* Sets 2 components values in the entity by their types and initializers. *>
macro Entity* set_2_components(Entity* entity, $Type1, #init1, $Type2, #init2) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 2) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 3 components values in the entity by their types and initializers. *>
macro Entity* set_3_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 3) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 4 components values in the entity by their types and initializers. *>
macro Entity* set_4_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 4) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 5 components values in the entity by their types and initializers. *>
macro Entity* set_5_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 5) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 6 components values in the entity by their types and initializers. *>
macro Entity* set_6_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 6) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 7 components values in the entity by their types and initializers. *>
macro Entity* set_7_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 7) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 8 components values in the entity by their types and initializers. *>
macro Entity* set_8_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 8) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 9 components values in the entity by their types and initializers. *>
macro Entity* set_9_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 9) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 10 components values in the entity by their types and initializers. *>
macro Entity* set_10_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 10) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 11 components values in the entity by their types and initializers. *>
macro Entity* set_11_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;
	$Type11 c11 = #init11;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 11) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
		} else if (id == id11) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c11, $Type11::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 12 components values in the entity by their types and initializers. *>
macro Entity* set_12_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11, $Type12, #init12) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;
	$Type11 c11 = #init11;
	$Type12 c12 = #init12;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 12) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
		} else if (id == id11) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c11, $Type11::size);
		} else if (id == id12) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c12, $Type12::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets 13 components values in the entity by their types and initializers. *>
macro Entity* set_13_components(Entity* entity, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11, $Type12, #init12, $Type13, #init13) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;

	$Type1 c1 = #init1;
	$Type2 c2 = #init2;
	$Type3 c3 = #init3;
	$Type4 c4 = #init4;
	$Type5 c5 = #init5;
	$Type6 c6 = #init6;
	$Type7 c7 = #init7;
	$Type8 c8 = #init8;
	$Type9 c9 = #init9;
	$Type10 c10 = #init10;
	$Type11 c11 = #init11;
	$Type12 c12 = #init12;
	$Type13 c13 = #init13;

	World* world = entity.block.world;
	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* chunk_ptr = entity.block.chunks + world.components.size * entity.chunk_idx;

	if (world.components.count != 13) {
		/* We need to read existing components values first to save values of ones
		   that are not being set in this method, but if total components count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all components values will be replaced by new ones. */
		mem::copy(&buffer[0], chunk_ptr, world.components.size);
	}

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c1, $Type1::size);
		} else if (id == id2) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c2, $Type2::size);
		} else if (id == id3) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c3, $Type3::size);
		} else if (id == id4) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c4, $Type4::size);
		} else if (id == id5) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c5, $Type5::size);
		} else if (id == id6) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c6, $Type6::size);
		} else if (id == id7) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c7, $Type7::size);
		} else if (id == id8) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c8, $Type8::size);
		} else if (id == id9) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c9, $Type9::size);
		} else if (id == id10) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c10, $Type10::size);
		} else if (id == id11) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c11, $Type11::size);
		} else if (id == id12) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c12, $Type12::size);
		} else if (id == id13) {
			char* ptr = &buffer[0] + offset;
			mem::copy(ptr, &c13, $Type13::size);
		}
	}

	mem::copy(chunk_ptr, &buffer[0], world.components.size);

	return entity;
}

<* Sets up to 13 resource values in the world by their types and initializers. *>
macro World* World.set(&self, ...) @safemacro {
	$switch $vaarg.len:
		$case 2:  return set_resource(self, ...$vaarg);
		$case 4:  return set_2_resources(self, ...$vaarg);
		$case 6:  return set_3_resources(self, ...$vaarg);
		$case 8:  return set_4_resources(self, ...$vaarg);
		$case 10: return set_5_resources(self, ...$vaarg);
		$case 12: return set_6_resources(self, ...$vaarg);
		$case 14: return set_7_resources(self, ...$vaarg);
		$case 16: return set_8_resources(self, ...$vaarg);
		$case 18: return set_9_resources(self, ...$vaarg);
		$case 20: return set_10_resources(self, ...$vaarg);
		$case 22: return set_11_resources(self, ...$vaarg);
		$case 24: return set_12_resources(self, ...$vaarg);
		$case 26: return set_13_resources(self, ...$vaarg);
		$default: unreachable(ERR_WRONG_ARGS_COUNT);
	$endswitch

	return self;
}

<* Sets 2 resource values in the world by their types and initializers. *>
macro World* set_2_resources(World* world, $Type1, #init1, $Type2, #init2) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 2) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 3 resource values in the world by their types and initializers. *>
macro World* set_3_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 3) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 4 resource values in the world by their types and initializers. *>
macro World* set_4_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 4) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 5 resource values in the world by their types and initializers. *>
macro World* set_5_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 5) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 6 resource values in the world by their types and initializers. *>
macro World* set_6_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 6) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 7 resource values in the world by their types and initializers. *>
macro World* set_7_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 7) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 8 resource values in the world by their types and initializers. *>
macro World* set_8_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;
	$Type8 r8 = #init8;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 8) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		} else if (id == id8) {
			mem::copy(&buffer[0] + offset, &r8, $Type8::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 9 resource values in the world by their types and initializers. *>
macro World* set_9_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;
	$Type8 r8 = #init8;
	$Type9 r9 = #init9;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 9) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		} else if (id == id8) {
			mem::copy(&buffer[0] + offset, &r8, $Type8::size);
		} else if (id == id9) {
			mem::copy(&buffer[0] + offset, &r9, $Type9::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 10 resource values in the world by their types and initializers. *>
macro World* set_10_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;
	$Type8 r8 = #init8;
	$Type9 r9 = #init9;
	$Type10 r10 = #init10;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 10) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		} else if (id == id8) {
			mem::copy(&buffer[0] + offset, &r8, $Type8::size);
		} else if (id == id9) {
			mem::copy(&buffer[0] + offset, &r9, $Type9::size);
		} else if (id == id10) {
			mem::copy(&buffer[0] + offset, &r10, $Type10::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 11 resource values in the world by their types and initializers. *>
macro World* set_11_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;
	$Type8 r8 = #init8;
	$Type9 r9 = #init9;
	$Type10 r10 = #init10;
	$Type11 r11 = #init11;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 11) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		} else if (id == id8) {
			mem::copy(&buffer[0] + offset, &r8, $Type8::size);
		} else if (id == id9) {
			mem::copy(&buffer[0] + offset, &r9, $Type9::size);
		} else if (id == id10) {
			mem::copy(&buffer[0] + offset, &r10, $Type10::size);
		} else if (id == id11) {
			mem::copy(&buffer[0] + offset, &r11, $Type11::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 12 resource values in the world by their types and initializers. *>
macro World* set_12_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11, $Type12, #init12) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;
	$Type8 r8 = #init8;
	$Type9 r9 = #init9;
	$Type10 r10 = #init10;
	$Type11 r11 = #init11;
	$Type12 r12 = #init12;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 12) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		} else if (id == id8) {
			mem::copy(&buffer[0] + offset, &r8, $Type8::size);
		} else if (id == id9) {
			mem::copy(&buffer[0] + offset, &r9, $Type9::size);
		} else if (id == id10) {
			mem::copy(&buffer[0] + offset, &r10, $Type10::size);
		} else if (id == id11) {
			mem::copy(&buffer[0] + offset, &r11, $Type11::size);
		} else if (id == id12) {
			mem::copy(&buffer[0] + offset, &r12, $Type12::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Sets 13 resource values in the world by their types and initializers. *>
macro World* set_13_resources(World* world, $Type1, #init1, $Type2, #init2, $Type3, #init3, $Type4, #init4,
	$Type5, #init5, $Type6, #init6, $Type7, #init7, $Type8, #init8, $Type9, #init9, $Type10, #init10,
	$Type11, #init11, $Type12, #init12, $Type13, #init13) @private @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;

	$Type1 r1 = #init1;
	$Type2 r2 = #init2;
	$Type3 r3 = #init3;
	$Type4 r4 = #init4;
	$Type5 r5 = #init5;
	$Type6 r6 = #init6;
	$Type7 r7 = #init7;
	$Type8 r8 = #init8;
	$Type9 r9 = #init9;
	$Type10 r10 = #init10;
	$Type11 r11 = #init11;
	$Type12 r12 = #init12;
	$Type13 r13 = #init13;

	char[STACK_BUFFER_SIZE] buffer @noinit;
	char* storage = world.resources.storage;

	if (world.resources.count != 13) {
		/* We need to read existing resource values first to save values of ones
		   that are not being set in this method, but if total resource count equals
		   number of proceeding types in this method we can omit reading for optimization
		   since all resource values will be replaced by new ones. */
		mem::copy(&buffer[0], storage, world.resources.size);
	}

	for (sz i = 0; i < world.resources.count; i++) {
		uptr id = world.resources.ids[i];
		sz offset = world.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&buffer[0] + offset, &r1, $Type1::size);
		} else if (id == id2) {
			mem::copy(&buffer[0] + offset, &r2, $Type2::size);
		} else if (id == id3) {
			mem::copy(&buffer[0] + offset, &r3, $Type3::size);
		} else if (id == id4) {
			mem::copy(&buffer[0] + offset, &r4, $Type4::size);
		} else if (id == id5) {
			mem::copy(&buffer[0] + offset, &r5, $Type5::size);
		} else if (id == id6) {
			mem::copy(&buffer[0] + offset, &r6, $Type6::size);
		} else if (id == id7) {
			mem::copy(&buffer[0] + offset, &r7, $Type7::size);
		} else if (id == id8) {
			mem::copy(&buffer[0] + offset, &r8, $Type8::size);
		} else if (id == id9) {
			mem::copy(&buffer[0] + offset, &r9, $Type9::size);
		} else if (id == id10) {
			mem::copy(&buffer[0] + offset, &r10, $Type10::size);
		} else if (id == id11) {
			mem::copy(&buffer[0] + offset, &r11, $Type11::size);
		} else if (id == id12) {
			mem::copy(&buffer[0] + offset, &r12, $Type12::size);
		} else if (id == id13) {
			mem::copy(&buffer[0] + offset, &r13, $Type13::size);
		}
	}

	mem::copy(storage, &buffer[0], world.resources.size);

	return world;
}

<* Gets 2 references to the 2 components values by their type. *>
macro Entity.get_mut_2(&self, $Type1, $Type2; @body(ptr1, ptr2)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2);
}

<* Gets 3 references to the 3 components values by their type. *>
macro Entity.get_mut_3(&self, $Type1, $Type2, $Type3; @body(ptr1, ptr2, ptr3)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3);
}

<* Gets 4 references to the 4 components values by their type. *>
macro Entity.get_mut_4(&self, $Type1, $Type2, $Type3, $Type4; @body(ptr1, ptr2, ptr3, ptr4)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4);
}

<* Gets 5 references to the 5 components values by their type. *>
macro Entity.get_mut_5(&self, $Type1, $Type2, $Type3, $Type4, $Type5; @body(ptr1, ptr2, ptr3, ptr4, ptr5)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5);
}

<* Gets 6 references to the 6 components values by their type. *>
macro Entity.get_mut_6(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6);
}

<* Gets 7 references to the 7 components values by their type. *>
macro Entity.get_mut_7(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7);
}

<* Gets 8 references to the 8 components values by their type. *>
macro Entity.get_mut_8(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	$Type8* c8 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c8 = ($Type8*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8);
}

<* Gets 9 references to the 9 components values by their type. *>
macro Entity.get_mut_9(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	$Type8* c8 = null;
	$Type9* c9 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c8 = ($Type8*)(chunk_ptr + offset);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c9 = ($Type9*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9);
}

<* Gets 10 references to the 10 components values by their type. *>
macro Entity.get_mut_10(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	$Type8* c8 = null;
	$Type9* c9 = null;
	$Type10* c10 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c8 = ($Type8*)(chunk_ptr + offset);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c9 = ($Type9*)(chunk_ptr + offset);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c10 = ($Type10*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10);
}

<* Gets 11 references to the 11 components values by their type. *>
macro Entity.get_mut_11(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10, ptr11)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	$Type8* c8 = null;
	$Type9* c9 = null;
	$Type10* c10 = null;
	$Type11* c11 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c8 = ($Type8*)(chunk_ptr + offset);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c9 = ($Type9*)(chunk_ptr + offset);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c10 = ($Type10*)(chunk_ptr + offset);
		} else if (id == id11 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c11 = ($Type11*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11);
}

<* Gets 12 references to the 12 components values by their type. *>
macro Entity.get_mut_12(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10, ptr11, ptr12)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	$Type8* c8 = null;
	$Type9* c9 = null;
	$Type10* c10 = null;
	$Type11* c11 = null;
	$Type12* c12 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c8 = ($Type8*)(chunk_ptr + offset);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c9 = ($Type9*)(chunk_ptr + offset);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c10 = ($Type10*)(chunk_ptr + offset);
		} else if (id == id11 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c11 = ($Type11*)(chunk_ptr + offset);
		} else if (id == id12 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c12 = ($Type12*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12);
}

<* Gets 13 references to the 13 components values by their type. *>
macro Entity.get_mut_13(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12, $Type13;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10, ptr11, ptr12, ptr13)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;
	
	$Type1* c1 = null;
	$Type2* c2 = null;
	$Type3* c3 = null;
	$Type4* c4 = null;
	$Type5* c5 = null;
	$Type6* c6 = null;
	$Type7* c7 = null;
	$Type8* c8 = null;
	$Type9* c9 = null;
	$Type10* c10 = null;
	$Type11* c11 = null;
	$Type12* c12 = null;
	$Type13* c13 = null;
	
	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;
		
		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c1 = ($Type1*)(chunk_ptr + offset);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c2 = ($Type2*)(chunk_ptr + offset);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c3 = ($Type3*)(chunk_ptr + offset);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c4 = ($Type4*)(chunk_ptr + offset);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c5 = ($Type5*)(chunk_ptr + offset);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c6 = ($Type6*)(chunk_ptr + offset);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c7 = ($Type7*)(chunk_ptr + offset);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c8 = ($Type8*)(chunk_ptr + offset);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c9 = ($Type9*)(chunk_ptr + offset);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c10 = ($Type10*)(chunk_ptr + offset);
		} else if (id == id11 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c11 = ($Type11*)(chunk_ptr + offset);
		} else if (id == id12 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c12 = ($Type12*)(chunk_ptr + offset);
		} else if (id == id13 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			c13 = ($Type13*)(chunk_ptr + offset);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13);
}

<* Gets 2 component values by their types. *>
macro Entity.get_2(&self, $Type1, $Type2; @body(value1, value2)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
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
macro Entity.get_3(&self, $Type1, $Type2, $Type3; @body(value1, value2, value3)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
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

<* Gets 4 component values by their types. *>
macro Entity.get_4(&self, $Type1, $Type2, $Type3, $Type4; @body(value1, value2, value3, value4)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		}
	}

	@body(c1, c2, c3, c4);
}

<* Gets 5 component values by their types. *>
macro Entity.get_5(&self, $Type1, $Type2, $Type3, $Type4, $Type5;
	@body(value1, value2, value3, value4, value5)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		}
	}

	@body(c1, c2, c3, c4, c5);
}

<* Gets 6 component values by their types. *>
macro Entity.get_6(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6;
	@body(value1, value2, value3, value4, value5, value6)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6);
}

<* Gets 7 component values by their types. *>
macro Entity.get_7(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7;
	@body(value1, value2, value3, value4, value5, value6, value7)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7);
}

<* Gets 8 component values by their types. *>
macro Entity.get_8(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8;
	@body(value1, value2, value3, value4, value5, value6, value7, value8)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;
	$Type8 c8 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c8, chunk_ptr + offset, $Type8::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8);
}

<* Gets 9 component values by their types. *>
macro Entity.get_9(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;
	$Type8 c8 @noinit;
	$Type9 c9 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c8, chunk_ptr + offset, $Type8::size);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c9, chunk_ptr + offset, $Type9::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9);
}

<* Gets 10 component values by their types. *>
macro Entity.get_10(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;
	$Type8 c8 @noinit;
	$Type9 c9 @noinit;
	$Type10 c10 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c8, chunk_ptr + offset, $Type8::size);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c9, chunk_ptr + offset, $Type9::size);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c10, chunk_ptr + offset, $Type10::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10);
}

<* Gets 11 component values by their types. *>
macro Entity.get_11(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;
	$Type8 c8 @noinit;
	$Type9 c9 @noinit;
	$Type10 c10 @noinit;
	$Type11 c11 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c8, chunk_ptr + offset, $Type8::size);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c9, chunk_ptr + offset, $Type9::size);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c10, chunk_ptr + offset, $Type10::size);
		} else if (id == id11 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c11, chunk_ptr + offset, $Type11::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11);
}

<* Gets 12 component values by their types. *>
macro Entity.get_12(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11,
	value12)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;
	$Type8 c8 @noinit;
	$Type9 c9 @noinit;
	$Type10 c10 @noinit;
	$Type11 c11 @noinit;
	$Type12 c12 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c8, chunk_ptr + offset, $Type8::size);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c9, chunk_ptr + offset, $Type9::size);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c10, chunk_ptr + offset, $Type10::size);
		} else if (id == id11 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c11, chunk_ptr + offset, $Type11::size);
		} else if (id == id12 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c12, chunk_ptr + offset, $Type12::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12);
}

<* Gets 13 component values by their types. *>
macro Entity.get_13(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12, $Type13;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11,
	value12, value13)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;

	$Type1 c1 @noinit;
	$Type2 c2 @noinit;
	$Type3 c3 @noinit;
	$Type4 c4 @noinit;
	$Type5 c5 @noinit;
	$Type6 c6 @noinit;
	$Type7 c7 @noinit;
	$Type8 c8 @noinit;
	$Type9 c9 @noinit;
	$Type10 c10 @noinit;
	$Type11 c11 @noinit;
	$Type12 c12 @noinit;
	$Type13 c13 @noinit;

	World* world = self.block.world;
	char* chunk_ptr = self.block.chunks + world.components.size * self.chunk_idx;

	for (sz i = 0; i < world.components.count; i++) {
		uptr id = world.components.ids[i];
		sz offset = world.components.types[i].offset;

		if (id == id1 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c1, chunk_ptr + offset, $Type1::size);
		} else if (id == id2 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c2, chunk_ptr + offset, $Type2::size);
		} else if (id == id3 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c3, chunk_ptr + offset, $Type3::size);
		} else if (id == id4 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c4, chunk_ptr + offset, $Type4::size);
		} else if (id == id5 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c5, chunk_ptr + offset, $Type5::size);
		} else if (id == id6 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c6, chunk_ptr + offset, $Type6::size);
		} else if (id == id7 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c7, chunk_ptr + offset, $Type7::size);
		} else if (id == id8 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c8, chunk_ptr + offset, $Type8::size);
		} else if (id == id9 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c9, chunk_ptr + offset, $Type9::size);
		} else if (id == id10 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c10, chunk_ptr + offset, $Type10::size);
		} else if (id == id11 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c11, chunk_ptr + offset, $Type11::size);
		} else if (id == id12 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c12, chunk_ptr + offset, $Type12::size);
		} else if (id == id13 && marker_is_set(COMPONENTS_MARKER_SIZE, &self.components, i)) {
			mem::copy(&c13, chunk_ptr + offset, $Type13::size);
		}
	}

	@body(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13);
}

<* Gets 2 references to 2 resource values by their types. *>
macro World.get_mut_2(&self, $Type1, $Type2; @body(ptr1, ptr2)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		}
	}

	@body(r1, r2);
}

<* Gets 3 references to 3 resource values by their types. *>
macro World.get_mut_3(&self, $Type1, $Type2, $Type3; @body(ptr1, ptr2, ptr3)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		}
	}

	@body(r1, r2, r3);
}

<* Gets 4 references to 4 resource values by their types. *>
macro World.get_mut_4(&self, $Type1, $Type2, $Type3, $Type4; @body(ptr1, ptr2, ptr3, ptr4)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4);
}

<* Gets 5 references to 5 resource values by their types. *>
macro World.get_mut_5(&self, $Type1, $Type2, $Type3, $Type4, $Type5;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5);
}

<* Gets 6 references to 6 resource values by their types. *>
macro World.get_mut_6(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6);
}

<* Gets 7 references to 7 resource values by their types. *>
macro World.get_mut_7(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7);
}

<* Gets 8 references to 8 resource values by their types. *>
macro World.get_mut_8(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	$Type8* r8 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		} else if (id == id8) {
			r8 = ($Type8*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8);
}

<* Gets 9 references to 9 resource values by their types. *>
macro World.get_mut_9(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	$Type8* r8 = null;
	$Type9* r9 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		} else if (id == id8) {
			r8 = ($Type8*)(storage + offset);
		} else if (id == id9) {
			r9 = ($Type9*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9);
}

<* Gets 10 references to 10 resource values by their types. *>
macro World.get_mut_10(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	$Type8* r8 = null;
	$Type9* r9 = null;
	$Type10* r10 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		} else if (id == id8) {
			r8 = ($Type8*)(storage + offset);
		} else if (id == id9) {
			r9 = ($Type9*)(storage + offset);
		} else if (id == id10) {
			r10 = ($Type10*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10);
}

<* Gets 11 references to 11 resource values by their types. *>
macro World.get_mut_11(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10, ptr11)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	$Type8* r8 = null;
	$Type9* r9 = null;
	$Type10* r10 = null;
	$Type11* r11 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		} else if (id == id8) {
			r8 = ($Type8*)(storage + offset);
		} else if (id == id9) {
			r9 = ($Type9*)(storage + offset);
		} else if (id == id10) {
			r10 = ($Type10*)(storage + offset);
		} else if (id == id11) {
			r11 = ($Type11*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11);
}

<* Gets 12 references to 12 resource values by their types. *>
macro World.get_mut_12(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10, ptr11, ptr12)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	$Type8* r8 = null;
	$Type9* r9 = null;
	$Type10* r10 = null;
	$Type11* r11 = null;
	$Type12* r12 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		} else if (id == id8) {
			r8 = ($Type8*)(storage + offset);
		} else if (id == id9) {
			r9 = ($Type9*)(storage + offset);
		} else if (id == id10) {
			r10 = ($Type10*)(storage + offset);
		} else if (id == id11) {
			r11 = ($Type11*)(storage + offset);
		} else if (id == id12) {
			r12 = ($Type12*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12);
}

<* Gets 13 references to 13 resource values by their types. *>
macro World.get_mut_13(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12, $Type13;
	@body(ptr1, ptr2, ptr3, ptr4, ptr5, ptr6, ptr7, ptr8, ptr9, ptr10, ptr11, ptr12, ptr13)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;
	
	$Type1* r1 = null;
	$Type2* r2 = null;
	$Type3* r3 = null;
	$Type4* r4 = null;
	$Type5* r5 = null;
	$Type6* r6 = null;
	$Type7* r7 = null;
	$Type8* r8 = null;
	$Type9* r9 = null;
	$Type10* r10 = null;
	$Type11* r11 = null;
	$Type12* r12 = null;
	$Type13* r13 = null;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			r1 = ($Type1*)(storage + offset);
		} else if (id == id2) {
			r2 = ($Type2*)(storage + offset);
		} else if (id == id3) {
			r3 = ($Type3*)(storage + offset);
		} else if (id == id4) {
			r4 = ($Type4*)(storage + offset);
		} else if (id == id5) {
			r5 = ($Type5*)(storage + offset);
		} else if (id == id6) {
			r6 = ($Type6*)(storage + offset);
		} else if (id == id7) {
			r7 = ($Type7*)(storage + offset);
		} else if (id == id8) {
			r8 = ($Type8*)(storage + offset);
		} else if (id == id9) {
			r9 = ($Type9*)(storage + offset);
		} else if (id == id10) {
			r10 = ($Type10*)(storage + offset);
		} else if (id == id11) {
			r11 = ($Type11*)(storage + offset);
		} else if (id == id12) {
			r12 = ($Type12*)(storage + offset);
		} else if (id == id13) {
			r13 = ($Type13*)(storage + offset);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13);
}

<* Gets 2 resource values by their types. *>
macro World.get_2(&self, $Type1, $Type2; @body(value1, value2)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		}
	}

	@body(r1, r2);
}

<* Gets 3 resource values by their types. *>
macro World.get_3(&self, $Type1, $Type2, $Type3; @body(value1, value2, value3)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		}
	}

	@body(r1, r2, r3);
}

<* Gets 4 resource values by their types. *>
macro World.get_4(&self, $Type1, $Type2, $Type3, $Type4; @body(value1, value2, value3, value4)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		}
	}

	@body(r1, r2, r3, r4);
}

<* Gets 5 resource values by their types. *>
macro World.get_5(&self, $Type1, $Type2, $Type3, $Type4, $Type5;
	@body(value1, value2, value3, value4, value5)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		}
	}

	@body(r1, r2, r3, r4, r5);
}

<* Gets 6 resource values by their types. *>
macro World.get_6(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6;
	@body(value1, value2, value3, value4, value5, value6)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6);
}

<* Gets 7 resource values by their types. *>
macro World.get_7(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7;
	@body(value1, value2, value3, value4, value5, value6, value7)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7);
}

<* Gets 8 resource values by their types. *>
macro World.get_8(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8;
	@body(value1, value2, value3, value4, value5, value6, value7, value8)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	$Type8 r8 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		} else if (id == id8) {
			mem::copy(&r8, storage + offset, $Type8::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8);
}

<* Gets 9 resource values by their types. *>
macro World.get_9(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	$Type8 r8 @noinit;
	$Type9 r9 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		} else if (id == id8) {
			mem::copy(&r8, storage + offset, $Type8::size);
		} else if (id == id9) {
			mem::copy(&r9, storage + offset, $Type9::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9);
}

<* Gets 10 resource values by their types. *>
macro World.get_10(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	$Type8 r8 @noinit;
	$Type9 r9 @noinit;
	$Type10 r10 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		} else if (id == id8) {
			mem::copy(&r8, storage + offset, $Type8::size);
		} else if (id == id9) {
			mem::copy(&r9, storage + offset, $Type9::size);
		} else if (id == id10) {
			mem::copy(&r10, storage + offset, $Type10::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10);
}

<* Gets 11 resource values by their types. *>
macro World.get_11(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	$Type8 r8 @noinit;
	$Type9 r9 @noinit;
	$Type10 r10 @noinit;
	$Type11 r11 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		} else if (id == id8) {
			mem::copy(&r8, storage + offset, $Type8::size);
		} else if (id == id9) {
			mem::copy(&r9, storage + offset, $Type9::size);
		} else if (id == id10) {
			mem::copy(&r10, storage + offset, $Type10::size);
		} else if (id == id11) {
			mem::copy(&r11, storage + offset, $Type11::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11);
}

<* Gets 12 resource values by their types. *>
macro World.get_12(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11,
	value12)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	$Type8 r8 @noinit;
	$Type9 r9 @noinit;
	$Type10 r10 @noinit;
	$Type11 r11 @noinit;
	$Type12 r12 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		} else if (id == id8) {
			mem::copy(&r8, storage + offset, $Type8::size);
		} else if (id == id9) {
			mem::copy(&r9, storage + offset, $Type9::size);
		} else if (id == id10) {
			mem::copy(&r10, storage + offset, $Type10::size);
		} else if (id == id11) {
			mem::copy(&r11, storage + offset, $Type11::size);
		} else if (id == id12) {
			mem::copy(&r12, storage + offset, $Type12::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12);
}

<* Gets 13 resource values by their types. *>
macro World.get_13(&self, $Type1, $Type2, $Type3, $Type4, $Type5, $Type6, $Type7, $Type8, $Type9, $Type10,
	$Type11, $Type12, $Type13;
	@body(value1, value2, value3, value4, value5, value6, value7, value8, value9, value10, value11,
	value12, value13)) @safemacro {
	uptr id1 = (uptr)$Type1::typeid;
	uptr id2 = (uptr)$Type2::typeid;
	uptr id3 = (uptr)$Type3::typeid;
	uptr id4 = (uptr)$Type4::typeid;
	uptr id5 = (uptr)$Type5::typeid;
	uptr id6 = (uptr)$Type6::typeid;
	uptr id7 = (uptr)$Type7::typeid;
	uptr id8 = (uptr)$Type8::typeid;
	uptr id9 = (uptr)$Type9::typeid;
	uptr id10 = (uptr)$Type10::typeid;
	uptr id11 = (uptr)$Type11::typeid;
	uptr id12 = (uptr)$Type12::typeid;
	uptr id13 = (uptr)$Type13::typeid;
	
	$Type1 r1 @noinit;
	$Type2 r2 @noinit;
	$Type3 r3 @noinit;
	$Type4 r4 @noinit;
	$Type5 r5 @noinit;
	$Type6 r6 @noinit;
	$Type7 r7 @noinit;
	$Type8 r8 @noinit;
	$Type9 r9 @noinit;
	$Type10 r10 @noinit;
	$Type11 r11 @noinit;
	$Type12 r12 @noinit;
	$Type13 r13 @noinit;
	
	char* storage = self.resources.storage;

	for (sz i = 0; i < self.resources.count; i++) {
		uptr id = self.resources.ids[i];
		sz offset = self.resources.types[i].offset;
		
		if (id == id1) {
			mem::copy(&r1, storage + offset, $Type1::size);
		} else if (id == id2) {
			mem::copy(&r2, storage + offset, $Type2::size);
		} else if (id == id3) {
			mem::copy(&r3, storage + offset, $Type3::size);
		} else if (id == id4) {
			mem::copy(&r4, storage + offset, $Type4::size);
		} else if (id == id5) {
			mem::copy(&r5, storage + offset, $Type5::size);
		} else if (id == id6) {
			mem::copy(&r6, storage + offset, $Type6::size);
		} else if (id == id7) {
			mem::copy(&r7, storage + offset, $Type7::size);
		} else if (id == id8) {
			mem::copy(&r8, storage + offset, $Type8::size);
		} else if (id == id9) {
			mem::copy(&r9, storage + offset, $Type9::size);
		} else if (id == id10) {
			mem::copy(&r10, storage + offset, $Type10::size);
		} else if (id == id11) {
			mem::copy(&r11, storage + offset, $Type11::size);
		} else if (id == id12) {
			mem::copy(&r12, storage + offset, $Type12::size);
		} else if (id == id13) {
			mem::copy(&r13, storage + offset, $Type13::size);
		}
	}

	@body(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13);
}

