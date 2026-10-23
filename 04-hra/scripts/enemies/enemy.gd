class_name Enemy
extends CharacterBody2D
## Společný základ všech nepřátel: životy, zásah, bliknutí, smrt.
## Konkrétní nepřítel (dron, vozík, věžička, boss) si jen dopíše svoje chování do think().

signal died(enemy: Enemy)

var hp := 3.0
var max_hp := 3.0
var texture: Texture2D
var room: Node2D          # místnost, ve které nepřítel je (do ní přidává střely)
var player: Node2D
var sprite: Sprite2D
var radius := 6.0          # velikost těla
var spawn_time := 0.6      # chvíli po příchodu hráče jen bliká a nic nedělá (je to fér)
var knockback := Vector2.ZERO
var _flash := 0.0
var _dead := false


func setup(the_room: Node2D, the_player: Node2D) -> void:
	room = the_room
	player = the_player


func _ready() -> void:
	max_hp = hp
	sprite = Sprite2D.new()
	sprite.texture = texture
	add_child(sprite)
	var shape := CollisionShape2D.new()
	shape.shape = make_shape()
	add_child(shape)
	collision_layer = 4      # vrstva 3: nepřátelé
	collision_mask = 1       # narážejí jen do zdí a beden
	add_to_group("enemies")


func make_shape() -> Shape2D:
	var c := CircleShape2D.new()
	c.radius = radius
	return c


func _physics_process(delta: float) -> void:
	if _dead:
		return
	if _flash > 0.0:
		_flash -= delta
		sprite.modulate = Color(3, 3, 3) if _flash > 0.0 else Color.WHITE
	if spawn_time > 0.0:
		spawn_time -= delta
		sprite.visible = int(spawn_time * 20) % 2 == 0 or spawn_time <= 0.0
		return
	think(delta)
	velocity += knockback
	knockback = knockback.lerp(Vector2.ZERO, clampf(12.0 * delta, 0.0, 1.0))
	move_and_slide()


## Chování nepřítele – přepisuje ho každý typ nepřítele.
func think(_delta: float) -> void:
	pass


func is_active() -> bool:
	return spawn_time <= 0.0 and not _dead


func direction_to_player() -> Vector2:
	if player == null:
		return Vector2.ZERO
	return global_position.direction_to(player.global_position)


## Zásah střelou nebo EMP náloží.
func hit(damage: float, from_dir := Vector2.ZERO) -> void:
	if _dead:
		return
	hp -= damage
	_flash = 0.08
	knockback += from_dir * 60.0
	Sfx.play("hit", -4.0)
	if hp <= 0.0:
		die()


func die() -> void:
	if _dead:
		return
	_dead = true
	remove_from_group("enemies")
	Sfx.play("explode")
	Fx.explosion(get_parent(), position)
	died.emit(self)
	queue_free()


## Vystřelí nepřátelskou střelu daným směrem.
func shoot(dir: Vector2, speed := 70.0, life := 3.0) -> void:
	if room == null:
		return
	var b := Bullet.new().setup(position + dir * radius, dir * speed, 1.0, life, false)
	room.add_child(b)
