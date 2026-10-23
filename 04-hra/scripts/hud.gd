extends CanvasLayer
## Horní lišta během hry: baterie (životy), šrouby, EMP nálože, název patra,
## číslo pokusu, minimapa, ukazatel životů bosse a krátké zprávy.

const T_CELL_FULL := preload("res://assets/sprites/hud_cell_full.png")
const T_CELL_EMPTY := preload("res://assets/sprites/hud_cell_empty.png")
const T_SCREW := preload("res://assets/sprites/pickup_screw.png")
const T_EMP := preload("res://assets/sprites/pickup_emp.png")
const MINIMAP := preload("res://scripts/minimap.gd")

var cells_box: HBoxContainer
var screws_label: Label
var emps_label: Label
var title_label: Label
var run_label: Label
var banner: Label
var hint_label: Label
var minimap: Control
var boss_box: Control
var boss_bar: ProgressBar
var boss: Node
var _banner_tween: Tween


func _ready() -> void:
	layer = 5
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	cells_box = HBoxContainer.new()
	cells_box.position = Vector2(8, 6)
	cells_box.add_theme_constant_override("separation", 2)
	root.add_child(cells_box)

	var screw_icon := TextureRect.new()
	screw_icon.texture = T_SCREW
	screw_icon.position = Vector2(8, 20)
	root.add_child(screw_icon)
	screws_label = _label(root, Vector2(19, 18), "0")
	var emp_icon := TextureRect.new()
	emp_icon.texture = T_EMP
	emp_icon.position = Vector2(40, 19)
	root.add_child(emp_icon)
	emps_label = _label(root, Vector2(53, 18), "1")

	title_label = _label(root, Vector2(92, 4), "PATRO 1 · SKLAD", 8, Color(0.85, 0.88, 0.95))
	title_label.size = Vector2(200, 10)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	run_label = _label(root, Vector2(92, 15), "", 6, Color(0.55, 0.6, 0.68))
	run_label.size = Vector2(200, 10)
	run_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	boss_box = Control.new()
	boss_box.position = Vector2(132, 26)
	boss_box.visible = false
	root.add_child(boss_box)
	var boss_name := _label(boss_box, Vector2(0, -2), "KLADIVO", 6, Color(1, 0.55, 0.3))
	boss_name.size = Vector2(120, 8)
	boss_bar = ProgressBar.new()
	boss_bar.show_percentage = false
	boss_bar.position = Vector2(34, 1)
	boss_bar.size = Vector2(86, 5)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.13)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.9, 0.38, 0.17)
	boss_bar.add_theme_stylebox_override("background", bg)
	boss_bar.add_theme_stylebox_override("fill", fill)
	boss_box.add_child(boss_bar)

	minimap = MINIMAP.new()
	minimap.position = Vector2(326, 5)
	minimap.size = Vector2(56, 35)
	root.add_child(minimap)

	banner = _label(root, Vector2(56, 52), "", 8, Color(1, 1, 1))
	banner.size = Vector2(272, 24)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.modulate.a = 0.0

	hint_label = _label(root, Vector2(56, 26), "", 6, Color(0.7, 0.75, 0.82))
	hint_label.size = Vector2(272, 10)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Controls.device_changed.connect(func(_pad): _refresh_hint())


func _label(parent: Node, pos: Vector2, text: String, size := 8, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.label_settings = Fx.small_text(color, size)
	parent.add_child(l)
	return l


func _process(_delta: float) -> void:
	if boss_box.visible:
		if is_instance_valid(boss):
			boss_bar.value = boss.hp
		else:
			boss_box.visible = false
			title_label.visible = true


func update_player(player: Node) -> void:
	for c in cells_box.get_children():
		c.queue_free()
	for i in player.max_cells:
		var t := TextureRect.new()
		t.texture = T_CELL_FULL if i < player.cells else T_CELL_EMPTY
		cells_box.add_child(t)
	screws_label.text = str(player.screws)
	emps_label.text = str(player.emps)


func set_run(run_number: int) -> void:
	run_label.text = "Pokus #%d" % run_number


func update_map(rooms: Dictionary, current: Vector2i) -> void:
	minimap.update_map(rooms, current)


func show_boss(the_boss: Node) -> void:
	boss = the_boss
	boss_bar.max_value = boss.max_hp if boss.max_hp > 0.0 else boss.hp
	boss_bar.value = boss.hp
	boss_box.visible = true
	title_label.visible = false


func hide_boss() -> void:
	boss = null
	boss_box.visible = false
	title_label.visible = true


## Krátká zpráva uprostřed nahoře (např. název sebraného předmětu).
func show_banner(text: String, seconds := 2.5) -> void:
	banner.text = text
	if _banner_tween:
		_banner_tween.kill()
	banner.modulate.a = 1.0
	_banner_tween = create_tween()
	_banner_tween.tween_interval(seconds)
	_banner_tween.tween_property(banner, "modulate:a", 0.0, 0.5)


func show_hint(visible_now: bool) -> void:
	hint_label.visible = visible_now
	_refresh_hint()


func _refresh_hint() -> void:
	hint_label.text = Controls.hint()
