extends Node
## Ovládání pro klávesnici i herní ovladač (rozložení Xbox / PlayStation).
## Akce vytváříme tady v kódu, aby bylo celé ovládání vidět na jednom místě.
##
## Klávesnice: WASD pohyb, šipky střelba, E = EMP nálož, Esc = pauza
## Ovladač:    levá páčka / D-pad pohyb, pravá páčka nebo Y/A/X/B střelba,
##             LB/RB nebo spouště = EMP, Start = pauza

signal device_changed(using_pad: bool)

const DEADZONE := 0.3

## true, když hráč naposledy sáhl na ovladač (podle toho ukazujeme nápovědu)
var using_pad := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_add("move_up", [KEY_W], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_add("move_down", [KEY_S], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_add("move_left", [KEY_A], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_add("move_right", [KEY_D], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	# Střelba: šipky, pravá páčka, nebo tlačítka Y/A/X/B (jako v The Binding of Isaac)
	_add("shoot_up", [KEY_UP], [JOY_BUTTON_Y], [[JOY_AXIS_RIGHT_Y, -1.0]])
	_add("shoot_down", [KEY_DOWN], [JOY_BUTTON_A], [[JOY_AXIS_RIGHT_Y, 1.0]])
	_add("shoot_left", [KEY_LEFT], [JOY_BUTTON_X], [[JOY_AXIS_RIGHT_X, -1.0]])
	_add("shoot_right", [KEY_RIGHT], [JOY_BUTTON_B], [[JOY_AXIS_RIGHT_X, 1.0]])
	_add("emp", [KEY_E, KEY_SHIFT], [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER],
		[[JOY_AXIS_TRIGGER_LEFT, 1.0], [JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	_add("pause", [KEY_ESCAPE, KEY_P], [JOY_BUTTON_START], [])


func _input(event: InputEvent) -> void:
	var pad := using_pad
	if event is InputEventJoypadButton:
		pad = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		pad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		pad = false
	if pad != using_pad:
		using_pad = pad
		device_changed.emit(using_pad)


## Vytvoří akci a přidá k ní klávesy, tlačítka ovladače a směry páček.
func _add(action: String, keys: Array, buttons: Array, axes: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action, DEADZONE)
	for key in keys:
		var e := InputEventKey.new()
		e.physical_keycode = key
		InputMap.action_add_event(action, e)
	for button in buttons:
		var e := InputEventJoypadButton.new()
		e.button_index = button
		InputMap.action_add_event(action, e)
	for axis in axes:
		var e := InputEventJoypadMotion.new()
		e.axis = axis[0]
		e.axis_value = axis[1]
		InputMap.action_add_event(action, e)


## Krátký text s ovládáním podle toho, čím hráč zrovna hraje.
func hint() -> String:
	if using_pad:
		return "L páčka: pohyb   P páčka / Y A X B: střelba   LB: EMP   Start: pauza"
	return "WASD: pohyb   Šipky: střelba   E: EMP nálož   Esc: pauza   F11: celá obrazovka"
