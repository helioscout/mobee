module mobee;

import std::io;

<* Adds up to 13 components to the entity by type and initializer.
   If entity already has a component it will be replaced by new one. *>
macro Entity* Entity.add(&self, ...) @safemacro {
	$switch $vaarg.len:
		$case 2: return self.add_component($vaarg[0], $vaarg[1]);
		$case 4: return add_2_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3]);
		$case 6: return add_3_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5]);
		$case 8: return add_4_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						$vaarg[6], $vaarg[7]);
		$case 10: return add_5_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9]);
		$case 12: return add_6_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11]);
		$case 14: return add_7_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13]);
		$case 16: return add_8_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15]);
		$case 18: return add_9_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17]);
		$case 20: return add_10_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19]);
		$case 22: return add_11_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19], $vaarg[20], $vaarg[21]);
		$case 24: return add_12_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19], $vaarg[20], $vaarg[21],
						 $vaarg[22], $vaarg[23]);
		$case 26: return add_13_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19], $vaarg[20], $vaarg[21],
						 $vaarg[22], $vaarg[23], $vaarg[24], $vaarg[25]);
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
		$case 2: return self.set_component($vaarg[0], $vaarg[1]);
		$case 4: return set_2_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3]);
		$case 6: return set_3_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5]);
		$case 8: return set_4_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						$vaarg[6], $vaarg[7]);
		$case 10: return set_5_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9]);
		$case 12: return set_6_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11]);
		$case 14: return set_7_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13]);
		$case 16: return set_8_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15]);
		$case 18: return set_9_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17]);
		$case 20: return set_10_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
						 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
						 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19]);
		// $case 22: return add_11_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
		// 				 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
		// 				 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19], $vaarg[20], $vaarg[21]);
		// $case 24: return add_12_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
		// 				 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
		// 				 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19], $vaarg[20], $vaarg[21],
		// 				 $vaarg[22], $vaarg[23]);
		// $case 26: return add_13_components(self, $vaarg[0], $vaarg[1], $vaarg[2], $vaarg[3], $vaarg[4], $vaarg[5],
		// 				 $vaarg[6], $vaarg[7], $vaarg[8], $vaarg[9], $vaarg[10], $vaarg[11], $vaarg[12], $vaarg[13],
		// 				 $vaarg[14], $vaarg[15], $vaarg[16], $vaarg[17], $vaarg[18], $vaarg[19], $vaarg[20], $vaarg[21],
		// 				 $vaarg[22], $vaarg[23], $vaarg[24], $vaarg[25]);
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

