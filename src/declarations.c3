module moecs;

import std::collections::list;
import std::collections::elastic_array;

/* Size (items count) of the one components chunk or entities collection for each block.
   Bigger chunk size increase productivity of entities adding, less chunk size can save a bit of memory. */

<* Dynamic lifetime chunk size. *>
const usz DYNAMIC_CHUNK_SIZE @private = 500;
<* Static lifetime chunk size. *>
const usz STATIC_CHUNK_SIZE @private  = 300;

<* Maximum components count available for adding to entity. *>
const usz MAX_COMPONENTS_COUNT = 127;
<* Maximum tags count available for adding to entity. *>
const usz MAX_TAGS_COUNT = 127;
<* Maximum resources count available for adding to the world. *>
const usz MAX_RESOURCES_COUNT = 127;

<* Count of bits in one marker word (element of marker array). *>
const usz MARKER_BITS_COUNT @private = usz.sizeof * 8;
<* Size of components marker (array of bitset). *>
const usz COMPONENTS_MARKER_SIZE @private = (MAX_COMPONENTS_COUNT + MARKER_BITS_COUNT - 1) / MARKER_BITS_COUNT;
<* Size of tags marker (array of bitset). *>
const usz TAGS_MARKER_SIZE @private = (MAX_TAGS_COUNT + MARKER_BITS_COUNT - 1) / MARKER_BITS_COUNT;

<* Number of entity's pointers in the one list chunk (block of memory). *>
const usz ENTITIES_LIST_CHUNK_SIZE @private = 3000;
<* Maximum chunks count available for the entities list. *>
const usz ENTITIES_LIST_MAX_CHUNKS_COUNT @private = 1000;

<* Blocks collection for each world. *>
alias Blocks = List { Block* };

<* Worlds collection in the space. *>
alias Worlds = List { World* };

<* Pointers to component values when retrieving/getting all. *>
alias ComponentPointers = ElasticArray { any, MAX_COMPONENTS_COUNT };

<* Systems collection in the world. *>
alias Systems = List { System* };

<* Archetypes collection of the world. *>
alias Archetypes = List { Archetype* };

<* Indexes type for dynamic lifetime block. *>
alias Indexes = ElasticArray { usz, DYNAMIC_CHUNK_SIZE };

<* Entities/blocks lifetime. *>
constdef Lifetime : inline char {
   <* Entities whose lifespan is not defined or determined in advance (from one frame to app exit).
      Such blocks will reuse freed after deletion rows to insert new entities. *>
   DYNAMIC = 0b00000001,
   <* Immortal entities that will exist until the end of the application.
      Such blocks are simply created when necessary, since entities cannot be despawn. *>
   STATIC  = 0b00000010
}

<* Kinds of elements that the world can consist of. *>
enum Element {
   <* Component element type (Position, Mass, Velocity).
      Must be defined as a struct or typedef custom type. *>
   COMPONENT,
   <* Tag element type for marking entities with some kind of characteristic.
      Must be defined as a typedef with a simple fundamental underlying type (typedef Tag = int). *>
   TAG,
	<* Resource element type for storing data in the world that has only one instance, singleton.
	   Must be defined as a struct or typedef custom type. Resources are not entities without components
	   as in other ECS, they have own storage and methods. *>
   RESOURCE,
   <* System element type for running actions at each step of the world progress. *>
   SYSTEM
}

<* The state flags for an element (entity or system). *>
constdef ElementState : inline char {
   <* Entity has been deleted. *>
   DELETED        = 0b00000001,
   <* System is enabled. *>
   ENABLED        = 0b00000010,
   <* System has tags in the match query. *>
   HAS_TAGS       = 0b00000100,
   <* System has components in the match query. *>
   HAS_COMPONENTS = 0b00001000,
   <* Indicates that a system is task, has no components or tags in match query. *>
   IS_TASK        = 0b00010000,
   <* Entity should be re-archetyped at deffered (perform) stage. *>
   ARCHETYPING    = 0b00100000,
   <* Entity should be despawned at deferred (perform) stage. *>
   DESPAWNING     = 0b01000000
}

<* Query match approach of slection entities for the systems. *>
enum Approach : char {
	<* Using this approach at each progress step all world entities will be iterated
	   with applying match conditions to select them for each running system.
	   First, iterates through all entities in the world for which the match condition is checked,
	   and if the entity matches, it is added to the system's collection of entities.
	   Then, all systems to which the generated collections are passed are executed in turn.
	   At the beginning of progress each step, these collections are cleared.
	   This is a very inefficient method, but it does not involve deferred actions. *>
	ITERATION,
	<* Each entity belongs to some unique archetype that is combination of bit flags
	   that represent entity's components/tags configuration. At each world progress step
	   all archetypes will be iterated with applying match condition of each system.
	   If an archetype matches the system query conditions, the system is launched with a list
	   of entities of that archetype. This is an effective approach, but it requires deferred actions.
	   The system callback will be invoked for each matching archetype. *>
	ARCHETYPE
}

<* System running phase, determine when system should run during pipeline. *>
constdef Phase : inline char {
	<* System will run once at the beginning of the first progress step. *>
	START       = 1,
	<* System will run before update phase. *>
	PRE_UPDATE  = 2,
	<* Main phase of each progress step. *>
	UPDATE      = 0,
	<* System will run after update phase. *>
	POST_UPDATE = 3,
	<* System can be executed only manually using its name, excluded from progress pipeline. *>
	MANUAL      = 4
}

<* Systems collections for each running phase. *>
struct Schedule @private {
	<* Systems that are being ran at the start phase. *>
	Systems start;
	<* Systems that are being ran at the pre-update phase. *>
	Systems pre_update;
	<* Systems that are being ran at the update phase. *>
	Systems update;
	<* Systems that are being ran at the post-update phase. *>
	Systems post_update;
}

<* Deffered actions for the world. *>
struct Deffered {
	<* Despawning entities. We need to keep them in the archetypes till end of the current progress step,
	   otherwise iterators inside systems code can lead to bugs, as they iterate over collections of
	   the archetypes which we need to delete entities from. Entities will be marked as DESPAWNING but
	   despawned (deleted from the block) at performing stage. Also, a new entity can be written in place
	   of a deleted entity, then bugs are inevitable since the reference to the deleted entity will
	   continue to be stored in the archetype collection. *>
	Entities despawning;
	<* When tags/components is being added/removed to the entity and world is already running,
	   entities should not be moved to other archetypes till end of the current progress step,
	   so this archetyping action is deferred to the perform stage. *>
	Entities archetyping;
}

<* Callback function for the system.
   @param entities : "Matched entities for the system."
   @param world    : "Pointer to the world." *>
alias SystemCallback = fn void (Entities* entities, World* world);

<* Entities iterator. *>
struct EntitiesIterator @private {
	<* Current entity index. *>
	usz idx;
	<* Current entity pointer. *>
	Entity* entity;
}

<* Accessing element is out of bounds of the collection. *>
faultdef OUT_OF_BOUNDS;
<* There is no element to swap with removed one in the collection. *>
faultdef NO_SWAPPED_ELEMENT;
