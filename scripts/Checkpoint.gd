extends Area2D

var active := false
var _time := 0.0

func _ready() -> void:
	body_entered.connect(_activate)
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta; queue_redraw()

func _activate(body: Node) -> void:
	if not body.has_method("set_checkpoint"): return
	if not active:
		AudioManager.play_sfx("checkpoint")
		get_tree().call_group("checkpoints", "deactivate")
	active = true
	body.set_checkpoint(global_position + Vector2(0,-28))
	queue_redraw()

func deactivate() -> void:
	active = false; queue_redraw()

func _draw() -> void:
	var color := Color("5dfff1") if active else Color("8067bd")
	var bob := sin(_time*2.0)*3.0
	var pts := PackedVector2Array([Vector2(0,-22+bob),Vector2(10,-8+bob),Vector2(0,7+bob),Vector2(-10,-8+bob)])
	draw_colored_polygon(pts,color)
	draw_circle(Vector2(0,-8+bob),22,Color(color,0.12))
	draw_line(Vector2(0,8),Vector2(0,18),color,3)
	draw_arc(Vector2(0,19),13,PI,TAU,18,color,3)

