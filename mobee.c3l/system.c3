module mobee;

<* System type. *>
struct System {
	<* Name of the system. It must be unique. Used for getting the system from the world. *>
	String name;
	<* System state. Uses:
	   ENABLED:				   If system is enabled it will run in each step of the world progress,
	        				   disable it to pause execution for some reason.
	   HAS_TAGS:			   Query tags has been registered. For optimization if wasn't.
	   HAS_COMPONENTS:		   Query component has been registered. For optimization if wasn't.
	   HAS_RELATIONS:		   Query relations has been registered. For optimization if wasn't.
	   HAS_WITHOUT_TAGS:       Query excluding tags has been registered. For optimization if wasn't.
	   HAS_WITHOUT_COMPONENTS: Query excluding components has been registered. For optimization if wasn't.
	   HAS_WITHOUT_RELATIONS:  Query excluding relations has been registered. For optimization if wasn't. *>
	ElementState state;
	<* Components marker, each set bit specifies component in the system match query. *>
	sz[COMPONENTS_MARKER_SIZE] components;
	<* Tags marker, each set bit specifies tag in the system match query. *>
	sz[TAGS_MARKER_SIZE] tags;
	<* Relations marker, each set bit specifies relation in the system match query. *>
	sz[RELATIONS_MARKER_SIZE] relations;
	<* Excluding components marker, each set bit specifies component in the system match query. *>
	sz[COMPONENTS_MARKER_SIZE] without_components;
	<* Excluding tags marker, each set bit specifies tag in the system match query. *>
	sz[TAGS_MARKER_SIZE] without_tags;
	<* Excluding relations marker, each set bit specifies relation in the system match query. *>
	sz[RELATIONS_MARKER_SIZE] without_relations;
	<* System running phase, order in the pipeline. By default equals UPDATE. *>
	Phase phase;
	<* Entities lifetime flag to optimize queries and do not process lifetimes
	   that you want to avoid for current system. Includes all lifetimes (0b00000011) by default.
	   Not used in ARCHETYPE approach. *>
	char lifetime;
	<* Matched entities list (query result) for current system run. Not used in ARCHETYPE approach. *>
	Entities entities;
	<* Callback function that will be invoked each step of the world progress.
	   Disable system to pause invokation. *>
	SystemCallback callback;
}

<* Checks if the system is enabled.
   @return "True if system is enabled, otherwise - false." *>
fn bool System.enabled(&self) @inline => self.state & ENABLED != 0;

<* Checks if the system has no components.
   @param system : "Pointer to the system."
   @return "True if system has no components, otherwise - false." *>
fn bool system_has_no_components(System* system) @private @inline => system.state & HAS_COMPONENTS == 0;

<* Checks if the system has no tags.
   @param system : "Pointer to the system."
   @return "True if system has no tags, otherwise - false." *>
fn bool system_has_no_tags(System* system) @private @inline => system.state & HAS_TAGS == 0;

<* Checks if the system has no relations.
   @param system : "Pointer to the system."
   @return "True if system has no relations, otherwise - false." *>
fn bool system_has_no_relations(System* system) @private @inline => system.state & HAS_RELATIONS == 0;

<* Checks if the system has no 'without components'.
   @param system : "Pointer to the system."
   @return "True if system has no 'without components', otherwise - false." *>
fn bool system_has_no_without_components(System* system) @private @inline => system.state & HAS_WITHOUT_COMPONENTS == 0;

<* Checks if the system has no 'without tags'.
   @param system : "Pointer to the system."
   @return "True if system has no 'without tags', otherwise - false." *>
fn bool system_has_no_without_tags(System* system) @private @inline => system.state & HAS_WITHOUT_TAGS == 0;

<* Checks if the system has no 'without relations'.
   @param system : "Pointer to the system."
   @return "True if system has no 'without relations', otherwise - false." *>
fn bool system_has_no_without_relations(System* system) @private @inline => system.state & HAS_WITHOUT_RELATIONS == 0;

<* Checks if the system is a task.
   @param system : "Pointer to the system."
   @return "True if system is a task, otherwise - false." *>
fn bool is_task(System* system) @private @inline => system.state & IS_TASK != 0;

<* Enables the system. *>
fn void System.enable(&self) @inline {
	self.state |= ENABLED;
}

<* Disables the system. *>
fn void System.disable(&self) @inline {
	self.state &= ~ENABLED;
}

fn bool System.eq(&self, System other) @operator(==) @inline => self.name == other.name;

<* Free all system resources.
   @param system : "Pointer to the system." *>
fn void free_system(System* system) @private @inline {
	system.entities.free();
}
