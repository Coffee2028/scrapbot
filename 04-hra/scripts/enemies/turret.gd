extends Enemy
## Rotující věžička: stojí na místě a střílí do čtyř směrů.
## Každá další salva je pootočená o 45°, takže vzniká „bullet hell“ vzor.

const TEX := preload("res://assets/sprites/turret.png")
const FIRE_EVERY := 1.6

var cooldown := 1.0
var angle := 0.0


func _init() -> void:
	hp = 5.0
	texture = TEX
	radius = 7.0


func _ready() -> void:
	super._ready()
	cooldown = randf_range(0.6, 1.4)


func think(delta: float) -> void:
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO       # věžička je přišroubovaná k podlaze
	cooldown -= delta
	if cooldown <= 0.3:
		sprite.modulate = Color(1.8, 1.3, 1.0)   # chvíli před výstřelem se rozsvítí
	if cooldown <= 0.0:
		sprite.modulate = Color.WHITE
		cooldown = FIRE_EVERY
		for i in 4:
			shoot(Vector2.RIGHT.rotated(angle + i * PI / 2.0), 62.0)
		Sfx.play("enemy_shoot", -6.0)
		angle += PI / 4.0
		sprite.rotation = angle
