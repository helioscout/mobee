module mobee;

import std::io;

<* Block type, building block of the world. *>
struct Block @private {
	<* Reference to the parent world. *>
	World* world;
	<* Block lifetime. *>
	Lifetime lifetime;
	<* Entities collection (chunk) for the block.
	   The index of the entity corresponds to the index of its components in each chunk. *>
	char* entities;
	<* Component chunks collection for the block.
	   Chunk is represented as a block in memory with sequentially recorded component's values.
	   The order (offset of each component) is defined in Components collection.
	   A pointer to allocated memory block. *>
	char* chunks;
	<* Deleted (freed) rows in the dynamic lifetime block. *>
	Indexes deleted;
	<* Current inserting index in the block (last inserted index + 1).
	   If it equals chunk size than new block should be inserted to the world. *>
	sz idx;
	<* Block chunk size dependent on lifetime. *>
	sz size;
}

<* Initializes the block.
   @param block : "Reference to the block." *>
fn void block_init(Block* block) @private {
	block.entities = mem::malloc_aligned(Entity::size * block.size, Entity::alignment);
	block.chunks = malloc(block.world.components.size * block.size);
}

<* Checks for existence of free rows (places to insert new entities/components).
   @param block : "Reference to the block." *>
fn bool block_has_free_rows(Block* block) @private @inline {
	switch (block.lifetime) {
		case DYNAMIC: return block.idx < DYNAMIC_CHUNK_SIZE || block.deleted.size > 0;
		case STATIC:  return block.idx < STATIC_CHUNK_SIZE;
	}

	return false;
}

<* Checks if all rows in the block are filled in.
   @param block : "Reference to the block." *>
fn bool block_is_full(Block* block) @private @inline {
	switch (block.lifetime) {
		case DYNAMIC: return block.idx == DYNAMIC_CHUNK_SIZE && block.deleted.size == 0;
		case STATIC:  return block.idx == STATIC_CHUNK_SIZE;
	}

	return false;
}

<* Checks that no one row in the block are filled in, it's totally free.
   @param block : "Reference to the block." *>
fn bool block_is_free(Block* block) @private @inline {
	switch (block.lifetime) {
		case DYNAMIC: return block.idx == 0 || block.deleted.size == block.idx;
		case STATIC:  return block.idx == 0;
	}

	return false;
}

<* Inserts entity into the block.
   @param block : "Reference to the block."
   @return "Pointer to inserted entity." *>
fn Entity* block_insert(Block* block) @private {
	sz idx = block_pop_free_index(block);

	Entity* entity = (Entity*)block.entities + idx;
	*entity = { .block = block, .chunk_idx = idx };
	
	return entity;
}

<* Deletes entity from the block.
   @param block : "Reference to the block."
   @param idx   : "Entity index." *>
fn void block_delete(Block* block, sz idx) @private @inline {
	switch (block.lifetime) {
		case DYNAMIC: block.deleted.push(idx);
		case STATIC:  abort("Static entities can't be deleted.");
	}
}

<* Creates iterator of entities.
   @return "Entities iterator." *>
fn EntitiesIterator block_iter() @private @inline => { .entity = null };

<* Iterate to the next alive (not deleted) entity in the block.
   @param block : "Reference to the block."
   @param iter  : "Entities iterator."
   @return        "True if next entity found, otherwise - false." *>
fn bool block_next(Block* block, EntitiesIterator* iter) @private {
	/* Start from next possible entity index. */
	sz idx = iter.entity == null ? 0 : iter.idx + 1;

	while (idx < block.idx) {
		if (block.lifetime == DYNAMIC && block.deleted.contains(idx)) {
			idx++;
		} else {
			iter.entity = (Entity*)block.entities + idx;
			iter.idx = idx;

			return true;
		}
	}

	return false;
}

<* Returns index of the first free to insert (last deleted) row in the block.
   @param block : "Reference to the block."
   @return "Index of the row to insert." *>
fn sz block_pop_free_index(Block* block) @local @inline {
	sz idx @noinit;
	
	switch (block.lifetime) {
		case DYNAMIC: idx = block.deleted.is_empty() ? block.idx++ : block.deleted.pop()!!;
		case STATIC: idx = block.idx++;
	}

	return idx;
}

<* Free all block resources.
   @param block : "Reference to the block." *>
fn void free_block(Block* block) @private {
	mem::free_aligned(block.entities);
	free(block.chunks);
}
