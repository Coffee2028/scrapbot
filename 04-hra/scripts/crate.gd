extends StaticBody2D
## Dřevěná bedna. Robot ji rozstřílí (stačí dva obyčejné zásahy) nebo ji rozbije
## EMP nálož. Střely nepřátel se o ni jen zastaví, takže bedna slouží jako kryt.

const TEX := preload("res://assets/sprites/crate.png")
const TEX_CRACKED := preload("res://assets/sprites/crate_cracked.png")
const MAX_HP := 2.0

var hp := MAX_HP
var room: Node2D
var sprite: Sprite2D


func setup(pos: Vector2, the_room: Node2D) -> void:
	position = pos
	room = the_room


func _ready() -> void:
	collision_layer = 1          # vrstva 1: zdi a bedny
	add_to_group("crates")
	sprite = Sprite2D.new()
	sprite.texture = TEX
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(14, 14)
	shape.shape = r
	add_child(shape)


## Zásah střelou robota. Volá ho bullet.gd stejně jako u nepřátel.
func hit(damage: float, from_dir: Vector2) -> void:
	hp -= damage
	if hp <= 0.0:
		room.break_crate(self)
		return
	sprite.texture = TEX_CRACKED
	Sfx.play("crate", -8.0, 0.15)
	Fx.sparks(room, position - from_dir * 7.0, "wood", 5, 45.0)
	# krátké cuknutí ve směru střely
	sprite.position = from_dir * 1.5
	create_tween().tween_property(sprite, "position", Vector2.ZERO, 0.12)
