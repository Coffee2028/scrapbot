extends Control
## Minimapa patra v pravém horním rohu.
## Navštívené místnosti jsou světlé, sousední (viděné přes dveře) tmavé,
## aktuální tyrkysová. Boss = červená tečka, poklad = žlutá, obchod = zelená.

const CELL := Vector2(7, 4)
const GAP := 1.0
const LIMIT := 3

var rooms := {}
var current := Vector2i.ZERO


func update_map(the_rooms: Dictionary, current_pos: Vector2i) -> void:
	rooms = the_rooms
	current = current_pos
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2(-2, -2), size + Vector2(4, 4)), Color(0, 0, 0, 0.35))
	for pos in rooms:
		var r: Dictionary = rooms[pos]
		var known: bool = r["visited"] or _next_to_visited(pos)
		if not known:
			continue
		var p := Vector2(pos.x + LIMIT, pos.y + LIMIT) * (CELL + Vector2(GAP, GAP))
		var color := Color(0.22, 0.24, 0.3)
		if r["visited"]:
			color = Color(0.62, 0.66, 0.72)
		if pos == current:
			color = Color(0.1, 0.9, 0.82)
		draw_rect(Rect2(p, CELL), color)
		var icon := Color.TRANSPARENT
		match r["type"]:
			"boss":
				icon = Color(0.9, 0.2, 0.25)
			"treasure":
				icon = Color(1.0, 0.8, 0.2)
			"shop":
				icon = Color(0.35, 0.85, 0.4)
		if icon.a > 0.0:
			draw_rect(Rect2(p + CELL / 2.0 - Vector2(1, 1), Vector2(2, 2)), icon)


func _next_to_visited(pos: Vector2i) -> bool:
	for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var n: Vector2i = pos + d
		if rooms.has(n) and rooms[n]["visited"]:
			return true
	return false
