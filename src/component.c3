module moecs;

import std::math;
import std::sort;

<* Component elment type description. *>
struct Component @private {
	<* Type id of the component type. *>
	typeid type;
	<* Index of the component in the bitset (entity's components marker). *>
	usz idx;
	<* Type size for allocations. *>
	usz size;
	<* Type alignment for allocations. *>
	usz alignment;
	<* Component offset (position) in the storage. *>
	usz offset;
}

<* Registered component types collection for each world. *>
struct Components @private {
	<* Registered ids of component types converted from typeids.
	   Index in this array will be index in the merker (bitset)
	   and the index of component's chunk in the block. *>
	uptr[MAX_COMPONENTS_COUNT] ids;
	<* Instances of concrete component type. *>
	Component[MAX_COMPONENTS_COUNT] types;
	<* Component types count (last index + 1). *>
	usz count;
	<* Total size in bytes of all components. *>
	usz size;
}

<* Gets index of component type.
   @param components : "Reference to component types collection."
   @param type       : "Component type." *>
fn usz component_index(Components* components, typeid type) @private @inline {
	uptr id = (uptr)type;

	for (usz i = 0; i < components.count; i++) {
		if (components.ids[i] == id) return i;
	}

	return usz.max;
}

<* Adds new component type into collection.
   @param components : "Reference to component types collection."
   @param type       : "Component type."
   @param component  : "Instance of the component type." *>
fn void components_add(Components* components, typeid type, Component component) @private {
	if (components_has(components, type)) abort("Component already registered.");
	if (components.count == MAX_COMPONENTS_COUNT) abort("The maximum count of components has been reached.");

	components.ids[components.count] = (uptr)type;
	components.types[components.count] = component;

	components.count++;
}

<* Gets reference to the component type.
   @param components : "Reference to component types collection."
   @param type       : "Component type." *>
fn Component* components_get(Components* components, typeid type) @private @inline {
	usz idx = component_index(components, type);
	return idx != usz.max ? &components.types[idx] : null;
}

<* Checks if the collection has specified component type.
   @param components : "Reference to component types collection."
   @param type       : "Component type."
   @return             "True if type was found, otherwise - false." *>
fn bool components_has(Components* components, typeid type) @private @inline {
	return component_index(components, type) != usz.max;
}

<* Adjust component types for efficient access, sort, calculate offsets.
   @param components : "Reference to component types collection." *>
fn void components_adjust(Components* components) @private {
	Component[] types = @clone_slice(components.types[:components.count]);

	quicksort(components.ids[:components.count]);

	foreach (component : types) {
		usz idx = component_index(components, component.type);
		components.types[idx] = component;
		components.types[idx].idx = idx;
	}

	components.types[0].offset = 0;

	usz offset = 0;
	usz chunk_align = 1;

	for (usz i = 0; i < components.count; i++) {
		Component* c = &components.types[i];
		
		offset = mem::aligned_offset(offset, c.alignment);
		c.offset = offset;
		offset += c.size;
		chunk_align = max(chunk_align, c.alignment);
	}

	components.size = mem::aligned_offset(offset, chunk_align);

	free(types);
}
