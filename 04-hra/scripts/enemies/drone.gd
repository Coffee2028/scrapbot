extends Enemy
## Svářecí dron: pomalu letí k robotovi a kličkuje ze strany na stranu.
## Zraní dotykem.

const TEX := preload("res://assets/sprites/drone.png")
const SPEED := 36.0

var _t := 0.0


func _init() -> void:
	hp = 3.0
	texture = TEX
	radius = 6.0


func _ready() -> void:
	super._ready()
	_t = randf() * TAU


func think(delta: float) -> void:
	_t += delta
	var to_player := direction_to_player()
	var side := to_player.orthogonal() * sin(_t * 3.0) * 0.8   # kličkování
	velocity = (to_player + side).normalized() * SPEED
	sprite.position.y = sin(_t * 6.0) * 1.0                     # vznáší se
	sprite.flip_h = to_player.x < 0.0
