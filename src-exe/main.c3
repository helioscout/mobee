module moecs_test;

import std::io;
import std::time;
import moecs;

alias ecs = module moecs;

struct Position (Printable) {
	double x, y;
}

struct Center (Printable) {
	int cx, cy;
}

struct Health (Printable) {
	char hp;
}

struct Rotation (Printable) {
	int angle;
	float rad;
}

struct Mutation (Printable) {
	int stage;
	uint128 skin;
}

typedef Velocity = float[1];

struct Resource1 (Printable) {
	bool enabled;
}

struct Resource2 (Printable) {
	bool enabled;
	int count;
}

struct Resource3 (Printable) {
	char* ptr;
	float[3] data;
	uint128 some;
}

struct Resource4 (Printable) {
	Position pos;
	Health hp;
}

struct Resource5 (Printable) {
	int[10] arr;
}

typedef VecType = float[<2>];

typedef Tag1 = int;
typedef Tag2 = int;

const usz MAX_COUNT = 130;
const usz BITS_COUNT = usz.sizeof * 8;
const usz MARKER_SIZE = (MAX_COUNT + BITS_COUNT - 1) / BITS_COUNT;

fn usz? Position.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ x: %f, y: %f }", self.x, self.y);
}
 
fn usz? Center.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ cx: %d, cy: %d }", self.cx, self.cy);
}

fn usz? Health.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ hp: %d }", self.hp);
}

fn usz? Rotation.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ angle: %d, rad: %f }", self.angle, self.rad);
}

fn usz? Mutation.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ stage: %d, skin: %f }", self.stage, self.skin);
}

fn usz? Resource1.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ enabled: %s }", self.enabled);
}

fn usz? Resource2.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ enabled: %s, count: %d }", self.enabled, self.count);
}

fn usz? Resource3.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ ptr: %p, data: %s, some: %d }", self.ptr, self.data, self.some);
}

fn usz? Resource4.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ pos: %s, hp: %s }", self.pos, self.hp);
}

fn usz? Resource5.to_format(&self, Formatter* f) @dynamic {
	return f.printf("{ arr: %s }", self.arr);
}

Clock clock @noinit;
NanoDuration duration @noinit;

fn void marker_print(usz[MARKER_SIZE] marker) {
	io::printn("--- marker ---");
	
	for (usz i = 0; i < marker.len; i++) {
		io::printfn("| word %d: %b", i, marker[i]);
	}

	io::printn("--------------");
}

fn void startup(Entities* entities, World* world) {
	io::printn("-- startup system...");
}

fn void system1(Entities* entities, World* world) {
	bool despawned;
	usz count;

	foreach (entity : entities) {
		if (count < 100) {
			entity.add((Position) { .x = 111, .y = 222 });
			count++;
		}

		if (!despawned && !entity.is_static()) {
			entity.despawn();
			despawned = true;
		}
	}
}

fn void system2(Entities* entities, World* world) {
	foreach (entity : entities) {
		if (try Position* p = entity.get(Position)) {
			p.x += 1;
		}
		
		if (try Center* c = entity.get(Center)) {
			c.cx += 1;
		}
	}
}

fn void system3(Entities* entities, World* world) {
	foreach (entity : entities) {
		if (try Position* p = entity.get(Position)) {
			p.x += 1;
		}
		
		if (try Center* c = entity.get(Center)) {
			c.cx += 1;
		}
	}
}

fn void system4(Entities* entities, World* world) {
	io::printn("-- manual system...");
}

fn void main() {
// mem::@report_heap_allocs_in_scope() {
	ecs::init();

	World* world = ecs::new();

	io::printn("--- registering ---");
	world.register(COMPONENT, Position)
		 .register(COMPONENT, Center)
		 .register(COMPONENT, VecType)
		 .register(COMPONENT, Mutation)
		 .register(COMPONENT, Health)
		 .register(COMPONENT, Rotation)
		 .register(COMPONENT, Velocity)
		 .register(RESOURCE, Resource1)
		 .register(RESOURCE, Resource2)
		 .register(RESOURCE, Resource3)
		 .register(RESOURCE, Resource4)
		 .register(RESOURCE, Resource5)
		 .register(TAG, Tag1)
		 .register(TAG, Tag2)
		 .mount({ .callback = &startup, .phase = START })
		 .mount({ .tags = { Tag1 }, .callback = &system1 })
		 .mount({ .tags = { Tag2 }, .callback = &system1 })
		 .mount({ .components = { Position, Center }, .callback = &system3 })
		 .mount({ .components = { Position, Center }, .tags = { Tag1, Tag2 }, .callback = &system3 })
		 .mount({ .name = "s1", .components = { Position }, .tags = { Tag1 }, .callback = &system2 })
		 .mount({ .name = "s2", .components = { Center }, .tags = { Tag1 }, .callback = &system2 })
		 .mount({ .name = "m_sys", .callback = &system4, .phase = MANUAL })
		 .run();
	io::printn("--- world is running ---");

	// Entities entities;
	// entities.init();

	// io::printn((uptr)Position.typeid);
	// io::printn((uptr)Center.typeid);
	// io::printn((uptr)VecType.typeid);
	// io::printn((uptr)Tag1.typeid);
	// io::printn((uptr)Tag2.typeid);
	// io::printfn("%b", usz.max >> (64 - 62 % 64));
	// io::printfn("marker: %b", usz.max >> (64 - 3 % 64));
	// io::printn(3 / 64);
	io::printfn("Entity size: %s", Entity.sizeof);
	// io::printn(Tag1.typeid == Tag1.typeid);

	// usz[MARKER_SIZE] marker;

	// marker_print(marker);
	// io::printfn("is all unset: %s", ecs::marker_is_all_unset(MAX_COUNT, MARKER_SIZE, &marker));
	// ecs::marker_set(MARKER_SIZE, &marker, 7);
	// ecs::marker_set(MARKER_SIZE, &marker, 63);
	// ecs::marker_set(MARKER_SIZE, &marker, 129);
	// io::printfn("is any set: %s", ecs::marker_is_any_set(MAX_COUNT, MARKER_SIZE, &marker));
	// marker_print(marker);
	// io::printfn("is 5-th bit set: %s", ecs::marker_is_set(MARKER_SIZE, &marker, 4));
	// io::printfn("is 64-th bit set: %s", ecs::marker_is_set(MARKER_SIZE, &marker, 63));
	// io::printfn("is 129-th bit set: %s", ecs::marker_is_set(MARKER_SIZE, &marker, 128));
	// io::printfn("is 130-th bit set: %s", ecs::marker_is_set(MARKER_SIZE, &marker, 129));

	// for (usz i = 0; i < 130; i++) ecs::marker_set(MARKER_SIZE, &marker, i);
	
	// marker_print(marker);
	// io::printfn("is all set: %s", ecs::marker_is_all_set(MAX_COUNT, MARKER_SIZE, &marker));
	// ecs::marker_unset(MARKER_SIZE, &marker, 7);
	// ecs::marker_unset(MARKER_SIZE, &marker, 63);
	// ecs::marker_unset(MARKER_SIZE, &marker, 129);
	// marker_print(marker);

	// usz[MARKER_SIZE] marker1 = { usz.max, usz.max, usz.max };
	// usz[MARKER_SIZE] marker2 = ecs::marker_clone(MARKER_SIZE, &marker1);

	// ecs::marker_unset(MARKER_SIZE, &marker2, 123);

	// marker_print(ecs::marker_xor(MARKER_SIZE, &marker, &marker1));
	// io::printfn("is equals: %s", ecs::marker_equals(MAX_COUNT, MARKER_SIZE, &marker1, &marker2));
	// io::printfn("is subset: %s", ecs::marker_is_subset(MAX_COUNT, MARKER_SIZE, &marker1, &marker2));
	// marker_print(marker1);
	// marker_print(marker2);

	world.@set(Resource1, { .enabled = true })
		 .@set(Resource2, { .count = 10 })
		 .@set(Resource3, { .some = 200 });

	if (try Resource1* r1 = world.get(Resource1)) {
		io::printn(r1);
	}

	if (try Resource3* r3 = world.get(Resource3)) {
		io::printn(r3);
	}

	world.@set(Resource1, { .enabled = false })
		 .@set(Resource3, { .some = 900 });

	if (try Resource1* r1 = world.get(Resource1)) {
		io::printn(r1);
	}

	if (try Resource3* r3 = world.get(Resource3)) {
		io::printn(r3);
	}

	io::printfn("-- spawning statics ( %d ) --", 100000 + 3);
	clock = clock::now();

	// foreach (ptr : entities.chunks) {
	// 	io::printf("%p ", ptr);
	// }

	for (usz i = 0; i < 100000 + 3; i++) {
		Entity* e = world.spawn(STATIC)
			.@add(Position, { .x = (double)i + 10, .y = (double)i + 20 })
			.@add(Center,   { .cx = (int)i + 20, .cy = (int)i + 20 })
			.@add(Health,   { .hp = 30 })
			.@add(Rotation, { .angle = 90 })
			.@add(Velocity, { 50 })
			.@add(VecType,  { 10, 20 })
			.@add(Mutation, { .skin = 11 });

		// usz idx = entities.push(e);

		// if (i > 99950) {
		// 	io::printfn("ptr: %p, idx: %d, get: %p", e, idx, entities[idx]);
		// }
	}

	// for (usz i = 0; i < 50; i++) {
	// 	io::printf("%p, ", entities.pop()!!);
	// }

	duration = clock.mark();
	io::printfn("-- ellapsed: %s", duration);

	world.@each(; Entity* entity, Lifetime lifetime) {
		// if (try Position* p = entity.get(Position)) {
		// 	io::printn(*p);
		// }
		
		// if (try Center* c = entity.get(Center)) {
		// 	io::printn(*c);
		// }
	};

	// world.spawn(QUICK)
	// 	.add((Position){ .x = 1, .y = 1 })
	// 	.add((Center){ .cx = 1, .cy = 1 });
	
	// world.spawn(DYNAMIC)
	// 	.add((Position){ .x = 1, .y = 1 })
	// 	.add((Center){ .cx = 1, .cy = 1 });
		
	// world.spawn(STATIC)
	// 	.add((Position){ .x = 1, .y = 1 })
	// 	.add((Center){ .cx = 1, .cy = 1 });
		
	Entity* e = world.spawn(DYNAMIC)
		.@add(Position, { .x = 1, .y = 1 })
		.@add(Center,   { .cx = 1, .cy = 1 })
		.@add(Health,   { .hp = 30 })
		.@add(Rotation, { .angle = 90 })
		.@add(Velocity, { 50 })
		.@add(VecType,  { 10, 20 })
		.@add(Mutation, { .skin = 11 });
	
	Entity* ed = world.spawn(DYNAMIC)
		.@add(Position, { .x = 2, .y = 2 })
		.@add(Center, { .cx = 2, .cy = 2 });
		
	Entity* es = world.spawn(STATIC)
		.@add(Position, { .x = 3, .y = 3 })
		.@add(Center, { .cx = 3, .cy = 3 });
		
	world.spawn(DYNAMIC);
	world.spawn(DYNAMIC);
	world.spawn(STATIC);

	io::printn("---------");
	io::printn(e.has(Position));
	io::printn(e.has(Center));
	io::printn(e.has(VecType));
	io::printn("---------");

	if (try Position* p = e.get(Position) && try Center* c = e.get(Center)) {
		io::printn(p);
		io::printn(c);
	} else {
		io::printn("Not found");
	}

	if (try Position* p = ed.get(Position) && try Center* c = ed.get(Center)) {
		io::printn(p);
		io::printn(c);
	} else {
		io::printn("Not found");
	}

	if (try Position* p = es.get(Position) && try Center* c = es.get(Center) && try VecType* v = es.get(VecType)) {
		io::printn(p);
		io::printn(c);
	} else {
		io::printn("Not found");
	}

	io::printn("---------");

	@pool() {
		foreach (component : e.tget_all(Position, Center, VecType, int)) {
			switch (component.type) {
				case Position:
					io::print("Position: ");
					io::printn(component);
				case Center:
					io::print("Center: ");
					io::printn(component);
			}
		}
	};

	io::printn("---- all -----");

	@pool() {
		foreach (component : ed.tall()) {
			switch (component.type) {
				case Position:
					io::print("Position: ");
					io::printn(component);
				case Center:
					io::print("Center: ");
					io::printn(component);
			}
		}
	};

	io::printn("---- @each -----");

	es.@each(; typeid type, void* c) {
		switch (type) {
			case Position:
				io::print("Position: ");
				io::printn((Position*)c);
			case Center:
				io::print("Center: ");
				io::printn((Center*)c);
		}
	};

	// es.remove_all(Position, Center);

	// es.@each(; typeid type, void* c) {
	// 	switch (type) {
	// 		case Position:
	// 			io::print("Position: ");
	// 			io::printn((Position*)c);
	// 		case Center:
	// 			io::print("Center: ");
	// 			io::printn((Center*)c);
	// 	}
	// };

	ed.tag(Tag1);

	io::printfn("Tagged with Tag1: %s", ed.tagged(Tag1));
	io::printfn("Tagged with Tag2: %s", ed.tagged(Tag2));

	es.tag_all(Tag1, Tag2);
	io::printn(es.tagged_all(Tag1, Tag2));
	
	es.untag_all(Tag2, Tag1);
	io::printn(es.tagged_all(Tag1, Tag2));

	io::printfn("-- spawning dynamicss ( %d ) --", 100000 + 3);
	clock = clock::now();
	
	for (usz i = 0; i < 100000 + 3; i++) {
		world.spawn(DYNAMIC)
			 .@add(Position, { .x = 10, .y = 10 })
			 .@add(Center,   { .cx = 20, .cy = 20 })
			 .@add(Health,   { .hp = 30 })
			 .@add(Rotation, { .angle = 90 })
			 .@add(Velocity, { 50 })
			 .@add(VecType,  { 10, 20 })
			 .@add(Mutation, { .skin = 11 })
			 .tag(Tag2);
	}

	duration = clock.mark();
	io::printfn("-- ellapsed: %s", duration);

	io::printfn("-- spawning dynamics ( %d ) --", 500000 + 3);
	clock = clock::now();
	
	for (usz i = 0; i < 500000 + 3; i++) {
		Entity* e7 = world.spawn(DYNAMIC);

		e7.add((Position) { .x = 1, .y = 2 })
		  .add((Health)   { .hp = 30 })
		  .add((Rotation) { .angle = 90 })
		  .add((Velocity) { 50 });
		  // .add((Center)   { .cx = 1, .cy = 2 });

		e7.tag(Tag1);

		if (i >= 100 && i < 105) {
			e7.add((Center) { .cx = 1, .cy = 2 });
			e7.tag(Tag2);
		}
	}

	duration = clock.mark();
	io::printfn("-- ellapsed: %s", duration);

	io::printfn("-- spawning statics ( %d ) --", 300000 + 3);
	clock = clock::now();
	
	for (usz i = 0; i < 300000 + 3; i++) {
		world.spawn(STATIC)
			 .@add(Position, { .x = 10, .y = 10 })
			 .@add(Center,   { .cx = 20, .cy = 20 })
			 .@add(Health,   { .hp = 30 })
			 .@add(Rotation, { .angle = 90 })
			 .@add(Velocity, { 50 })
			 .@add(VecType,  { 10, 20 })
			 .@add(Mutation, { .skin = 11 });
	}

	duration = clock.mark();
	io::printfn("-- ellapsed: %s", duration);

	io::printfn("--- iterating ---");
	clock = clock::now();

	usz count;
	
	world.@each(; Entity* entity, Lifetime lifetime) {
		if (try Position* p = entity.get(Position)) {
		}
		count++;
	};

	duration = clock.mark();
	io::printfn("-- ellapsed: %s, count: %s", duration, count);

	// io::readline(tmem)!!;

	if (try Resource1* r = world.get(Resource1)) {
		io::printn(r);
		r.enabled = true;
	}
	if (try Resource1* r = world.get(Resource1)) {
		io::printn(r);
	}

	world.@set(Resource1, { .enabled = false });
	if (try Resource1* r = world.get(Resource1)) {
		io::printn(r);
	}

	io::printn("--- Resource2 ---");
	if (try Resource2* r = world.get(Resource2)) {
		io::printn(r);
	}

	world.set((Resource2) { .enabled = true, .count = 7 });
	if (try Resource2* r = world.get(Resource2)) {
		io::printn(r);
	}

	// io::printfn("-- iterating dynamics ( %d ) --", DYNAMIC_CHUNK_SIZE * 1000 + 3);
	// clock = clock::now();

	// world.@each(Lifetime.DYNAMIC; Entity* entity, Lifetime lifetime) {
	// 	if (try Position* p = e.get(Position) && try Center* c = e.get(Center)) {
	// 		// some actions...
	// 	}
	// };
	
	// duration = clock.mark();
	// io::printfn("\nEllapsed: %s", duration);

	// io::printfn("-- iterating quicks ( %d ) --", QUICK_CHUNK_SIZE * 1000 + 3);
	// clock = clock::now();

	// world.@each(Lifetime.QUICK; Entity* entity, Lifetime lifetime) {
	// 	if (try Position* p = e.get(Position) && try Center* c = e.get(Center)) {
	// 		// some actions...
	// 	}
	// };
	
	// duration = clock.mark();
	// io::printfn("\nEllapsed: %s", duration);

	// io::printfn("-- iterating statics ( %d ) --", STATIC_CHUNK_SIZE * 1000 + 3);
	// clock = clock::now();

	// world.@each(Lifetime.STATIC; Entity* entity, Lifetime lifetime) {
	// 	if (try Position* p = e.get(Position) && try Center* c = e.get(Center)) {
	// 		// some actions...
	// 	}
	// };
	
	// duration = clock.mark();
	// io::printfn("\nEllapsed: %s", duration);

	// io::printn("-- iterating all --");
	// clock = clock::now();

	// world.@each(; Entity* entity, Lifetime lifetime) {
	// 	if (try Position* p = e.get(Position) && try Center* c = e.get(Center)) {
	// 		// some actions...
	// 	}
	// };
	
	// duration = clock.mark();
	// io::printf("\nEllapsed: %s", duration);

	world.despawn(e);
	world.despawn(ed);

	world.perform();

	foreach (archetype : world.archetypes) {
		io::printfn("archetype: %s, %s, %s", archetype.entities.len(), archetype.components, archetype.tags);
	}

	io::printn("--- progress 100 times ---");
	usz step = 0;
	clock = clock::now();
	
	while (step++ < 100) {
		world.progress();
	}
	
	duration = clock.mark();
	io::printf("-- ellapsed: %s", duration);

	// io::readline(tmem)!!;
// };
}
