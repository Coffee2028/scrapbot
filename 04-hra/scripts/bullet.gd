class_name Bullet
extends Area2D
## Střela robota i nepřátel. Letí rovně (nebo se stáčí k nepříteli s magnetickou cívkou)
## a zmizí, když do něčeho narazí nebo doletí.

const TEX_PLAYER := preload("res://assets/sprites/bullet_player.png")
const TEX_ENEMY := preload("res://assets/sprites/bullet_enemy.png")

var velocity := Vector2.ZERO
var damage := 1.0
var life := 0.7
var from_player := true
var homing := 0.0        # jak silně se stáčí k nepříteli (0 = vůbec)
var _done := false


func setup(pos: Vector2, vel: Vector2, dmg: float, lifetime: float, by_player: bool,
		homing_strength := 0.0, size := 1.0) -> Bullet:
	position = pos
	velocity = vel
	damage = dmg
	life = lifetime
	from_player = by_player
	homing = homing_strength
	scale = Vector2.ONE * size
	return self


func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = TEX_PLAYER if from_player else TEX_ENEMY
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 2.5
	shape.shape = circle
	add_child(shape)
	# vrstvy: robot střílí na zdi (1) a nepřátele (3), nepřátelé na zdi (1) a robota (2)
	collision_layer = 8 if from_player else 16
	collision_mask = (1 | 4) if from_player else (1 | 2)
	body_entered.connect(_on_body_entered)
	add_to_group("bullets")


func _physics_process(delta: float) -> void:
	if homing > 0.0:
		var target := _nearest_enemy()
		if target:
			var wanted := (target.global_position - global_position).normalized() * velocity.length()
			velocity = velocity.lerp(wanted, clampf(homing * delta, 0.0, 1.0))
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		pop()


func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_d := 110.0
	for e in get_tree().get_nodes_in_group("enemies"):
		var d := global_position.distance_to(e.global_position)
		if d < best_d:
			best = e
			best_d = d
	return best


func _on_body_entered(body: Node) -> void:
	if _done:
		return
	if from_player and body.has_method("hit"):
		body.hit(damage, velocity.normalized())
	elif not from_player and body.has_method("take_damage"):
		body.take_damage(1)
	pop()


## Zánik střely s malým zábleskem.
func pop() -> void:
	if _done:
		return
	_done = true
	Fx.sparks(get_parent(), position, "turquoise" if from_player else "orange", 4, 40.0)
	queue_free()
