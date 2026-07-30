module mobee;

<* Blocks list, growable collection of pointers to block.
   Capacity equals BLOCKS_LIST_CHUNK_SIZE * BLOCKS_LIST_MAX_CHUNKS_COUNT. *>
struct Blocks {
	<* Blocks of memory for storing pointers to blocks. *>
	char*[BLOCKS_LIST_MAX_CHUNKS_COUNT] chunks;
	<* Current inserting index in the last chunk (last inserted index + 1).
	   If it equals chunk size than new chunk should be allocated. *>
	sz idx;
	<* Current working (last allocated if list was not cleared yet) chunk index.
	   When list was being cleared it will be set to 0. *>
	sz chunk_idx;
}

<* Initializes list, allocates first chunk. *>
fn void Blocks.init(&self) {
	self.chunks[0] = malloc(Block*::size * BLOCKS_LIST_CHUNK_SIZE);
}

<* Adds block to the list.
   @param block : "Pointer to the block."
   @return "Total index of inserted block in the list." *>
fn sz Blocks.push(&self, Block* block) {
	/* Check if it is necessary to allocate new (switch to next) chunk (current one is full). */
	if (self.idx == BLOCKS_LIST_CHUNK_SIZE) {
		/* Check if capacity allows to allocate new memory blocks. */
		if (self.chunk_idx == BLOCKS_LIST_MAX_CHUNKS_COUNT - 1) abort("Blocks list capacity overflow.");
		/* Increment current chunk index. */
		self.chunk_idx++;
		/* Checks if the block was not already allocated (before list clearing). */
		if (self.chunks[self.chunk_idx] == null) {
			/* Allocate chunk memory block and store pointer to it. */
			self.chunks[self.chunk_idx] = malloc(Block*::size * BLOCKS_LIST_CHUNK_SIZE);
		}
		/* Reset current inserting index. */
		self.idx = 0;
	}

	/* Calculates pointer for writing and set it to new value. */
	Block** ptr = (Block**)(self.chunks[self.chunk_idx] + Block*::size * self.idx);
	*ptr = block;

	return self.chunk_idx * BLOCKS_LIST_CHUNK_SIZE + self.idx++;	/* Increment inserting index. */
}

<* Pops the last list item.
   @return "Pointer to the block."
   @return? NO_MORE_ELEMENT : "The list is empty." *>
fn Block*? Blocks.pop(&self) {
	/* Check if the list is empty. */
	if (self.idx == 0 && self.chunk_idx == 0) return NO_MORE_ELEMENT~;
	/* Decrement current index and calculates pointer to last item. */
	Block** ptr = (Block**)(self.chunks[self.chunk_idx] + Block*::size * (--self.idx));
	/* Check if current chunk becomes empty and go to previous one if it exists. */
	if (self.idx == 0 && self.chunk_idx > 0) {
		self.chunk_idx--;
		self.idx = BLOCKS_LIST_CHUNK_SIZE;
	}

	return *ptr;
}

<* Unordered removes list item at specific index,
   swaps the last element to the removed location.
   @param idx : "List item index."
   @return "Block's pointer that took the place of the deleted one."
   @return? OUT_OF_BOUNDS      : "Index is out of bounds."
   @return? NO_SWAPPED_ELEMENT : "It was last element, nothing to swap with." *>
fn Block*? Blocks.remove(&self, sz idx) {
	sz len = self.len();
	/* Checks for correctness of passed index. */
	if (idx >= len) return OUT_OF_BOUNDS~;
	/* If the list has only one element. */
	if (len == 1) {
		self.idx = 0;
		return NO_SWAPPED_ELEMENT~;
	}

	Block* swapped = self.pop()!!;

	if (idx == len - 1) {
		/* It was last element in the list, no need to swap.
		   The item was already removed with pop() operation. */
		return NO_SWAPPED_ELEMENT~;
	} else {
		(*self)[idx] = swapped;
		return swapped;
	}
}

<* Gets the length of the list. *>
fn sz Blocks.len(&self) @operator(len) @inline {
	return self.chunk_idx * BLOCKS_LIST_CHUNK_SIZE + self.idx;
}

<* Gets block's pointer.
   @param idx : "Block's index in the list."
   @return "Pointer to the block." *>
fn Block* Blocks.get(&self, sz idx) @operator([]) @inline {
	/* Calculates indexes. */
	sz chunk_idx = idx / BLOCKS_LIST_CHUNK_SIZE;
	idx = idx % BLOCKS_LIST_CHUNK_SIZE;
	/* Calculates pointer. */
	Block** ptr = (Block**)(self.chunks[chunk_idx] + Block*::size * idx);

	return *ptr;
}

<* Sets block's pointer (list value) at specified index.
   @param idx    : "List item index."
   @param block  : "Pointer to the block." *>
fn void Blocks.set(&self, sz idx, Block* block) @operator([]=) @inline {
	/* Calculates indexes. */
	sz chunk_idx = idx / BLOCKS_LIST_CHUNK_SIZE;
	idx = idx % BLOCKS_LIST_CHUNK_SIZE;
	/* Calculates pointer for writing and set it to new value. */
	Block** ptr = (Block**)(self.chunks[chunk_idx] + Block*::size * idx);
	*ptr = block;
}

<* Set the length to be 0, while the capacity remains the same.
   All allocates chunks still in memory.*>
fn void Blocks.clear(&self) {
	self.chunk_idx = 0;
	self.idx = 0;
}

<* Frees all list memory. *>
fn void Blocks.free(&self) {
	foreach (char* ptr : self.chunks) {
		free(ptr);
	}
}
