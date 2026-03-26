module moecs;

<* Entities list, growable collection of pointers to entity.
   Capacity equals ENTITIES_LIST_CHUNK_SIZE * ENTITIES_LIST_MAX_CHUNKS_COUNT. *>
struct Entities {
	<* Blocks of memory for storing pointers to entities. *>
	char*[ENTITIES_LIST_MAX_CHUNKS_COUNT] chunks;
	<* Current inserting index in the last chunk (last inserted index + 1).
	   If it equals chunk size than new chunk should be allocated. *>
	usz idx;
	<* Current working (last allocated if list was not cleared yet) chunk index.
	   When list was being cleared it will be set to 0. *>
	usz chunk_idx;
}

<* Initializes list, allocates first chunk. *>
fn void Entities.init(&self) {
	self.chunks[0] = malloc($sizeof(Entity*) * ENTITIES_LIST_CHUNK_SIZE);
}

<* Adds entity to the list.
   @param entity : "Pointer to the entity."
   @return "Total index of inserted entity in the list." *>
fn usz Entities.push(&self, Entity* entity) {
	/* Check if it is necessary to allocate new (switch to next) chunk (current one is full). */
	if (self.idx == ENTITIES_LIST_CHUNK_SIZE) {
		/* Check if capacity allows to allocate new memory blocks. */
		if (self.chunk_idx == ENTITIES_LIST_MAX_CHUNKS_COUNT - 1) abort("Entities list capacity overflow.");
		/* Increment current chunk index. */
		self.chunk_idx++;
		/* Checks if the block was not already allocated (before list clearing). */
		if (self.chunks[self.chunk_idx] == null) {
			/* Allocate chunk memory block and store pointer to it. */
			self.chunks[self.chunk_idx] = malloc($sizeof(Entity*) * ENTITIES_LIST_CHUNK_SIZE);
		}
		/* Reset current inserting index. */
		self.idx = 0;
	}

	/* Calculates pointer for writing and set it to new value. */
	Entity** ptr = (Entity**)(self.chunks[self.chunk_idx] + $sizeof(Entity*) * self.idx);
	*ptr = entity;

	return self.chunk_idx * ENTITIES_LIST_CHUNK_SIZE + self.idx++;	/* Increment inserting index. */
}

<* Pops the last list item.
   @return "Pointer to the entity."
   @return? NO_MORE_ELEMENT : "The list is empty." *>
fn Entity*? Entities.pop(&self) {
	/* Check if the list is empty. */
	if (self.idx == 0 && self.chunk_idx == 0) return NO_MORE_ELEMENT~;
	/* Decrement current index and calculates pointer to last item. */
	Entity** ptr = (Entity**)(self.chunks[self.chunk_idx] + $sizeof(Entity*) * (--self.idx));
	/* Check if current chunk becomes empty and go to previous one if it exists. */
	if (self.idx == 0 && self.chunk_idx > 0) {
		self.chunk_idx--;
		self.idx = ENTITIES_LIST_CHUNK_SIZE;
	}

	return *ptr;
}

<* Unordered removes list item at specific index,
   swaps the last element to the removed location.
   @param idx : "List item index."
   @return "Entity's pointer that took the place of the deleted one."
   @return? OUT_OF_BOUNDS      : "Index is out of bounds."
   @return? NO_SWAPPED_ELEMENT : "It was last element, nothing to swap with." *>
fn Entity*? Entities.remove(&self, usz idx) {
	usz len = self.len();
	/* Checks for correctness of passed index. */
	if (idx >= len) return OUT_OF_BOUNDS~;
	/* If the list has only one element. */
	if (len == 1) {
		self.idx = 0;
		return NO_SWAPPED_ELEMENT~;
	}

	Entity* swapped = self.pop()!!;

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
fn usz Entities.len(&self) @operator(len) @inline {
	return self.chunk_idx * ENTITIES_LIST_CHUNK_SIZE + self.idx;
}

<* Gets entity's pointer.
   @param idx : "Entity's index in the list."
   @return "Pointer to the entity." *>
fn Entity* Entities.get(&self, usz idx) @operator([]) @inline {
	/* Calculates indexes. */
	usz chunk_idx = idx / ENTITIES_LIST_CHUNK_SIZE;
	idx = idx % ENTITIES_LIST_CHUNK_SIZE;
	/* Calculates pointer. */
	Entity** ptr = (Entity**)(self.chunks[chunk_idx] + $sizeof(Entity*) * idx);

	return *ptr;
}

<* Sets entity's pointer (list value) at specified index.
   @param idx    : "List item index."
   @param entity : "Pointer to the entity." *>
fn void Entities.set(&self, usz idx, Entity* entity) @operator([]=) @inline {
	/* Calculates indexes. */
	usz chunk_idx = idx / ENTITIES_LIST_CHUNK_SIZE;
	idx = idx % ENTITIES_LIST_CHUNK_SIZE;
	/* Calculates pointer for writing and set it to new value. */
	Entity** ptr = (Entity**)(self.chunks[chunk_idx] + $sizeof(Entity*) * idx);
	*ptr = entity;
}

<* Set the length to be 0, while the capacity remains the same.
   All allocates chunks still in memory.*>
fn void Entities.clear(&self) {
	self.chunk_idx = 0;
	self.idx = 0;
}

<* Frees all list memory. *>
fn void Entities.free(&self) {
	foreach (char* ptr : self.chunks) {
		free(ptr);
	}
}
