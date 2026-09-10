module mobee;

import std::io;
import std::sort;

<* Relation type that describes child->parent relationship. *>
struct ChildOf (Printable) {
	<* Custom data pointer for the relation. *>
	void* data;
}

fn sz? ChildOf.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ data: %p }", self.data);
}

<* Relation type that describes parent->child relationship. *>
struct ParentOf (Printable) {
	<* Custom data pointer for the relation. *>
	void* data;
}

fn sz? ParentOf.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ data: %p }", self.data);
}

<* Relation type that describes whether an entity has dependencies
   on relationships with other entities (is their relations target). *>
typedef RelationOf = char;

<* Relation element type description. *>
struct Relation @private {
	<* Type id of the relation type. *>
	typeid type;
	<* Index of the relation in the bitset (entity's relations marker). *>
	sz idx;
	<* Type size for allocations. *>
	sz size;
	<* Type alignment for allocations. *>
	sz alignment;
	<* Relation offset (position) in the storage. *>
	sz offset;
	<* Relation target (entity or array of entities) offset (position) in the storage. *>
	sz target_offset;
}

<* Registered relation types collection for each world. *>
struct Relations @private {
	<* Registered ids of relation types converted from typeids.
	   Index in this array will be index in the merker (bitset)
	   and the index of relation's (component's) chunk in the block. *>
	uptr[MAX_RELATIONS_COUNT] ids;
	<* Instances of concrete relation type. *>
	Relation[MAX_RELATIONS_COUNT] types;
	<* Relation types count (last index + 1). *>
	sz count;
	<* Total size in bytes of all relations and targets. *>
	sz size;
	<* Index of ChildOf relation in the merker. *>
	sz idx_child_of;
	<* Index of ParentOf relation in the merker. *>
	sz idx_parent_of;
	<* Index of RelationOf relation in the merker. *>
	sz idx_relation_of;
}

<* Gets index of relation type.
   @param relations   : "Reference to relation types collection."
   @param type        : "Relation type."
   @return              "Index of the relation type."
   @return? NOT_FOUND : "Relation type was not found (registered)." *>
fn sz? relation_index(Relations* relations, typeid type) @private @inline {
	uptr id = (uptr)type;

	for (sz i = 0; i < relations.count; i++) {
		if (relations.ids[i] == id) return i;
	}

	return NOT_FOUND~;
}

<* Adds new relation type into collection.
   @param relations : "Reference to relation types collection."
   @param type      : "Relation type."
   @param relation  : "Instance of the relation type." *>
fn void relations_add(Relations* relations, typeid type, Relation relation) @private {
	if (relations_has(relations, type)) abort(ERR_RELATION_ALREADY_REGISTERED);
	if (relations.count == MAX_RELATIONS_COUNT) abort(ERR_MAX_RELATIONS_COUNT);

	relations.ids[relations.count] = (uptr)type;
	relations.types[relations.count] = relation;

	relations.count++;
}

<* Gets reference to the relation type.
   @param relations   : "Reference to relation types collection."
   @param type        : "Relation type."
   @return              "Pointer to relation's type instance."
   @return? NOT_FOUND : "Relation type was not found (registered)." *>
fn Relation*? relations_get(Relations* relations, typeid type) @private @inline {
	if (try sz idx = relation_index(relations, type)) {
		return &relations.types[idx];
	} else {
		return NOT_FOUND~;
	}
}

<* Checks if the collection has specified relation type.
   @param relations : "Reference to relation types collection."
   @param type      : "Relation type."
   @return            "True if type was found, otherwise - false." *>
fn bool relations_has(Relations* relations, typeid type) @private @inline {
	return @ok(relation_index(relations, type));
}

<* Adjust relation types for efficient access, sort, calculate offsets.
   @param world : "Pointer to the world." *>
fn void relations_adjust(World* world) @private {
	Relations* relations = &world.relations;
	Relation[] types = @clone_slice(relations.types[:relations.count]);

	quicksort(relations.ids[:relations.count]);

	foreach (relation : types) {
		sz idx = relation_index(relations, relation.type)!!;
		relations.types[idx] = relation;
		relations.types[idx].idx = idx;
	}

	/* Relations are stored right after components. */
	relations.types[0].offset = world.components.size;

	sz offset = world.components.size;
	sz chunk_align = void*::alignment;

	for (sz i = 0; i < relations.count; i++) {
		Relation* r = &relations.types[i];
		
		offset = mem::aligned_offset(offset, r.alignment);
		r.offset = offset;
		offset += r.size;
		offset = mem::aligned_offset(offset, void*::alignment);
		r.target_offset = offset;
		offset += void*::size;
		chunk_align = max(chunk_align, r.alignment);
	}

	/* Relations size without components size in the common chunk. */
	relations.size = mem::aligned_offset(offset, chunk_align) - world.components.size;

	free(types);

	/* To speed up checks for builtin relations we store their indexes. */
	relations.idx_child_of = relation_index(relations, ChildOf)!!;
	relations.idx_parent_of = relation_index(relations, ParentOf)!!;
	relations.idx_relation_of = relation_index(relations, RelationOf)!!;
}
