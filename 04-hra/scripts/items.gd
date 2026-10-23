class_name Items
## Předměty (vylepšení robota). Co přesně dělají, je v player.gd ve funkci apply_item().

const ALL := {
	"fan": {
		"name": "Turbo ventilátor",
		"desc": "Rychlejší střelba",
		"icon": preload("res://assets/sprites/item_fan.png"),
	},
	"coil": {
		"name": "Magnetická cívka",
		"desc": "Střely se stáčejí k nepřátelům",
		"icon": preload("res://assets/sprites/item_coil.png"),
	},
	"chip": {
		"name": "Přetaktovaný čip",
		"desc": "Větší poškození, ale robot je pomalejší",
		"icon": preload("res://assets/sprites/item_chip.png"),
	},
	"battery": {
		"name": "Záložní baterie",
		"desc": "Jeden článek baterie navíc",
		"icon": preload("res://assets/sprites/item_battery.png"),
	},
	"relay": {
		"name": "Zaseknuté relé",
		"desc": "Každý výstřel je jiný",
		"icon": preload("res://assets/sprites/item_relay.png"),
	},
}
