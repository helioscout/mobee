module moecs;

<* Tag element type description. *>
struct Tag @private {
	<* Type id of the tag type. *>
	typeid type;
	<* Index of the tag in the bitset (entity's tags marker). *>
	usz idx;
}

struct Tags @private {
	<* Registered ids of tag types converted from typeids.
	   Index in this array will be index in the merker (bitset). *>
	uptr[MAX_TAGS_COUNT] ids;
	<* Instances of concrete tag type. *>
	Tag[MAX_TAGS_COUNT] types;
	<* Tag types count (last index + 1). *>
	usz count;
}

<* Gets index of tag type.
   @param tags : "Reference to tag types collection."
   @param type : "Tag type." *>
fn usz tag_index(Tags* tags, typeid type) @private @inline {
	uptr id = (uptr)type;

	for (usz i = 0; i < tags.count; i++) {
		if (tags.ids[i] == id) return i;
	}

	return usz.max;
}

<* Adds new tag type into collection.
   @param tags : "Reference to tag types collection."
   @param type : "Tag type."
   @param tag  : "Instance of the tag type." *>
fn void tags_add(Tags* tags, typeid type, Tag tag) @private {
	if (tags_has(tags, type)) abort("Tag already registered.");
	if (tags.count == MAX_TAGS_COUNT) abort("The maximum count of tags has been reached.");

	tags.ids[tags.count] = (uptr)type;
	tags.types[tags.count] = tag;

	tags.count++;
}

<* Gets reference to the tag type.
   @param tags : "Reference to tag types collection."
   @param type : "Tag type." *>
fn Tag* tags_get(Tags* tags, typeid type) @private @inline {
	usz idx = tag_index(tags, type);
	return idx != usz.max ? &tags.types[idx] : null;
}

<* Checks if the collection has specified tag type.
   @param tags : "Reference to tag types collection."
   @param type : "Tag type"
   @return       "True if type was found, otherwise - false." *>
fn bool tags_has(Tags* tags, typeid type) @private @inline {
	return tag_index(tags, type) != usz.max;
}
