class_name FloorGen
## Náhodné patro jako v The Binding of Isaac: místnosti v mřížce propojené dveřmi.
## Na konci slepých chodeb leží boss, pokladová místnost a obchod.
## Výsledek je jen „data“ (slovník); místnosti z nich staví room.gd.

const DIRS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const ROOM_COUNT := 10
const LIMIT := 3                    # mřížka -3..3 (7 × 7 polí), aby se vešla do minimapy
const TILE := 16
const DOOR_ENTRY := [Vector2i(8, 1), Vector2i(8, 9), Vector2i(1, 5), Vector2i(15, 5)]

# rozestavení beden (souřadnice dlaždic uvnitř místnosti 1..15 × 1..9)
const CRATE_SETS := [
	[],
	[Vector2i(4, 3), Vector2i(12, 3), Vector2i(4, 7), Vector2i(12, 7)],
	[Vector2i(7, 5), Vector2i(9, 5)],
	[Vector2i(5, 4), Vector2i(5, 6), Vector2i(11, 4), Vector2i(11, 6)],
	[Vector2i(3, 2), Vector2i(13, 2), Vector2i(3, 8), Vector2i(13, 8), Vector2i(8, 5)],
	[Vector2i(6, 3), Vector2i(10, 3), Vector2i(6, 7), Vector2i(10, 7)],
]


static func generate(rng: RandomNumberGenerator) -> Dictionary:
	for attempt in 300:
		var rooms := {}
		rooms[Vector2i.ZERO] = _new_room("start")
		var cells: Array[Vector2i] = [Vector2i.ZERO]
		var guard := 0
		while cells.size() < ROOM_COUNT and guard < 2000:
			guard += 1
			var from: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
			var pos: Vector2i = from + DIRS[rng.randi_range(0, 3)]
			if rooms.has(pos) or absi(pos.x) > LIMIT or absi(pos.y) > LIMIT:
				continue
			if _neighbor_count(rooms, pos) > 1:      # žádné kruhy ani shluky místností
				continue
			rooms[pos] = _new_room("normal")
			cells.append(pos)
		if cells.size() < ROOM_COUNT:
			continue

		var dist := _distances(rooms)
		var dead_ends: Array[Vector2i] = []
		for pos in cells:
			if pos != Vector2i.ZERO and _neighbor_count(rooms, pos) == 1:
				dead_ends.append(pos)
		if dead_ends.size() < 3:
			continue
		dead_ends.sort_custom(func(a, b): return dist[a] > dist[b])
		if dist[dead_ends[0]] < 3:                   # boss nesmí být hned vedle startu
			continue

		rooms[dead_ends[0]]["type"] = "boss"
		rooms[dead_ends[0]]["cleared"] = false
		rooms[dead_ends[1]]["type"] = "treasure"
		rooms[dead_ends[2]]["type"] = "shop"
		for pos in rooms:
			var room: Dictionary = rooms[pos]
			room["depth"] = dist[pos]
			var doors: Array[Vector2i] = []
			for d in DIRS:
				if rooms.has(pos + d):
					doors.append(d)
			room["doors"] = doors
			if room["type"] == "normal":
				_fill_normal(room, rng)
		_place_items(rooms, dead_ends[1], dead_ends[2], rng)
		return {"rooms": rooms}
	push_error("FloorGen: patro se nepodařilo vytvořit")
	return {}


static func _new_room(type: String) -> Dictionary:
	return {
		"type": type,
		"cleared": type != "normal",
		"visited": false,
		"enemies": [],        # [{"kind", "pos"}]
		"crates": [],         # [Vector2]
		"pickups": [],        # [{"kind", "pos", "price"}]
		"items": [],          # [{"id", "pos", "price"}]
		"hatch": false,
	}


static func tile_to_pos(t: Vector2i) -> Vector2:
	return Vector2(t.x * TILE + TILE / 2.0, t.y * TILE + TILE / 2.0)


static func _neighbor_count(rooms: Dictionary, pos: Vector2i) -> int:
	var n := 0
	for d in DIRS:
		if rooms.has(pos + d):
			n += 1
	return n


## Kolik dveří je každá místnost daleko od startu (prohledávání do šířky).
static func _distances(rooms: Dictionary) -> Dictionary:
	var dist := {Vector2i.ZERO: 0}
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	while not queue.is_empty():
		var p: Vector2i = queue.pop_front()
		for d in DIRS:
			var n: Vector2i = p + d
			if rooms.has(n) and not dist.has(n):
				dist[n] = dist[p] + 1
				queue.append(n)
	return dist


## Běžná místnost: bedny a nepřátelé. Čím dál od startu, tím víc nepřátel.
static func _fill_normal(room: Dictionary, rng: RandomNumberGenerator) -> void:
	var crate_tiles: Array = CRATE_SETS[rng.randi_range(0, CRATE_SETS.size() - 1)]
	var crates: Array[Vector2] = []
	for t in crate_tiles:
		crates.append(tile_to_pos(t))
	room["crates"] = crates

	var free: Array[Vector2i] = []
	for x in range(2, 15):
		for y in range(2, 9):
			var t := Vector2i(x, y)
			if t in crate_tiles:
				continue
			var near_door := false
			for door in DOOR_ENTRY:
				if absi(door.x - x) + absi(door.y - y) <= 4:
					near_door = true
			if not near_door:
				free.append(t)

	var count := clampi(1 + room["depth"] + rng.randi_range(0, 1), 2, 5)
	var enemies: Array = []
	for i in count:
		if free.is_empty():
			break
		var t: Vector2i = free.pop_at(rng.randi_range(0, free.size() - 1))
		var roll := rng.randf()
		var kind := "drone" if roll < 0.45 else ("cart" if roll < 0.75 else "turret")
		enemies.append({"kind": kind, "pos": tile_to_pos(t)})
	room["enemies"] = enemies


## Poklad: 1 předmět zdarma. Obchod: 2 předměty a článek baterie za šrouby.
static func _place_items(rooms: Dictionary, treasure: Vector2i, shop: Vector2i, rng: RandomNumberGenerator) -> void:
	var pool: Array = Items.ALL.keys()
	for i in range(pool.size() - 1, 0, -1):       # zamíchání se semínkem patra
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	rooms[treasure]["items"] = [{"id": pool[0], "pos": tile_to_pos(Vector2i(8, 5)), "price": 0}]
	rooms[shop]["items"] = [
		{"id": pool[1], "pos": tile_to_pos(Vector2i(6, 5)), "price": 7},
		{"id": pool[2], "pos": tile_to_pos(Vector2i(10, 5)), "price": 10},
	]
	rooms[shop]["pickups"] = [{"kind": "battery", "pos": tile_to_pos(Vector2i(8, 7)), "price": 3}]
