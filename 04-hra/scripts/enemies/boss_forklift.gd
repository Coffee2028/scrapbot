extends Enemy
## Boss prvního patra: vysokozdvižný vozík „Kladivo“.
## Střídá tři útoky:
##   1. pomalu se blíží k robotovi,
##   2. zabliká, zaburácí a rozjede se proti němu – při nárazu do zdi rozhodí střely do kruhu,
##   3. vystřelí několik vějířů střel.
## Pod polovinou životů zrychlí a střílí víc.

const TEX := preload("res://assets/sprites/boss_forklift.png")

enum Mode { WALK, WARN, CHARGE, STUNNED, SPRAY }

var mode := Mode.WALK
var timer := 1.5
var charge_dir := Vector2.ZERO
var volleys := 0


func _init() -> void:
	hp = 45.0
	texture = TEX
	spawn_time = 1.0


func make_shape() -> Shape2D:
	var r := RectangleShape2D.new()
	r.size = Vector2(24, 24)
	return r


func _ready() -> void:
	super._ready()
	radius = 12.0


func angry() -> bool:
	return hp < max_hp * 0.5


func hit(damage: float, from_dir := Vector2.ZERO) -> void:
	super.hit(damage, from_dir * 0.15)   # těžký vozík skoro neodhodíš


func think(delta: float) -> void:
	timer -= delta
	var speed_mul := 1.35 if angry() else 1.0
	match mode:
		Mode.WALK:
			velocity = direction_to_player() * 22.0 * speed_mul
			if timer <= 0.0:
				if randf() < 0.55:
					_start_warn()
				else:
					mode = Mode.SPRAY
					volleys = 4 if angry() else 3
					timer = 0.2
		Mode.WARN:
			velocity = Vector2.ZERO
			sprite.position = Vector2(randf_range(-1, 1), randf_range(-1, 1))   # třese se
			sprite.modulate = Color(2.0, 1.2, 1.0) if int(timer * 16) % 2 == 0 else Color.WHITE
			if timer <= 0.0:
				sprite.position = Vector2.ZERO
				sprite.modulate = Color.WHITE
				charge_dir = direction_to_player()
				mode = Mode.CHARGE
				timer = 1.6
		Mode.CHARGE:
			velocity = charge_dir * 175.0 * speed_mul
			if get_slide_collision_count() > 0 or timer <= 0.0:
				_crash()
		Mode.STUNNED:
			velocity = Vector2.ZERO
			if timer <= 0.0:
				mode = Mode.WALK
				timer = randf_range(1.0, 1.8) / speed_mul
		Mode.SPRAY:
			velocity = Vector2.ZERO
			if timer <= 0.0:
				_fan(7 if angry() else 5)
				volleys -= 1
				timer = 0.45 / speed_mul
				if volleys <= 0:
					mode = Mode.WALK
					timer = randf_range(1.2, 2.0) / speed_mul


func _start_warn() -> void:
	mode = Mode.WARN
	timer = 0.7
	Sfx.play("boss_charge")


## Náraz do zdi: otřes obrazovky a kruh střel.
func _crash() -> void:
	mode = Mode.STUNNED
	timer = 0.9
	velocity = Vector2.ZERO
	if room and room.has_method("shake"):
		room.shake(4.0)
	Sfx.play("explode", 2.0)
	Fx.sparks(get_parent(), position + charge_dir * 14.0, "yellow", 16, 110.0)
	var count := 12 if angry() else 8
	for i in count:
		shoot(Vector2.RIGHT.rotated(TAU * i / count), 60.0)


## Vějíř střel směrem k robotovi.
func _fan(count: int) -> void:
	var base := direction_to_player().angle()
	var spread := deg_to_rad(16.0)
	for i in count:
		var a := base + (i - (count - 1) / 2.0) * spread
		shoot(Vector2.RIGHT.rotated(a), 78.0)
	Sfx.play("enemy_shoot", -2.0)


func die() -> void:
	if _dead:
		return
	Fx.explosion(get_parent(), position, true)
	Fx.explosion(get_parent(), position + Vector2(8, -6), true)
	super.die()
