module mobee;

<* The space consists of worlds. *>
Worlds worlds @private;

<* Gets worlds count. *>
fn sz size() => worlds.len();

<* Initializes the space (ecs). *>
fn void init() {
	worlds.init(mem, 0);
}

<* Free all worlds of the space. *>
fn void destroy() {
	foreach (world : worlds) {
		free_world(world);
		free(world);
	}

	worlds.free();
}

<* Creates new world.
   @param approach : "Query match approach."
   @return           "Pointer to newly created world." *>
fn World* new(Approach approach = ARCHETYPE) {
	World* world = mem::new(World);
	world.approach = approach;
	
	worlds.push(world);
	world_init(world);

	return world;
}
