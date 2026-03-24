module moecs;

import std::math;
import std::sort;

<* Resource element type description. *>
struct Resource @private {
	<* Type id of the resource type. *>
	typeid type;
	<* Index of the resource. *>
	usz idx;
	<* Type size for allocations. *>
	usz size;
	<* Type alignment for allocations. *>
	usz alignment;
	<* Resource offset (position) in the storage. *>
	usz offset;
}

struct Resources @private {
	<* Registered ids of resource types converted from typeids. *>
	uptr[MAX_RESOURCES_COUNT] ids;
	<* Instances of concrete resource type. *>
	Resource[MAX_RESOURCES_COUNT] types;
	<* Resource types count (last index + 1). *>
	usz count;
	<* Total size in bytes of all resources. *>
	usz size;
	<* Resources storage in the memory. *>
	char* storage;
}

<* Gets index of resource type.
   @param resources : "Reference to resource types collection."
   @param type      : "Resource type." *>
fn usz resource_index(Resources* resources, typeid type) @private @inline {
	uptr id = (uptr)type;

	for (usz i = 0; i < resources.count; i++) {
		if (resources.ids[i] == id) return i;
	}

	return usz.max;
}

<* Adds new resource type into collection.
   @param resources : "Reference to resource types collection."
   @param type      : "Resource type."
   @param resource  : "Instance of the resource type." *>
fn void resources_add(Resources* resources, typeid type, Resource resource) @private {
	if (resources_has(resources, type)) abort("Resource already registered.");
	if (resources.count == MAX_RESOURCES_COUNT) abort("The maximum count of resources has been reached.");

	resources.ids[resources.count] = (uptr)type;
	resources.types[resources.count] = resource;

	resources.count++;
}

<* Gets reference to the resource type.
   @param resources : "Reference to resource types collection."
   @param type      : "Resource type." *>
fn Resource* resources_get(Resources* resources, typeid type) @private @inline {
	usz idx = resource_index(resources, type);
	return idx != usz.max ? &resources.types[idx] : null;
}

<* Checks if the collection has specified resource type.
   @param resources : "Reference to resource types collection."
   @param type      : "Resource type."
   @return            "True if type was found, otherwise - false." *>
fn bool resources_has(Resources* resources, typeid type) @private @inline {
	return resource_index(resources, type) != usz.max;
}

<* Adjust resource types for efficient access, sort, calculate offsets.
   @param resources : "Reference to resource types collection." *>
fn void resources_adjust(Resources* resources) @private {
	Resource[] types = @clone_slice(resources.types[:resources.count]);

	quicksort(resources.ids[:resources.count]);

	foreach (resource : types) {
		usz idx = resource_index(resources, resource.type);
		resources.types[idx] = resource;
		resources.types[idx].idx = idx;
	}

	resources.types[0].offset = 0;

	usz offset = 0;
	usz chunk_align = 1;

	for (usz i = 0; i < resources.count; i++) {
		Resource* r = &resources.types[i];
		
		offset = mem::aligned_offset(offset, r.alignment);
		r.offset = offset;
		offset += r.size;
		chunk_align = max(chunk_align, r.alignment);
	}

	resources.size = mem::aligned_offset(offset, chunk_align);

	free(types);
}
