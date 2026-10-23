extends Node2D
## EMP nálož: chvíli bliká, pak vybuchne. Zraní nepřátele v okolí
## a rozbije bedny. Robotovi samotnému neublíží.

const TEX := preload("res://assets/sprites/pickup_emp.png")
const RADIUS := 42.0
const DAMAGE := 6.0

var fuse := 0.9
var sprite: Sprite2D
var _exploded := false
var _ring := 0.0


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = TEX
	add_child(sprite)
	z_index = 2


func _process(delta: float) -> void:
	if _exploded:
		_ring += delta
		queue_redraw()
		if _ring > 0.35:
			queue_free()
		return
	fuse -= delta
	sprite.scale = Vector2.ONE * (1.0 + 0.25 * sin(fuse * 30.0))
	sprite.modulate = Color(2, 2, 2) if int(fuse * 12) % 2 == 0 else Color.WHITE
	if fuse <= 0.0:
		_explode()


func _explode() -> void:
	_exploded = true
	sprite.visible = false
	Sfx.play("emp")
	Fx.sparks(get_parent(), position, "violet", 24, 130.0)
	var room := get_parent()
	if room and room.has_method("shake"):
		room.shake(5.0)
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.global_position.distance_to(global_position) <= RADIUS + 8.0:
			e.hit(DAMAGE, global_position.direction_to(e.global_position))
	for crate in get_tree().get_nodes_in_group("crates"):
		if crate.global_position.distance_to(global_position) <= RADIUS:
			if room and room.has_method("break_crate"):
				room.break_crate(crate)


func _draw() -> void:
	if _exploded:
		var r := RADIUS * clampf(_ring / 0.2, 0.0, 1.0)
		var a := clampf(1.0 - _ring / 0.35, 0.0, 1.0)
		draw_circle(Vector2.ZERO, r, Color(0.55, 0.4, 1.0, 0.25 * a))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(0.75, 0.6, 1.0, a), 2.0)
