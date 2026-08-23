extends Area2D

@export_enum("FRAGMENT", "MEMORY") var collectible_type := 0
@export var collectible_id := ""
@export_multiline var lore_text := ""
var _time := 0.0

func _ready() -> void:
	if SaveManager.has_collectible(collectible_id):
		queue_free(); return
	body_entered.connect(_collect)
	queue_redraw()

func configure(id: String, type: int, lore := "") -> void:
	collectible_id = id; collectible_type = type; lore_text = lore
	if is_inside_tree() and SaveManager.has_collectible(id): queue_free()

func _process(delta: float) -> void:
	_time += delta
	position.y += sin(_time*2.4) * delta * 4.0
	rotation = sin(_time*1.7)*0.12
	queue_redraw()

func _collect(body: Node) -> void:
	if not body.is_in_group("player"): return
	var accepted := SaveManager.collect_fragment(collectible_id) if collectible_type == 0 else SaveManager.collect_memory(collectible_id)
	if not accepted: queue_free(); return
	AudioManager.play_sfx("fragment" if collectible_type == 0 else "memory")
	get_tree().call_group("game_level", "collectible_picked", collectible_type, lore_text)
	set_deferred("monitoring",false)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2.4,2.4), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()

func _draw() -> void:
	if collectible_type == 0:
		var points := PackedVector2Array([Vector2(0,-13),Vector2(9,0),Vector2(0,14),Vector2(-9,0)])
		draw_colored_polygon(points, Color("63f8e9"))
		draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]), Color.WHITE, 2)
		draw_circle(Vector2.ZERO, 19, Color(0.3,1,0.95,0.16))
	else:
		draw_circle(Vector2.ZERO, 10, Color("b38cff"))
		draw_circle(Vector2.ZERO, 17, Color(0.65,0.45,1,0.15))
		draw_arc(Vector2.ZERO, 14, 0, TAU, 24, Color("e4d8ff"), 2)
