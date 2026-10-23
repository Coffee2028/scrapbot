extends Area2D
## Podstavec s předmětem (v pokladové místnosti zdarma, v obchodě za šrouby).

signal taken(pedestal)

const TEX_PEDESTAL := preload("res://assets/sprites/pedestal.png")

var data: Dictionary          # {"id", "pos", "price"}
var item_sprite: Sprite2D
var _t := 0.0
var _cooldown := 0.0


func setup(item_data: Dictionary) -> void:
	data = item_data
	position = data["pos"]


func _ready() -> void:
	var base := Sprite2D.new()
	base.texture = TEX_PEDESTAL
	base.position = Vector2(0, 4)
	add_child(base)
	item_sprite = Sprite2D.new()
	item_sprite.texture = Items.ALL[data["id"]]["icon"]
	item_sprite.position = Vector2(0, -6)
	add_child(item_sprite)
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(14, 16)
	shape.shape = r
	add_child(shape)
	collision_layer = 32
	collision_mask = 2
	body_entered.connect(_on_body)
	if data.get("price", 0) > 0:
		var label := Label.new()
		label.text = Fx.screws(data["price"])
		label.label_settings = Fx.small_text(Color(1, 0.8, 0.2))
		label.position = Vector2(-30, 12)
		label.size = Vector2(60, 10)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(label)
	# blokuje cestu jako malá bedna, aby do něj robot jen „ťukl“
	var solid := StaticBody2D.new()
	var sshape := CollisionShape2D.new()
	var sr := RectangleShape2D.new()
	sr.size = Vector2(10, 6)
	sshape.shape = sr
	sshape.position = Vector2(0, 6)
	solid.add_child(sshape)
	add_child(solid)


func _process(delta: float) -> void:
	_t += delta
	_cooldown -= delta
	item_sprite.position.y = -7.0 + sin(_t * 3.0) * 1.5


func _on_body(body: Node) -> void:
	if not body.has_method("apply_item"):
		return
	var price: int = data.get("price", 0)
	if price > body.screws:
		if _cooldown <= 0.0:
			_cooldown = 1.0
			Fx.float_text(get_parent(), position + Vector2(0, -10), "Málo šroubů", Color(1, 0.5, 0.4))
		return
	body.screws -= price
	body.apply_item(data["id"])
	Stats.items_taken.append(Items.ALL[data["id"]]["name"])
	Sfx.play("item")
	Fx.sparks(get_parent(), position, "turquoise", 18, 90.0)
	taken.emit(self)
	queue_free()
