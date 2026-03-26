module moecs;

<* Worlds list, growable collection of pointers to world.
   Capacity equals WORLDS_LIST_CHUNK_SIZE * WORLDS_LIST_MAX_CHUNKS_COUNT. *>
struct Worlds {
	<* Blocks of memory for storing pointers to worlds. *>
	char*[WORLDS_LIST_MAX_CHUNKS_COUNT] chunks;
	<* Current inserting index in the last chunk (last inserted index + 1).
	   If it equals chunk size than new chunk should be allocated. *>
	usz idx;
	<* Current working (last allocated if list was not cleared yet) chunk index.
	   When list was being cleared it will be set to 0. *>
	usz chunk_idx;
}

<* Initializes list, allocates first chunk. *>
fn void Worlds.init(&self) {
	self.chunks[0] = malloc($sizeof(World*) * WORLDS_LIST_CHUNK_SIZE);
}

<* Adds world to the list.
   @param world : "Pointer to the world."
   @return "Total index of inserted world in the list." *>
fn usz Worlds.push(&self, World* world) {
	/* Check if it is necessary to allocate new (switch to next) chunk (current one is full). */
	if (self.idx == WORLDS_LIST_CHUNK_SIZE) {
		/* Check if capacity allows to allocate new memory blocks. */
		if (self.chunk_idx == WORLDS_LIST_MAX_CHUNKS_COUNT - 1) abort("Worlds list capacity overflow.");
		/* Increment current chunk index. */
		self.chunk_idx++;
		/* Checks if the block was not already allocated (before list clearing). */
		if (self.chunks[self.chunk_idx] == null) {
			/* Allocate chunk memory block and store pointer to it. */
			self.chunks[self.chunk_idx] = malloc($sizeof(World*) * WORLDS_LIST_CHUNK_SIZE);
		}
		/* Reset current inserting index. */
		self.idx = 0;
	}

	/* Calculates pointer for writing and set it to new value. */
	World** ptr = (World**)(self.chunks[self.chunk_idx] + $sizeof(World*) * self.idx);
	*ptr = world;

	return self.chunk_idx * WORLDS_LIST_CHUNK_SIZE + self.idx++;	/* Increment inserting index. */
}

<* Pops the last list item.
   @return "Pointer to the world."
   @return? NO_MORE_ELEMENT : "The list is empty." *>
fn World*? Worlds.pop(&self) {
	/* Check if the list is empty. */
	if (self.idx == 0 && self.chunk_idx == 0) return NO_MORE_ELEMENT~;
	/* Decrement current index and calculates pointer to last item. */
	World** ptr = (World**)(self.chunks[self.chunk_idx] + $sizeof(World*) * (--self.idx));
	/* Check if current chunk becomes empty and go to previous one if it exists. */
	if (self.idx == 0 && self.chunk_idx > 0) {
		self.chunk_idx--;
		self.idx = WORLDS_LIST_CHUNK_SIZE;
	}

	return *ptr;
}

<* Unordered removes list item at specific index,
   swaps the last element to the removed location.
   @param idx : "List item index."
   @return "World's pointer that took the place of the deleted one."
   @return? OUT_OF_BOUNDS      : "Index is out of bounds."
   @return? NO_SWAPPED_ELEMENT : "It was last element, nothing to swap with." *>
fn World*? Worlds.remove(&self, usz idx) {
	usz len = self.len();
	/* Checks for correctness of passed index. */
	if (idx >= len) return OUT_OF_BOUNDS~;
	/* If the list has only one element. */
	if (len == 1) {
		self.idx = 0;
		return NO_SWAPPED_ELEMENT~;
	}

	World* swapped = self.pop()!!;

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
fn usz Worlds.len(&self) @operator(len) @inline {
	return self.chunk_idx * WORLDS_LIST_CHUNK_SIZE + self.idx;
}

<* Gets world's pointer.
   @param idx : "World's index in the list."
   @return "Pointer to the world." *>
fn World* Worlds.get(&self, usz idx) @operator([]) @inline {
	/* Calculates indexes. */
	usz chunk_idx = idx / WORLDS_LIST_CHUNK_SIZE;
	idx = idx % WORLDS_LIST_CHUNK_SIZE;
	/* Calculates pointer. */
	World** ptr = (World**)(self.chunks[chunk_idx] + $sizeof(World*) * idx);

	return *ptr;
}

<* Sets world's pointer (list value) at specified index.
   @param idx    : "List item index."
   @param world  : "Pointer to the world." *>
fn void Worlds.set(&self, usz idx, World* world) @operator([]=) @inline {
	/* Calculates indexes. */
	usz chunk_idx = idx / WORLDS_LIST_CHUNK_SIZE;
	idx = idx % WORLDS_LIST_CHUNK_SIZE;
	/* Calculates pointer for writing and set it to new value. */
	World** ptr = (World**)(self.chunks[chunk_idx] + $sizeof(World*) * idx);
	*ptr = world;
}

<* Set the length to be 0, while the capacity remains the same.
   All allocates chunks still in memory.*>
fn void Worlds.clear(&self) {
	self.chunk_idx = 0;
	self.idx = 0;
}

<* Frees all list memory. *>
fn void Worlds.free(&self) {
	foreach (char* ptr : self.chunks) {
		free(ptr);
	}
}
