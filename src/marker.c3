module moecs;

/* Bits enumeration starts from 0. */

<* Checks if all bits in the marker are set to 1.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)." *>
macro bool marker_is_all_set(usz $count, usz $size, void* _marker) @private {
	usz[$size]* marker = (usz[$size]*)_marker;

	for (usz i = 0; i < $size - 1; i++) {
		if ((*marker)[i] ^ usz.max != 0) return false;
	}

	usz remaining = $count == MARKER_BITS_COUNT
		? usz.max : usz.max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);
	
	return (*marker)[$size - 1] & remaining == remaining;
}

<* Checks if all bits in the marker are set to 0.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)." *>
macro bool marker_is_all_unset(usz $count, usz $size, void* _marker) @private {
	usz[$size]* marker = (usz[$size]*)_marker;

	for (usz i = 0; i < $size - 1; i++) {
		if ((*marker)[i] > 0) return false;
	}

	usz remaining = $count == MARKER_BITS_COUNT
		? usz.max : usz.max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);

	return (*marker)[$size - 1] & remaining == 0;
}

<* Checks if any of bits in the marker are set to 1.
   @param $count : "Whole marker bits count."
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)." *>
macro bool marker_is_any_set(usz $count, usz $size, void* _marker) @private {
	usz[$size]* marker = (usz[$size]*)_marker;

	for (usz i = 0; i < $size - 1; i++) {
		if ((*marker)[i] > 0) return true;
	}

	usz remaining = $count == MARKER_BITS_COUNT
		? usz.max : usz.max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);

	return (*marker)[$size - 1] & remaining > 0;
}

<* Checks if all the bits of two markers are equal.
   @param $count  : "Whole marker bits count."
   @param $size   : "Markers (arrays) size."
   @param _marker1 : "Pointer to first bitset (marker array)."
   @param _marker2 : "Pointer to second bitset (marker array)." *>
macro bool marker_equals(usz $count, usz $size, void* _marker1, void* _marker2) @private {
	usz[$size]* marker1 = (usz[$size]*)_marker1;
	usz[$size]* marker2 = (usz[$size]*)_marker2;

	for (usz i = 0; i < $size - 1; i++) {
		if ((*marker1)[i] != (*marker2)[i]) return false;
	}

	usz remaining = $count == MARKER_BITS_COUNT
		? usz.max : usz.max >> (MARKER_BITS_COUNT - $count % MARKER_BITS_COUNT);

	return (*marker1)[$size - 1] & remaining == (*marker2)[$size - 1] & remaining;
}

<* Clones marker.
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)."
   @return         "New marker." *>
macro usz[*] marker_clone(usz $size, void* _marker) @private {
	usz[$size]* marker = (usz[$size]*)_marker;
	usz[$size] clone @noinit;

	for (usz i = 0; i < $size; i++) {
		clone[i] = (*marker)[i];
	}

	return clone;
}

<* Set all marker's bits to 0.
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)." *>
macro void marker_clear(usz $size, void* _marker) @private {
	usz[$size]* marker = (usz[$size]*)_marker;

	for (usz i = 0; i < $size; i++) {
		(*marker)[i] = 0;
	}
}

<* Checks if all bits of one marker (subset) included into other marker.
   @param $count : "Whole marker bits count."
   @param $size  : "Markers (arrays) size."
   @param marker : "Pointer to bitset that should include a subset."
   @param subset : "Pointer to bitset that should be included into marker." *>
macro bool marker_is_subset(usz $count, usz $size, void* marker, void* subset) @private {
	return marker_equals($count, $size, &&marker_and($size, marker, subset), subset);
}

<* Sets marker's bit to 1.
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)."
   @param idx    : "Bit index." *>
macro void marker_set(usz $size, void* _marker, usz idx) @private {
	usz[$size]* marker = (usz[$size]*)_marker;
	(*marker)[idx / MARKER_BITS_COUNT] |= (usz)1 << (idx % MARKER_BITS_COUNT);
}

<* Unsets marker's bit (set to 0).
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)."
   @param idx    : "Bit index." *>
macro void marker_unset(usz $size, void* _marker, usz idx) @private {
	usz[$size]* marker = (usz[$size]*)_marker;
	(*marker)[idx / MARKER_BITS_COUNT] &= ~((usz)1 << (idx % MARKER_BITS_COUNT));
}

<* Check if marker's bit at index idx is set to 1.
   @param $size  : "Marker (array) size."
   @param _marker : "Pointer to bitset (marker array)."
   @param idx    : "Bit index." *>
macro bool marker_is_set(usz $size, void* _marker, usz idx) @private {
	usz[$size]* marker = (usz[$size]*)_marker;
	return (*marker)[idx / MARKER_BITS_COUNT] & ((usz)1 << (idx % MARKER_BITS_COUNT)) != 0;
}

<* Perform bitwise AND over all bits of two markers.
   @param $size   : "Markers (arrays) size."
   @param _marker1 : "Pointer to first bitset (marker array)."
   @param _marker2 : "Pointer to second bitset (marker array)."
   @return          "New marker." *>
macro usz[*] marker_and(usz $size, void* _marker1, void* _marker2) @private {
	usz[$size]* marker1 = (usz[$size]*)_marker1;
	usz[$size]* marker2 = (usz[$size]*)_marker2;
	usz[$size] marker @noinit;

	for (usz i = 0; i < $size; i++) {
		marker[i] = (*marker1)[i] & (*marker2)[i];
	}
	
	return marker;
}

<* Perform bitwise OR over all bits of two markers.
   @param $size   : "Markers (arrays) size."
   @param _marker1 : "Pointer to first bitset (marker array)."
   @param _marker2 : "Pointer to second bitset (marker array)."
   @return          "New marker." *>
macro usz[*] marker_or(usz $size, void* _marker1, void* _marker2) @private {
	usz[$size]* marker1 = (usz[$size]*)_marker1;
	usz[$size]* marker2 = (usz[$size]*)_marker2;
	usz[$size] marker @noinit;

	for (usz i = 0; i < $size; i++) {
		marker[i] = (*marker1)[i] | (*marker2)[i];
	}
	
	return marker;
}

<* Perform bitwise XOR over all bits of two markers.
   @param $size   : "Markers (arrays) size."
   @param _marker1 : "Pointer to first bitset (marker array)."
   @param _marker2 : "Pointer to second bitset (marker array)."
   @return          "New marker." *>
macro usz[*] marker_xor(usz $size, void* _marker1, void* _marker2) @private {
	usz[$size]* marker1 = (usz[$size]*)_marker1;
	usz[$size]* marker2 = (usz[$size]*)_marker2;
	usz[$size] marker @noinit;

	for (usz i = 0; i < $size; i++) {
		marker[i] = (*marker1)[i] ^ (*marker2)[i];
	}
	
	return marker;
}
