module moecs;

<* The space consists of worlds. *>
Worlds worlds @private;

<* Gets worlds count. *>
fn usz size() {
	return worlds.size;
}

<* Initializes the space (ecs). *>
fn void init() {
	worlds.init(mem);
}

<* Creates new world.
   @param approach : "Query match approach."
   @return           "Pointer to newly created world."
*>
fn World* new(Approach approach = ARCHETYPE) {
	World* world = mem::new(World, { .approach = approach });
	
	worlds.push(world);
	world_init(world);

	return world;
}
