extends Area2D

var next_level := 0
var active := true
var _time := 0.0

func _ready() -> void:
	body_entered.connect(_entered)
	queue_redraw()

func configure(next: int) -> void: next_level = next

func _process(delta: float) -> void:
	_time += delta; queue_redraw()

func _entered(body: Node) -> void:
	if active and body.is_in_group("player"):
		active = false
		get_tree().call_group("game_level", "level_goal_reached", next_level)

func _draw() -> void:
	var pulse := 2.0 + sin(_time*3.0)*2.0
	draw_arc(Vector2.ZERO,22+pulse,0,TAU,32,Color("63f8ea"),4)
	draw_arc(Vector2.ZERO,15,0,TAU,24,Color("a57dff"),3)
	draw_circle(Vector2.ZERO,10,Color(0.4,1,0.95,0.18))

