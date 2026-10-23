class_name Fx
## Drobné efekty: jiskry, výbuchy a plovoucí text. Všechno se po dohrání samo smaže.

const SPARK_COLORS := {
	"turquoise": Color(0.1, 0.9, 0.82),
	"orange": Color(0.95, 0.45, 0.15),
	"yellow": Color(1.0, 0.8, 0.2),
	"white": Color(0.95, 0.95, 1.0),
	"violet": Color(0.6, 0.4, 1.0),
	"wood": Color(0.62, 0.42, 0.24),
}


## Jiskry: krátký výbuch malých čtverečků.
static func sparks(parent: Node, pos: Vector2, color := "yellow", amount := 10, speed := 70.0) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var p := CPUParticles2D.new()
	p.position = pos
	p.amount = amount
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 0.35
	p.direction = Vector2.UP
	p.spread = 180.0
	p.gravity = Vector2(0, 160)
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.0
	p.color = SPARK_COLORS.get(color, Color.WHITE)
	p.z_index = 5
	p.emitting = true
	p.finished.connect(p.queue_free)
	parent.add_child(p)


## Větší výbuch: jiskry dvou barev.
static func explosion(parent: Node, pos: Vector2, big := false) -> void:
	sparks(parent, pos, "orange", 26 if big else 14, 120.0 if big else 80.0)
	sparks(parent, pos, "yellow", 14 if big else 8, 90.0 if big else 60.0)


## Text, který vyletí nahoru a zmizí (třeba „+1“ nebo „Málo šroubů“).
static func float_text(parent: Node, pos: Vector2, text: String, color := Color.WHITE) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var label := Label.new()
	label.text = text
	label.label_settings = small_text(color)
	label.position = pos + Vector2(-40, -14)
	label.size = Vector2(80, 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 20
	parent.add_child(label)
	var tw := label.create_tween()
	tw.tween_property(label, "position:y", label.position.y - 14, 0.8)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tw.tween_callback(label.queue_free)


## Správný tvar slova: 1 šroub, 2–4 šrouby, 5 a víc šroubů.
static func screws(n: int) -> String:
	if n == 1:
		return "1 šroub"
	if n >= 2 and n <= 4:
		return "%d šrouby" % n
	return "%d šroubů" % n


static func small_text(color := Color.WHITE, size := 8) -> LabelSettings:
	var s := LabelSettings.new()
	s.font_size = size
	s.font_color = color
	s.outline_size = 3
	s.outline_color = Color(0.05, 0.05, 0.08)
	return s
