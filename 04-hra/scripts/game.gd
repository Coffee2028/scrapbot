extends Node2D
## Hlavní skript hry. Řídí, co se děje: hlavní menu → hra → pauza → konec pokusu.
## Na začátku pokusu nechá vygenerovat patro (floor_gen.gd), zobrazuje vždy jednu
## místnost (room.gd) a při průchodu dveřmi robota přenese do vedlejší místnosti.

const ROOM := preload("res://scripts/room.gd")
const PLAYER := preload("res://scripts/player.gd")
const HUD := preload("res://scripts/hud.gd")
const MENUS := preload("res://scripts/menus.gd")

const ROOM_OFFSET := Vector2(56, 40)     # místnost leží pod horní lištou, uprostřed
const START_POS := Vector2(136, 88)      # střed místnosti
# kam se robot postaví v nové místnosti podle toho, kterým směrem šel
const ENTRY_POS := {
	Vector2i.UP: Vector2(136, 147),
	Vector2i.DOWN: Vector2(136, 29),
	Vector2i.LEFT: Vector2(243, 88),
	Vector2i.RIGHT: Vector2(29, 88),
}

enum State { TITLE, PLAYING, PAUSED, OVER }

var state := State.TITLE
var rng := RandomNumberGenerator.new()
var rooms := {}                  # data celého patra (z FloorGen)
var current := Vector2i.ZERO     # souřadnice aktuální místnosti v mřížce
var room: Node2D
var player: CharacterBody2D
var world: Node2D                # obsahuje místnost a robota; při otřesu se posouvá
var hud: CanvasLayer
var menus: CanvasLayer
var fade: ColorRect
var _shake := 0.0
var _moving := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS         # menu musí fungovat i při pauze
	world = Node2D.new()
	world.position = ROOM_OFFSET
	world.y_sort_enabled = true                     # kdo je níž, je vykreslen před ostatními
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)

	hud = HUD.new()
	hud.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(hud)
	menus = MENUS.new()
	add_child(menus)
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 20
	add_child(fade_layer)
	fade = ColorRect.new()
	fade.color = Color(0.03, 0.03, 0.05)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.modulate.a = 0.0
	fade_layer.add_child(fade)

	menus.play_pressed.connect(start_run)
	menus.resume_pressed.connect(resume)
	menus.restart_pressed.connect(_restart)
	menus.menu_pressed.connect(go_to_menu)
	menus.quit_pressed.connect(func(): get_tree().quit())
	go_to_menu()


func _process(delta: float) -> void:
	# otřes obrazovky: náhodně posuneme celý svět a postupně se uklidní
	if _shake > 0.0:
		_shake = move_toward(_shake, 0.0, 22.0 * delta)
		world.position = ROOM_OFFSET + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
	else:
		world.position = ROOM_OFFSET


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if event.is_action_pressed("pause"):
		if state == State.PLAYING:
			pause()
		elif state == State.PAUSED:
			resume()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Stats.end_run("vzdal")       # i zavření okna se zapíše do statistik


# ---------- průběh pokusu ----------

func start_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	menus.hide_all()
	_clear_world()
	rng.randomize()
	rooms = FloorGen.generate(rng)["rooms"]

	player = PLAYER.new()
	player.stats_changed.connect(func(): hud.update_player(player))
	player.died.connect(_on_player_died)
	world.add_child(player)

	Stats.start_run()
	hud.visible = true
	hud.hide_boss()
	hud.set_run(Stats.run_number)
	hud.update_player(player)
	_enter_room(Vector2i.ZERO, START_POS)
	state = State.PLAYING
	hud.show_banner("Najdi a znič Kladivo!", 2.0)


func _restart() -> void:
	Stats.end_run("vzdal")          # když už pokus skončil, nic se nezapíše podruhé
	start_run()


func go_to_menu() -> void:
	if state == State.PLAYING or state == State.PAUSED:
		Stats.end_run("vzdal")
	get_tree().paused = false
	Engine.time_scale = 1.0
	_clear_world()
	hud.visible = false
	state = State.TITLE
	menus.show_title()


func pause() -> void:
	state = State.PAUSED
	get_tree().paused = true
	menus.show_pause()


func resume() -> void:
	state = State.PLAYING
	get_tree().paused = false
	menus.hide_all()


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _clear_world() -> void:
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	room = null
	player = null


# ---------- místnosti ----------

func _enter_room(pos: Vector2i, player_pos: Vector2) -> void:
	if room:
		world.remove_child(room)
		room.queue_free()
	current = pos
	var data: Dictionary = rooms[pos]
	data["visited"] = true
	room = ROOM.new()
	room.build(data, player, self)
	room.door_entered.connect(_on_door_entered)
	room.hatch_entered.connect(_on_hatch_entered)
	world.add_child(room)
	player.position = player_pos
	player.velocity = Vector2.ZERO
	player.room = room
	room.start()
	hud.update_map(rooms, current)
	hud.show_hint(pos == Vector2i.ZERO)
	match data["type"]:
		"treasure":
			if not data["items"].is_empty():
				hud.show_banner("Pokladová místnost", 1.5)
		"shop":
			hud.show_banner("Obchod: plať šrouby", 1.5)


## Robot vešel do otevřených dveří: krátké ztmavnutí a přesun do vedlejší místnosti.
func _on_door_entered(dir: Vector2i) -> void:
	if _moving or state != State.PLAYING:
		return
	_moving = true
	player.controls_locked = true
	var tw := create_tween()
	tw.tween_property(fade, "modulate:a", 1.0, 0.12)
	tw.tween_callback(_enter_room.bind(current + dir, ENTRY_POS[dir]))
	tw.tween_property(fade, "modulate:a", 0.0, 0.15)
	tw.tween_callback(_finish_move)


func _finish_move() -> void:
	_moving = false
	if is_instance_valid(player):
		player.controls_locked = false


# ---------- události z místností ----------

func on_boss_appeared(boss: Node) -> void:
	hud.show_boss(boss)
	hud.show_banner("KLADIVO", 1.5)


func on_boss_defeated() -> void:
	Sfx.play("boss_die")
	shake(7.0)
	# krátké zpomalení času, ať je vidět, jak vozík vybuchuje
	Engine.time_scale = 0.3
	get_tree().create_timer(0.9, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)
	hud.show_banner("Kladivo poraženo! Vstup do poklopu.", 3.0)


func on_item_taken(id: String) -> void:
	var item: Dictionary = Items.ALL[id]
	hud.show_banner("%s\n%s" % [item["name"], item["desc"]], 2.5)


func _on_hatch_entered() -> void:
	if state != State.PLAYING:
		return
	state = State.OVER
	player.controls_locked = true
	Stats.end_run("vyhra")
	var tw := create_tween()
	tw.tween_property(fade, "modulate:a", 0.6, 0.4)
	tw.tween_callback(func():
		fade.modulate.a = 0.0
		get_tree().paused = true
		menus.show_victory(Stats.items_taken))


func _on_player_died() -> void:
	if state != State.PLAYING:
		return
	state = State.OVER
	Stats.end_run("smrt")
	shake(6.0)
	get_tree().create_timer(1.2, true, false, true).timeout.connect(func():
		if state == State.OVER:
			get_tree().paused = true
			menus.show_game_over(Stats.rooms_cleared, Stats.items_taken))
