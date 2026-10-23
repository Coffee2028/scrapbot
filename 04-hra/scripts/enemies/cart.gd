extends Enemy
## Pásový vozík: jezdí po místnosti tam a zpátky. Když se robot ocitne
## ve stejné řadě nebo sloupci, zabliká a rozjede se proti němu.

const TEX := preload("res://assets/sprites/cart.png")
const PATROL_SPEED := 30.0
const CHARGE_SPEED := 135.0

enum Mode { PATROL, WARN, CHARGE, REST }

var mode := Mode.PATROL
var dir := Vector2.RIGHT
var timer := 0.0


func _init() -> void:
	hp = 4.0
	texture = TEX
	radius = 6.5


func _ready() -> void:
	super._ready()
	dir = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN].pick_random()


func think(delta: float) -> void:
	timer -= delta
	match mode:
		Mode.PATROL:
			velocity = dir * PATROL_SPEED
			if get_slide_collision_count() > 0:
				dir = -dir
			var line := _player_in_line()
			if line != Vector2.ZERO:
				dir = line
				mode = Mode.WARN
				timer = 0.35
		Mode.WARN:
			velocity = Vector2.ZERO
			sprite.modulate = Color(2.2, 1.4, 1.0) if int(timer * 20) % 2 == 0 else Color.WHITE
			if timer <= 0.0:
				sprite.modulate = Color.WHITE
				mode = Mode.CHARGE
				timer = 1.2
		Mode.CHARGE:
			velocity = dir * CHARGE_SPEED
			if timer <= 0.0 or get_slide_collision_count() > 0:
				if get_slide_collision_count() > 0:
					Fx.sparks(get_parent(), position + dir * 8.0, "yellow", 6)
				mode = Mode.REST
				timer = 0.7
		Mode.REST:
			velocity = Vector2.ZERO
			if timer <= 0.0:
				dir = -dir
				mode = Mode.PATROL
	sprite.rotation = 0.0 if absf(dir.x) > 0.0 else PI / 2.0


## Je robot zhruba ve stejném řádku nebo sloupci? Vrátí směr k němu, jinak nulu.
func _player_in_line() -> Vector2:
	if player == null:
		return Vector2.ZERO
	var d := player.global_position - global_position
	if absf(d.y) < 7.0 and absf(d.x) < 150.0:
		return Vector2(signf(d.x), 0)
	if absf(d.x) < 7.0 and absf(d.y) < 110.0:
		return Vector2(0, signf(d.y))
	return Vector2.ZERO
