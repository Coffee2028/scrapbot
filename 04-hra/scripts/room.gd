extends Node2D
## Jedna místnost patra: podlaha, zdi, dveře, bedny, nepřátelé, věci a předměty.
## Postaví se z dat, která připravil floor_gen.gd. Když hráč odejde, místnost
## se smaže; co se v ní stalo (vyčištěno, sebrané věci), zůstává v datech.

signal door_entered(dir: Vector2i)
signal cleared
signal hatch_entered

const TILE := 16
const W := 17          # šířka v dlaždicích včetně zdí
const H := 11          # výška v dlaždicích včetně zdí
const DOOR_TILES := {
	Vector2i.UP: Vector2i(8, 0),
	Vector2i.DOWN: Vector2i(8, 10),
	Vector2i.LEFT: Vector2i(0, 5),
	Vector2i.RIGHT: Vector2i(16, 5),
}
const DOOR_ROTATION := {
	Vector2i.UP: 0.0, Vector2i.DOWN: PI, Vector2i.LEFT: -PI / 2.0, Vector2i.RIGHT: PI / 2.0,
}

const T_FLOOR := preload("res://assets/sprites/floor.png")
const T_WALL := preload("res://assets/sprites/wall.png")
const T_DOOR_OPEN := preload("res://assets/sprites/door_open.png")
const T_DOOR_CLOSED := preload("res://assets/sprites/door_closed.png")
const T_HATCH := preload("res://assets/sprites/hatch.png")

const ENEMIES := {
	"drone": preload("res://scripts/enemies/drone.gd"),
	"cart": preload("res://scripts/enemies/cart.gd"),
	"turret": preload("res://scripts/enemies/turret.gd"),
}
const BOSS := preload("res://scripts/enemies/boss_forklift.gd")
const PICKUP := preload("res://scripts/pickup.gd")
const PEDESTAL := preload("res://scripts/item_pedestal.gd")
const CRATE := preload("res://scripts/crate.gd")

var data: Dictionary
var player: Node2D
var game: Node
var boss: Node2D
var doors_open := true
var _door_sprites := {}
var _door_blockers := {}
var _alive := 0


func build(room_data: Dictionary, the_player: Node2D, the_game: Node) -> void:
	data = room_data
	player = the_player
	game = the_game
	y_sort_enabled = true
	_build_floor()
	_build_walls()
	for pos in data["crates"]:
		_add_crate(pos)
	for p in data["pickups"]:
		_add_pickup(p)
	for item in data["items"]:
		var ped := PEDESTAL.new()
		ped.setup(item)
		ped.taken.connect(_on_item_taken)
		add_child(ped)
	if data["hatch"]:
		_add_hatch()
	_set_doors(data["cleared"], false)


## Zavolá se, když už robot v místnosti stojí: teprve teď se objeví nepřátelé.
func start() -> void:
	if data["cleared"]:
		return
	if data["type"] == "boss":
		boss = BOSS.new()
		boss.position = Vector2(136, 60)
		boss.setup(self, player)
		boss.died.connect(_on_boss_died)
		add_child(boss)
		_alive = 1
		Stats.reached_boss = true
		if game and game.has_method("on_boss_appeared"):
			game.on_boss_appeared(boss)
		return
	for e in data["enemies"]:
		var enemy: Node2D = ENEMIES[e["kind"]].new()
		enemy.position = e["pos"]
		enemy.setup(self, player)
		enemy.died.connect(_on_enemy_died)
		add_child(enemy)
		_alive += 1
	if _alive == 0:
		_on_cleared()


func shake(amount: float) -> void:
	if game and game.has_method("shake"):
		game.shake(amount)


# ---------- stavba ----------

func _build_floor() -> void:
	var floor_sprite := Sprite2D.new()
	floor_sprite.texture = T_FLOOR
	floor_sprite.centered = false
	floor_sprite.region_enabled = true
	floor_sprite.region_rect = Rect2(0, 0, (W - 2) * TILE, (H - 2) * TILE)
	floor_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	floor_sprite.position = Vector2(TILE, TILE)
	floor_sprite.z_index = -10
	add_child(floor_sprite)


func _build_walls() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 1
	walls.collision_mask = 0
	add_child(walls)
	var door_tiles := {}
	for d in data["doors"]:
		door_tiles[DOOR_TILES[d]] = d
	for x in W:
		for y in H:
			if x != 0 and y != 0 and x != W - 1 and y != H - 1:
				continue
			var t := Vector2i(x, y)
			var center := Vector2(x * TILE + TILE / 2.0, y * TILE + TILE / 2.0)
			if door_tiles.has(t):
				_build_door(door_tiles[t], center)
				continue
			var s := Sprite2D.new()
			s.texture = T_WALL
			s.position = center
			s.z_index = -5
			add_child(s)
			var shape := CollisionShape2D.new()
			var r := RectangleShape2D.new()
			r.size = Vector2(TILE, TILE)
			shape.shape = r
			shape.position = center
			walls.add_child(shape)


func _build_door(dir: Vector2i, center: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = T_DOOR_OPEN
	s.position = center
	s.rotation = DOOR_ROTATION[dir]
	s.z_index = -5
	add_child(s)
	_door_sprites[dir] = s
	# zábrana, která drží dveře zavřené, dokud jsou v místnosti nepřátelé
	var blocker := StaticBody2D.new()
	blocker.collision_layer = 1
	var bshape := CollisionShape2D.new()
	var br := RectangleShape2D.new()
	br.size = Vector2(TILE, TILE)
	bshape.shape = br
	blocker.position = center
	blocker.add_child(bshape)
	add_child(blocker)
	_door_blockers[dir] = bshape
	# průchod: když do něj robot vejde a dveře jsou otevřené, jde se do vedlejší místnosti
	var trigger := Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	var tshape := CollisionShape2D.new()
	var tr := RectangleShape2D.new()
	tr.size = Vector2(TILE, TILE) - Vector2(abs(dir.x), abs(dir.y)) * 6.0
	tshape.shape = tr
	trigger.position = center + Vector2(dir) * 3.0
	trigger.add_child(tshape)
	trigger.body_entered.connect(func(body):
		if body == player and doors_open:
			door_entered.emit(dir))
	add_child(trigger)


## Pro pomocníka u dveří (player.gd): když robot jde k otevřeným dveřím a je
## blízko, vrátí, o kolik je vedle středu průchodu. Jinak vrátí Vector2.ZERO.
func door_offset(body_pos: Vector2, move: Vector2) -> Vector2:
	if not doors_open:
		return Vector2.ZERO
	for dir in _door_sprites:
		var d := Vector2(dir)
		if move.dot(d) < 0.3:                      # robot nejde směrem k těmto dveřím
			continue
		var to_door: Vector2 = _door_sprites[dir].position - body_pos
		var ahead := to_door.dot(d)                # jak daleko jsou dveře před robotem
		var beside := to_door - d * ahead          # o kolik je robot vedle středu dveří
		if ahead > -4.0 and ahead < 40.0 and beside.length() < 13.0:
			return beside
	return Vector2.ZERO


func _set_doors(open: bool, with_sound: bool) -> void:
	doors_open = open
	for dir in _door_sprites:
		_door_sprites[dir].texture = T_DOOR_OPEN if open else T_DOOR_CLOSED
		_door_blockers[dir].set_deferred("disabled", open)
	if with_sound:
		Sfx.play("door")


func _add_crate(pos: Vector2) -> void:
	var crate := CRATE.new()
	crate.setup(pos, self)
	add_child(crate)


## Bedna je rozbitá (rozstřílená nebo od EMP): zmizí i z dat místnosti,
## aby tu po návratu už nebyla, a občas z ní vypadne šroub.
func break_crate(crate: Node2D) -> void:
	if not is_instance_valid(crate) or crate.is_queued_for_deletion():
		return
	var pos: Vector2 = crate.position
	data["crates"].erase(pos)
	Sfx.play("crate", -2.0)
	Fx.sparks(self, pos, "wood", 14, 80.0)
	Fx.sparks(self, pos, "yellow", 4, 50.0)
	crate.queue_free()
	if randf() < 0.25:
		drop("screw", pos)


func _add_pickup(p: Dictionary) -> void:
	var node := PICKUP.new()
	node.setup(p)
	node.collected.connect(func(n): data["pickups"].erase(n.data))
	add_child(node)


## Nová věc na zemi (zapíše se i do dat, aby tu zůstala, když hráč odejde a vrátí se).
func drop(kind: String, pos: Vector2) -> void:
	var p := {"kind": kind, "pos": _free_spot(pos), "price": 0}
	data["pickups"].append(p)
	call_deferred("_add_pickup", p)   # odloženě: může se volat uprostřed fyziky


## Najde místo pro věc na zemi: uvnitř místnosti a ne v bedně ani na podstavci,
## jinak by na ni robot nedosáhl. Když je místo obsazené, vezme nejbližší volnou dlaždici.
func _free_spot(pos: Vector2) -> Vector2:
	pos = pos.clamp(Vector2(TILE + 8, TILE + 8), Vector2((W - 1) * TILE - 8, (H - 1) * TILE - 8))
	if not _blocked(pos):
		return pos
	var best := pos
	var best_dist := INF
	for x in range(1, W - 1):
		for y in range(1, H - 1):
			var c := Vector2(x * TILE + TILE / 2.0, y * TILE + TILE / 2.0)
			if not _blocked(c) and c.distance_to(pos) < best_dist:
				best = c
				best_dist = c.distance_to(pos)
	return best


## true, když by věc na tomhle místě ležela v bedně nebo na podstavci s předmětem.
func _blocked(pos: Vector2) -> bool:
	for crate_pos in data["crates"]:
		if absf(crate_pos.x - pos.x) < 14.0 and absf(crate_pos.y - pos.y) < 14.0:
			return true
	for item in data["items"]:
		if item["pos"].distance_to(pos) < 14.0:
			return true
	return false


func _add_hatch() -> void:
	var hatch := Area2D.new()
	hatch.position = Vector2(136, 88)
	hatch.collision_layer = 32
	hatch.collision_mask = 2
	var s := Sprite2D.new()
	s.texture = T_HATCH
	s.z_index = -4
	hatch.add_child(s)
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(10, 10)
	shape.shape = r
	hatch.add_child(shape)
	hatch.body_entered.connect(func(body):
		if body == player:
			hatch_entered.emit())
	add_child(hatch)


# ---------- události ----------

func _on_enemy_died(enemy: Node2D) -> void:
	_alive -= 1
	var r := randf()
	if r < 0.28:
		drop("screw", enemy.position)
	elif r < 0.34:
		drop("battery", enemy.position)
	if _alive <= 0:
		_on_cleared()


func _on_cleared() -> void:
	if data["cleared"]:
		return
	data["cleared"] = true
	Stats.rooms_cleared += 1
	_set_doors(true, true)
	# odměna za vyčištění místnosti
	var r := randf()
	if r < 0.25:
		drop("screw", Vector2(136, 88))
	elif r < 0.37:
		drop("battery", Vector2(136, 88))
	elif r < 0.45:
		drop("emp", Vector2(136, 88))
	cleared.emit()


func _on_boss_died(_boss: Node2D) -> void:
	_alive = 0
	data["cleared"] = true
	Stats.rooms_cleared += 1
	if game and game.has_method("on_boss_defeated"):
		game.on_boss_defeated()
	for i in 3:
		drop("screw", _boss.position + Vector2(randf_range(-16, 16), randf_range(-10, 10)))
	drop("battery", _boss.position + Vector2(0, 14))
	# za chvíli se otevřou dveře a objeví se poklop do dalšího patra
	# (Timer je dítětem místnosti, takže když místnost zmizí, zmizí s ní)
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 1.0
	timer.timeout.connect(_after_boss)
	add_child(timer)
	timer.start()


func _after_boss() -> void:
	_set_doors(true, true)
	data["hatch"] = true
	_add_hatch()
	cleared.emit()


func _on_item_taken(ped: Node2D) -> void:
	data["items"].erase(ped.data)
	if game and game.has_method("on_item_taken"):
		game.on_item_taken(ped.data["id"])
