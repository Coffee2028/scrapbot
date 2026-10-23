extends Area2D
## Věci na zemi: článek baterie (+1 život), šroub (peníze), EMP nálož.
## V obchodě mají cenu ve šroubech.

signal collected(pickup)

const TEXTURES := {
	"battery": preload("res://assets/sprites/pickup_battery.png"),
	"screw": preload("res://assets/sprites/pickup_screw.png"),
	"emp": preload("res://assets/sprites/pickup_emp.png"),
}

var data: Dictionary          # záznam v datech místnosti: {"kind", "pos", "price"}
var sprite: Sprite2D
var _t := 0.0
var _cooldown := 0.0


func setup(pickup_data: Dictionary) -> void:
	data = pickup_data
	position = data["pos"]


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = TEXTURES[data["kind"]]
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 7.0
	shape.shape = c
	add_child(shape)
	collision_layer = 32
	collision_mask = 2
	body_entered.connect(_on_body)
	_t = randf() * TAU
	if data.get("price", 0) > 0:
		var label := Label.new()
		label.text = Fx.screws(data["price"])
		label.label_settings = Fx.small_text(Color(1, 0.8, 0.2))
		label.position = Vector2(-30, 6)
		label.size = Vector2(60, 10)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(label)
	# při vypadnutí z nepřítele malý poskok
	scale = Vector2(0.3, 0.3)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)


func _process(delta: float) -> void:
	_t += delta
	_cooldown -= delta
	sprite.position.y = sin(_t * 4.0) * 1.0


func _on_body(body: Node) -> void:
	if body.has_method("apply_item"):
		_try_collect(body)


func _try_collect(player) -> void:
	var price: int = data.get("price", 0)
	if price > player.screws:
		if _cooldown <= 0.0:
			_cooldown = 1.0
			Fx.float_text(get_parent(), position, "Málo šroubů", Color(1, 0.5, 0.4))
		return
	var ok := true
	match data["kind"]:
		"battery":
			ok = player.heal(1)
			if not ok and _cooldown <= 0.0:
				_cooldown = 1.0
				Fx.float_text(get_parent(), position, "Baterie je plná", Color(0.7, 0.9, 1))
		"screw":
			player.screws += 1
		"emp":
			player.emps += 1
	if not ok:
		return
	player.screws -= price
	player.stats_changed.emit()
	Sfx.play("pickup")
	Fx.sparks(get_parent(), position, "white", 6, 40.0)
	collected.emit(self)
	queue_free()
