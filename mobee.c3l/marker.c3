module mobee;

/* Bits enumeration starts from 0. */

<* Checks if all bits in the marker are set to 1.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)." *>
macro bool marker_is_all_set(sz $count, sz $size, void* marker) @private {
	sz[$size]* m = (sz[$size]*)marker;

	for (sz i = 0; i < $size - 1; i++) {
		if ((*m)[i] ^ sz::max != 0) return false;
	}

	sz remaining = $count == MARKER_BITS_COUNT
		? sz::max : sz::max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);
	
	return (*m)[$size - 1] & remaining == remaining;
}

<* Checks if all bits in the marker are set to 0.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)." *>
macro bool marker_is_all_unset(sz $count, sz $size, void* marker) @private {
	sz[$size]* m = (sz[$size]*)marker;

	for (sz i = 0; i < $size - 1; i++) {
		if ((*m)[i] > 0) return false;
	}

	sz remaining = $count == MARKER_BITS_COUNT
		? sz::max : sz::max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);

	return (*m)[$size - 1] & remaining == 0;
}

<* Checks if any of bits in the marker are set to 1.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)." *>
macro bool marker_is_any_set(sz $count, sz $size, void* marker) @private {
	sz[$size]* m = (sz[$size]*)marker;

	for (sz i = 0; i < $size - 1; i++) {
		if ((*m)[i] > 0) return true;
	}

	sz remaining = $count == MARKER_BITS_COUNT
		? sz::max : sz::max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);

	return (*m)[$size - 1] & remaining > 0;
}

<* Checks if all the bits of two markers are equal.
   @param $count  : "Whole marker bits count."
   @param $size   : "Markers (arrays) size."
   @param marker1 : "Pointer to first bitset (marker array)."
   @param marker2 : "Pointer to second bitset (marker array)." *>
macro bool marker_equals(sz $count, sz $size, void* marker1, void* marker2) @private {
	sz[$size]* m1 = (sz[$size]*)marker1;
	sz[$size]* m2 = (sz[$size]*)marker2;

	for (sz i = 0; i < $size - 1; i++) {
		if ((*m1)[i] != (*m2)[i]) return false;
	}

	sz remaining = $count == MARKER_BITS_COUNT
		? sz::max : sz::max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);

	return (*m1)[$size - 1] & remaining == (*m2)[$size - 1] & remaining;
}

<* Clones marker.
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)."
   @return         "New marker." *>
macro sz[*] marker_clone(sz $size, void* marker) @private {
	sz[$size]* m = (sz[$size]*)marker;
	sz[$size] clone @noinit;

	for (sz i = 0; i < $size; i++) {
		clone[i] = (*m)[i];
	}

	return clone;
}

<* Set all marker's bits to 0.
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)." *>
macro void marker_clear(sz $size, void* marker) @private {
	sz[$size]* m = (sz[$size]*)marker;

	for (sz i = 0; i < $size; i++) {
		(*m)[i] = 0;
	}
}

<* Checks if all bits of one marker (subset) included into other marker.
   @param $count : "Whole marker bits count."
   @param $size  : "Markers (arrays) size."
   @param marker : "Pointer to bitset that should include a subset."
   @param subset : "Pointer to bitset that should be included into marker." *>
macro bool marker_is_subset(sz $count, sz $size, void* marker, void* subset) @private {
	return marker_equals($count, $size, &&marker_and($size, marker, subset), subset);
}

<* Sets marker's bit to 1.
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)."
   @param idx    : "Bit index." *>
macro void marker_set(sz $size, void* marker, sz idx) @private {
	sz[$size]* m = (sz[$size]*)marker;
	(*m)[idx / MARKER_BITS_COUNT] |= (sz)1 << (idx % MARKER_BITS_COUNT);
}

<* Unsets marker's bit (set to 0).
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)."
   @param idx    : "Bit index." *>
macro void marker_unset(sz $size, void* marker, sz idx) @private {
	sz[$size]* m = (sz[$size]*)marker;
	(*m)[idx / MARKER_BITS_COUNT] &= ~((sz)1 << (idx % MARKER_BITS_COUNT));
}

<* Check if marker's bit at index idx is set to 1.
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)."
   @param idx    : "Bit index." *>
macro bool marker_is_set(sz $size, void* marker, sz idx) @private {
	sz[$size]* m = (sz[$size]*)marker;
	return (*m)[idx / MARKER_BITS_COUNT] & ((sz)1 << (idx % MARKER_BITS_COUNT)) != 0;
}

<* Sets all marker's bits to 1.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param marker : "Pointer to bitset (marker array)." *>
macro bool marker_set_all(sz $count, sz $size, void* marker) @private {
	sz[$size]* m = (sz[$size]*)marker;

	for (sz i = 0; i < $size - 1; i++) {
		(*m)[i] = sz::max;
	}

	(*m)[$size - 1] = $count == MARKER_BITS_COUNT
		? sz::max : sz::max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);
}

<* Perform bitwise AND over all bits of two markers.
   @param $size   : "Markers (arrays) size."
   @param marker1 : "Pointer to first bitset (marker array)."
   @param marker2 : "Pointer to second bitset (marker array)."
   @return          "New marker." *>
macro sz[*] marker_and(sz $size, void* marker1, void* marker2) @private {
	sz[$size]* m1 = (sz[$size]*)marker1;
	sz[$size]* m2 = (sz[$size]*)marker2;
	sz[$size] marker @noinit;

	for (sz i = 0; i < $size; i++) {
		marker[i] = (*m1)[i] & (*m2)[i];
	}
	
	return marker;
}

<* Perform bitwise OR over all bits of two markers.
   @param $size   : "Markers (arrays) size."
   @param marker1 : "Pointer to first bitset (marker array)."
   @param marker2 : "Pointer to second bitset (marker array)."
   @return          "New marker." *>
macro sz[*] marker_or(sz $size, void* marker1, void* marker2) @private {
	sz[$size]* m1 = (sz[$size]*)marker1;
	sz[$size]* m2 = (sz[$size]*)marker2;
	sz[$size] marker @noinit;

	for (sz i = 0; i < $size; i++) {
		marker[i] = (*m1)[i] | (*m2)[i];
	}
	
	return marker;
}

<* Perform bitwise XOR over all bits of two markers.
   @param $size   : "Markers (arrays) size."
   @param marker1 : "Pointer to first bitset (marker array)."
   @param marker2 : "Pointer to second bitset (marker array)."
   @return          "New marker." *>
macro sz[*] marker_xor(sz $size, void* marker1, void* marker2) @private {
	sz[$size]* m1 = (sz[$size]*)marker1;
	sz[$size]* m2 = (sz[$size]*)marker2;
	sz[$size] marker @noinit;

	for (sz i = 0; i < $size; i++) {
		marker[i] = (*m1)[i] ^ (*m2)[i];
	}
	
	return marker;
}
