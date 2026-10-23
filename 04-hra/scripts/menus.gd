extends CanvasLayer
## Obrazovky mimo hru: hlavní menu, pauza, zničení robota a vítězství.
## Ovládají se myší, klávesnicí (šipky + Enter) i ovladačem (D-pad + A).

signal play_pressed
signal resume_pressed
signal restart_pressed
signal menu_pressed
signal quit_pressed

const T_PLAYER := preload("res://assets/sprites/player.png")
const TURQUOISE := Color(0.1, 0.9, 0.82)
const ORANGE := Color(0.95, 0.45, 0.17)
const ROBOT_Y := 80.0

var screen: Control
var theme_res: Theme
var _robot: TextureRect
var _t := 0.0


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme_res = _make_theme()


func _process(delta: float) -> void:
	_t += delta
	if is_instance_valid(_robot):
		_robot.position.y = ROBOT_Y + sin(_t * 2.5) * 3.0


func hide_all() -> void:
	if is_instance_valid(screen):
		screen.queue_free()
	screen = null


# ---------- obrazovky ----------

func show_title() -> void:
	var box := _new_screen(Color(0.04, 0.045, 0.065, 1.0))
	_robot = TextureRect.new()
	_robot.texture = T_PLAYER
	_robot.size = Vector2(48, 48)
	_robot.stretch_mode = TextureRect.STRETCH_SCALE
	_robot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_robot.position = Vector2(168, ROBOT_Y)
	screen.add_child(_robot)
	_text(box, "SCRAPBOT", 30, TURQUOISE)
	_text(box, "CESTA DO JÁDRA", 8, Color(0.7, 0.75, 0.82))
	_spacer(box, 56)
	var play := _button(box, "HRÁT", play_pressed)
	_button(box, "KONEC", quit_pressed)
	var info := "Pokusů celkem: %d" % Stats.total_runs
	if Stats.boss_kills > 0:
		info += "   ·   Kladivo poraženo: %d×" % Stats.boss_kills
	_spacer(box, 4)
	_text(box, info, 6, Color(0.5, 0.55, 0.62))
	_text(box, Controls.hint(), 6, Color(0.5, 0.55, 0.62))
	_footer("Prototyp v0.1  ·  4ITE PHR  ·  Jakub Steinz (Coffee2028)")
	play.grab_focus()


func show_pause() -> void:
	var box := _new_screen(Color(0.02, 0.02, 0.04, 0.82))
	_text(box, "PAUZA", 20, TURQUOISE)
	_text(box, "Pokus #%d   ·   %s" % [Stats.run_number, Stats.format_time(Stats.run_seconds())], 6, Color(0.6, 0.65, 0.72))
	_spacer(box, 8)
	var resume := _button(box, "POKRAČOVAT", resume_pressed)
	_button(box, "NOVÝ POKUS", restart_pressed)
	var stats_btn := _button(box, "SLOŽKA SE STATISTIKAMI", Signal())
	stats_btn.pressed.connect(Stats.open_folder)
	_button(box, "HLAVNÍ MENU", menu_pressed)
	_spacer(box, 4)
	_text(box, Controls.hint(), 6, Color(0.5, 0.55, 0.62))
	resume.grab_focus()


func show_game_over(rooms: int, items: Array[String]) -> void:
	var box := _new_screen(Color(0.06, 0.02, 0.02, 0.85))
	_text(box, "ROBOT ZNIČEN", 20, ORANGE)
	_text(box, "Pokus #%d   ·   čas %s   ·   vyčištěno místností: %d" % [
		Stats.run_number, Stats.format_time(Stats.run_seconds()), rooms], 6, Color(0.8, 0.8, 0.85))
	if not items.is_empty():
		_text(box, "Předměty: " + ", ".join(items), 6, Color(0.6, 0.65, 0.72))
	_spacer(box, 8)
	var again := _button(box, "ZNOVU", restart_pressed)
	_button(box, "HLAVNÍ MENU", menu_pressed)
	_delay_focus(box, again)


func show_victory(items: Array[String]) -> void:
	var box := _new_screen(Color(0.02, 0.05, 0.05, 0.88))
	_text(box, "PATRO 1 VYČIŠTĚNO", 18, TURQUOISE)
	_text(box, "Kladivo poraženo v pokusu #%d za %s" % [
		Stats.run_number, Stats.format_time(Stats.run_seconds())], 8, Color(0.9, 0.92, 0.95))
	if not items.is_empty():
		_text(box, "Předměty: " + ", ".join(items), 6, Color(0.6, 0.65, 0.72))
	_text(box, "V plné verzi cesta pokračuje do Lakovny, Slévárny a Jádra.", 6, Color(0.6, 0.65, 0.72))
	_spacer(box, 8)
	var again := _button(box, "NOVÝ POKUS", restart_pressed)
	_button(box, "HLAVNÍ MENU", menu_pressed)
	_delay_focus(box, again)


# ---------- pomocné funkce ----------

func _new_screen(bg: Color) -> VBoxContainer:
	hide_all()
	screen = Control.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.theme = theme_res
	add_child(screen)
	var back := ColorRect.new()
	back.color = bg
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(back)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 3)
	screen.add_child(box)
	screen.modulate.a = 0.0
	screen.create_tween().tween_property(screen, "modulate:a", 1.0, 0.2)
	return box


func _text(box: Control, text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.label_settings = Fx.small_text(color, size)
	box.add_child(l)
	return l


func _spacer(box: Control, height: float) -> void:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	box.add_child(c)


func _button(box: Control, text: String, sig: Signal) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(120, 16)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if not sig.is_null():
		b.pressed.connect(func(): sig.emit())
	b.pressed.connect(func(): Sfx.play("blip"))
	b.focus_entered.connect(func(): Sfx.play("blip", -10.0, 0.0))
	box.add_child(b)
	return b


func _footer(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.label_settings = Fx.small_text(Color(0.35, 0.38, 0.45), 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, 204)
	l.size = Vector2(384, 10)
	screen.add_child(l)


## Po zničení robota chvíli počká, než jde tlačítko zmáčknout
## (aby hráč, který právě drží „střelbu dolů“ = A, omylem hned nezačal znovu).
func _delay_focus(box: Control, button: Button) -> void:
	for c in box.get_children():
		if c is Button:
			c.disabled = true
	await get_tree().create_timer(0.8, true, false, true).timeout
	if not is_instance_valid(button):
		return
	for c in box.get_children():
		if c is Button:
			c.disabled = false
	button.grab_focus()


func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 8
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.1, 0.11, 0.15, 0.95)
	normal.border_color = Color(0.25, 0.27, 0.33)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.content_margin_top = 3
	normal.content_margin_bottom = 3
	var focus := normal.duplicate()
	focus.bg_color = Color(0.06, 0.3, 0.29, 0.95)
	focus.border_color = TURQUOISE
	var pressed := focus.duplicate()
	pressed.bg_color = Color(0.1, 0.55, 0.5)
	for state in ["normal", "disabled"]:
		t.set_stylebox(state, "Button", normal)
	t.set_stylebox("hover", "Button", focus)
	t.set_stylebox("focus", "Button", focus)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_color("font_color", "Button", Color(0.85, 0.88, 0.93))
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_focus_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color(0.45, 0.48, 0.55))
	return t
