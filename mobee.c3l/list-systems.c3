module mobee;

<* Systems list, growable collection of pointers to system.
   Capacity equals SYSTEMS_LIST_CHUNK_SIZE * SYSTEMS_LIST_MAX_CHUNKS_COUNT. *>
struct Systems {
	<* Blocks of memory for storing pointers to systems. *>
	char*[SYSTEMS_LIST_MAX_CHUNKS_COUNT] chunks;
	<* Current inserting index in the last chunk (last inserted index + 1).
	   If it equals chunk size than new chunk should be allocated. *>
	sz idx;
	<* Current working (last allocated if list was not cleared yet) chunk index.
	   When list was being cleared it will be set to 0. *>
	sz chunk_idx;
}

<* Initializes list, allocates first chunk. *>
fn void Systems.init(&self) {
	self.chunks[0] = malloc(System*::size * SYSTEMS_LIST_CHUNK_SIZE);
}

<* Adds system to the list.
   @param system : "Pointer to the system."
   @return "Total index of inserted system in the list." *>
fn sz Systems.push(&self, System* system) {
	/* Check if it is necessary to allocate new (switch to next) chunk (current one is full). */
	if (self.idx == SYSTEMS_LIST_CHUNK_SIZE) {
		/* Check if capacity allows to allocate new memory blocks. */
		if (self.chunk_idx == SYSTEMS_LIST_MAX_CHUNKS_COUNT - 1) abort("Systems list capacity overflow.");
		/* Increment current chunk index. */
		self.chunk_idx++;
		/* Checks if the block was not already allocated (before list clearing). */
		if (self.chunks[self.chunk_idx] == null) {
			/* Allocate chunk memory block and store pointer to it. */
			self.chunks[self.chunk_idx] = malloc(Systems*::size * SYSTEMS_LIST_CHUNK_SIZE);
		}
		/* Reset current inserting index. */
		self.idx = 0;
	}

	/* Calculates pointer for writing and set it to new value. */
	System** ptr = (System**)(self.chunks[self.chunk_idx] + System*::size * self.idx);
	*ptr = system;

	return self.chunk_idx * SYSTEMS_LIST_CHUNK_SIZE + self.idx++;	/* Increment inserting index. */
}

<* Pops the last list item.
   @return "Pointer to the system."
   @return? NO_MORE_ELEMENT : "The list is empty." *>
fn System*? Systems.pop(&self) {
	/* Check if the list is empty. */
	if (self.idx == 0 && self.chunk_idx == 0) return NO_MORE_ELEMENT~;
	/* Decrement current index and calculates pointer to last item. */
	System** ptr = (System**)(self.chunks[self.chunk_idx] + System*::size * (--self.idx));
	/* Check if current chunk becomes empty and go to previous one if it exists. */
	if (self.idx == 0 && self.chunk_idx > 0) {
		self.chunk_idx--;
		self.idx = SYSTEMS_LIST_CHUNK_SIZE;
	}

	return *ptr;
}

<* Unordered removes list item at specific index,
   swaps the last element to the removed location.
   @param idx : "List item index."
   @return "System's pointer that took the place of the deleted one."
   @return? OUT_OF_BOUNDS      : "Index is out of bounds."
   @return? NO_SWAPPED_ELEMENT : "It was last element, nothing to swap with." *>
fn System*? Systems.remove(&self, sz idx) @maydiscard {
	sz len = self.len();
	/* Checks for correctness of passed index. */
	if (idx >= len) return OUT_OF_BOUNDS~;
	/* If the list has only one element. */
	if (len == 1) {
		self.idx = 0;
		return NO_SWAPPED_ELEMENT~;
	}

	System* swapped = self.pop()!!;

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
fn sz Systems.len(&self) @operator(len) @inline {
	return self.chunk_idx * SYSTEMS_LIST_CHUNK_SIZE + self.idx;
}

<* Gets system's pointer.
   @param idx : "System's index in the list."
   @return "Pointer to the system." *>
fn System* Systems.get(&self, sz idx) @operator([]) @inline {
	/* Calculates indexes. */
	sz chunk_idx = idx / SYSTEMS_LIST_CHUNK_SIZE;
	idx = idx % SYSTEMS_LIST_CHUNK_SIZE;
	/* Calculates pointer. */
	System** ptr = (System**)(self.chunks[chunk_idx] + System*::size * idx);

	return *ptr;
}

<* Sets system's pointer (list value) at specified index.
   @param idx    : "List item index."
   @param system : "Pointer to the system." *>
fn void Systems.set(&self, sz idx, System* system) @operator([]=) @inline {
	/* Calculates indexes. */
	sz chunk_idx = idx / SYSTEMS_LIST_CHUNK_SIZE;
	idx = idx % SYSTEMS_LIST_CHUNK_SIZE;
	/* Calculates pointer for writing and set it to new value. */
	System** ptr = (System**)(self.chunks[chunk_idx] + System*::size * idx);
	*ptr = system;
}

<* Set the length to be 0, while the capacity remains the same.
   All allocates chunks still in memory.*>
fn void Systems.clear(&self) {
	self.chunk_idx = 0;
	self.idx = 0;
}

<* Frees all list memory. *>
fn void Systems.free(&self) {
	foreach (char* ptr : self.chunks) {
		free(ptr);
	}
}
