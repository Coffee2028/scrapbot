extends CharacterBody2D
## SCRAPBOT – robot, za kterého hráč hraje.
## Pohyb do 8 směrů, střelba do 4 směrů nezávisle na pohybu (jako v The Binding of Isaac),
## životy jsou články baterie, peníze jsou šrouby a bomby jsou EMP nálože.

signal stats_changed      # něco se změnilo na HUD (baterie, šrouby, nálože…)
signal died

const TEX := preload("res://assets/sprites/player.png")
const EMP_SCRIPT := preload("res://scripts/emp.gd")
const BODY_OFFSET := Vector2(0, 2)   # tělo (kolize) je o 2 px níž než střed obrázku

# --- vlastnosti, které mění předměty ---
var speed := 85.0
var fire_delay := 0.34       # sekundy mezi výstřely
var damage := 1.0
var shot_speed := 170.0
var shot_life := 0.62        # jak daleko střely doletí
var homing := 0.0            # magnetická cívka
var random_shots := false    # zaseknuté relé

# --- zdroje ---
var max_cells := 3
var cells := 3
var screws := 0
var emps := 1
var items: Array[String] = []

var room: Node2D             # aktuální místnost (do ní přidáváme střely)
var controls_locked := false
var sprite: Sprite2D
var _cooldown := 0.0
var _invulnerable := 0.0
var _eye := 1                # střídá levé a pravé „oko“, ze kterého střela vylétá
var _t := 0.0
var _dead := false


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = TEX
	add_child(sprite)
	# tělo je kruh: o rohy zdí a beden se nezasekne, ale sklouzne kolem nich
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	shape.shape = circle
	shape.position = BODY_OFFSET
	add_child(shape)
	collision_layer = 2       # vrstva 2: robot
	collision_mask = 1        # naráží do zdí a beden
	# „Hurtbox“: zóna, která hlídá dotyk s nepřáteli
	var hurtbox := Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 4
	var hshape := CollisionShape2D.new()
	var hrect := RectangleShape2D.new()
	hrect.size = Vector2(9, 11)
	hshape.shape = hrect
	hshape.position = Vector2(0, 1)
	hurtbox.add_child(hshape)
	add_child(hurtbox)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_t += delta
	_cooldown -= delta
	if _invulnerable > 0.0:
		_invulnerable -= delta
		sprite.visible = int(_invulnerable * 15) % 2 == 0 or _invulnerable <= 0.0

	var move := Vector2.ZERO
	var aim := Vector2.ZERO
	if not controls_locked:
		move = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		aim = _aim_direction()
	velocity = velocity.move_toward(move * speed, 900.0 * delta)
	_door_assist(move)
	move_and_slide()

	# drobná animace chůze a otáčení podle směru
	sprite.position.y = -absf(sin(_t * 14.0)) * 1.5 if move != Vector2.ZERO else 0.0
	if aim.x != 0.0:
		sprite.flip_h = aim.x < 0.0
	elif move.x != 0.0:
		sprite.flip_h = move.x < 0.0

	if aim != Vector2.ZERO and _cooldown <= 0.0:
		_shoot(aim)
	if not controls_locked and Input.is_action_just_pressed("emp"):
		_drop_emp()

	# dotyk s nepřítelem bolí
	for body in $Hurtbox.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.is_active():
			take_damage(1)
			break


## Když robot míří do otevřených dveří a je jen kousek vedle, jemně ho navedeme
## do středu průchodu (jako v Isaacovi), aby se nezasekl o roh zdi.
func _door_assist(move: Vector2) -> void:
	if room == null or move == Vector2.ZERO or not room.has_method("door_offset"):
		return
	var fix: Vector2 = room.door_offset(position + BODY_OFFSET, move)
	if fix == Vector2.ZERO:
		return
	var along := fix.normalized()
	velocity -= along * velocity.dot(along)                     # zrušíme pohyb podél zdi…
	velocity += along * minf(fix.length() * 12.0, speed)        # …a posuneme robota ke středu


## Směr střelby jen do 4 stran: vybere převládající směr ze šipek / pravé páčky.
func _aim_direction() -> Vector2:
	var v := Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	if v == Vector2.ZERO:
		return Vector2.ZERO
	if absf(v.x) >= absf(v.y):
		return Vector2(signf(v.x), 0)
	return Vector2(0, signf(v.y))


func _shoot(dir: Vector2) -> void:
	if room == null:
		return
	_cooldown = fire_delay
	_eye = -_eye
	var dmg := damage
	var spd := shot_speed
	var size := 1.0
	if random_shots:              # zaseknuté relé: každá střela je trochu jiná
		var k := randf_range(0.6, 1.9)
		dmg *= k
		size = clampf(k, 0.7, 1.7)
		spd *= randf_range(0.8, 1.25)
	var start := position + dir * 6.0 + dir.orthogonal() * 2.0 * _eye + Vector2(0, -1)
	var vel := dir * spd + velocity * 0.25   # střela si „vezme“ trochu rychlosti robota
	var b := Bullet.new().setup(start, vel, dmg, shot_life, true, homing, size)
	room.add_child(b)
	if random_shots and randf() < 0.15:  # občas relé vystřelí rovnou tři
		for a in [-0.25, 0.25]:
			room.add_child(Bullet.new().setup(start, vel.rotated(a), dmg, shot_life, true, homing, size))
	Sfx.play("shoot", -8.0)


func _drop_emp() -> void:
	if emps <= 0 or room == null:
		return
	emps -= 1
	stats_changed.emit()
	var emp := EMP_SCRIPT.new()
	emp.position = position
	room.add_child(emp)


func take_damage(amount: int) -> void:
	if _invulnerable > 0.0 or _dead:
		return
	cells -= amount
	_invulnerable = 1.0
	Sfx.play("hurt")
	Fx.sparks(get_parent(), position, "turquoise", 12)
	if room and room.has_method("shake"):
		room.shake(3.0)
	stats_changed.emit()
	if cells <= 0:
		_die()


func _die() -> void:
	_dead = true
	sprite.visible = true
	sprite.modulate = Color(0.4, 0.4, 0.45)
	velocity = Vector2.ZERO
	Fx.explosion(get_parent(), position, true)
	Sfx.play("explode", 3.0)
	died.emit()


func is_dead() -> bool:
	return _dead


func heal(amount: int) -> bool:
	if cells >= max_cells:
		return false
	cells = mini(cells + amount, max_cells)
	stats_changed.emit()
	return true


## Účinek předmětu (seznam předmětů je v items.gd).
func apply_item(id: String) -> void:
	items.append(id)
	match id:
		"fan":
			fire_delay *= 0.65
		"coil":
			homing += 6.0
		"chip":
			damage *= 1.6
			speed *= 0.9
		"battery":
			max_cells += 1
			cells = max_cells
		"relay":
			random_shots = true
	stats_changed.emit()
