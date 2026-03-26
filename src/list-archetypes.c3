module moecs;

<* Archetypes list, growable collection of pointers to archetype.
   Capacity equals ARCHETYPES_LIST_CHUNK_SIZE * ARCHETYPES_LIST_MAX_CHUNKS_COUNT. *>
struct Archetypes {
	<* Blocks of memory for storing pointers to archetypes. *>
	char*[ARCHETYPES_LIST_MAX_CHUNKS_COUNT] chunks;
	<* Current inserting index in the last chunk (last inserted index + 1).
	   If it equals chunk size than new chunk should be allocated. *>
	usz idx;
	<* Current working (last allocated if list was not cleared yet) chunk index.
	   When list was being cleared it will be set to 0. *>
	usz chunk_idx;
}

<* Initializes list, allocates first chunk. *>
fn void Archetypes.init(&self) {
	self.chunks[0] = malloc($sizeof(Archetype*) * ARCHETYPES_LIST_CHUNK_SIZE);
}

<* Adds archetype to the list.
   @param archetype : "Pointer to the archetype."
   @return "Total index of inserted archetype in the list." *>
fn usz Archetypes.push(&self, Archetype* archetype) {
	/* Check if it is necessary to allocate new (switch to next) chunk (current one is full). */
	if (self.idx == ARCHETYPES_LIST_CHUNK_SIZE) {
		/* Check if capacity allows to cllocate new memory blocks. */
		if (self.chunk_idx == ARCHETYPES_LIST_MAX_CHUNKS_COUNT - 1) abort("Archetypes list capacity overflow.");
		/* Increment current chunk index. */
		self.chunk_idx++;
		/* Checks if the block was not already allocated (before list clearing). */
		if (self.chunks[self.chunk_idx] == null) {
			/* Allocate chunk memory block and store pointer to it. */
			self.chunks[self.chunk_idx] = malloc($sizeof(Archetype*) * ARCHETYPES_LIST_CHUNK_SIZE);
		}
		/* Reset current inserting index. */
		self.idx = 0;
	}

	/* Calculates pointer for writing and set it to new value. */
	Archetype** ptr = (Archetype**)(self.chunks[self.chunk_idx] + $sizeof(Archetype*) * self.idx);
	*ptr = archetype;

	return self.chunk_idx * ARCHETYPES_LIST_CHUNK_SIZE + self.idx++;	/* Increment inserting index. */
}

<* Pops the last list item.
   @return "Pointer to the archetype."
   @return? NO_MORE_ELEMENT : "The list is empty." *>
fn Archetype*? Archetypes.pop(&self) {
	/* Check if the list is empty. */
	if (self.idx == 0 && self.chunk_idx == 0) return NO_MORE_ELEMENT~;
	/* Decrement current index and calculates pointer to last item. */
	Archetype** ptr = (Archetype**)(self.chunks[self.chunk_idx] + $sizeof(Archetype*) * (--self.idx));
	/* Check if current chunk becomes empty and go to previous one if it exists. */
	if (self.idx == 0 && self.chunk_idx > 0) {
		self.chunk_idx--;
		self.idx = ARCHETYPES_LIST_CHUNK_SIZE;
	}

	return *ptr;
}

<* Unordered removes list item at specific index,
   swaps the last element to the removed location.
   @param idx : "List item index."
   @return "Archetype's pointer that took the place of the deleted one."
   @return? OUT_OF_BOUNDS      : "Index is out of bounds."
   @return? NO_SWAPPED_ELEMENT : "It was last element, nothing to swap with." *>
fn Archetype*? Archetypes.remove(&self, usz idx) {
	usz len = self.len();
	/* Checks for correctness of passed index. */
	if (idx >= len) return OUT_OF_BOUNDS~;
	/* If the list has only one element. */
	if (len == 1) {
		self.idx = 0;
		return NO_SWAPPED_ELEMENT~;
	}

	Archetype* swapped = self.pop()!!;

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
fn usz Archetypes.len(&self) @operator(len) @inline {
	return self.chunk_idx * ARCHETYPES_LIST_CHUNK_SIZE + self.idx;
}

<* Gets archetype's pointer.
   @param idx : "Archetype's index in the list."
   @return "Pointer to the archetype." *>
fn Archetype* Archetypes.get(&self, usz idx) @operator([]) @inline {
	/* Calculates indexes. */
	usz chunk_idx = idx / ARCHETYPES_LIST_CHUNK_SIZE;
	idx = idx % ARCHETYPES_LIST_CHUNK_SIZE;
	/* Calculates pointer. */
	Archetype** ptr = (Archetype**)(self.chunks[chunk_idx] + $sizeof(Archetype*) * idx);

	return *ptr;
}

<* Sets archetype's pointer (list value) at specified index.
   @param idx       : "List item index."
   @param archetype : "Pointer to the archetype." *>
fn void Archetypes.set(&self, usz idx, Archetype* archetype) @operator([]=) @inline {
	/* Calculates indexes. */
	usz chunk_idx = idx / ARCHETYPES_LIST_CHUNK_SIZE;
	idx = idx % ARCHETYPES_LIST_CHUNK_SIZE;
	/* Calculates pointer for writing and set it to new value. */
	Archetype** ptr = (Archetype**)(self.chunks[chunk_idx] + $sizeof(Archetype*) * idx);
	*ptr = archetype;
}

<* Set the length to be 0, while the capacity remains the same.
   All allocates chunks still in memory.*>
fn void Archetypes.clear(&self) {
	self.chunk_idx = 0;
	self.idx = 0;
}

<* Frees all list memory. *>
fn void Archetypes.free(&self) {
	foreach (char* ptr : self.chunks) {
		free(ptr);
	}
}
