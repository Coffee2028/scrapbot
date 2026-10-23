extends Node
## Zvukové efekty. Kdekoli ve hře stačí napsat Sfx.play("shoot").

const SOUNDS := {
	"shoot": preload("res://assets/sfx/shoot.wav"),
	"enemy_shoot": preload("res://assets/sfx/enemy_shoot.wav"),
	"hit": preload("res://assets/sfx/hit.wav"),
	"explode": preload("res://assets/sfx/explode.wav"),
	"hurt": preload("res://assets/sfx/hurt.wav"),
	"pickup": preload("res://assets/sfx/pickup.wav"),
	"item": preload("res://assets/sfx/item.wav"),
	"door": preload("res://assets/sfx/door.wav"),
	"emp": preload("res://assets/sfx/emp.wav"),
	"boss_charge": preload("res://assets/sfx/boss_charge.wav"),
	"boss_die": preload("res://assets/sfx/boss_die.wav"),
	"blip": preload("res://assets/sfx/blip.wav"),
}

var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # zvuky menu hrají i při pauze
	for i in 14:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func play(sound: String, volume_db := 0.0, pitch_jitter := 0.08) -> void:
	var stream: AudioStream = SOUNDS.get(sound)
	if stream == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
			p.play()
			return
