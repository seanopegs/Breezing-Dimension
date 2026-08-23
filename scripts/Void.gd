extends Area2D

@export var chase_speed := 62.0
@export var active := false
@export var wall_size := Vector2(260, 900)

func _ready() -> void:
	add_to_group("collapse_void")
	body_entered.connect(func(body): if body.has_method("die"): body.die())
	var shape := RectangleShape2D.new(); shape.size = wall_size
	$CollisionShape2D.shape = shape
	queue_redraw()

func _physics_process(delta: float) -> void:
	if active: global_position.x += chase_speed * delta

func retreat_behind(world_x: float) -> void:
	global_position.x = minf(global_position.x, world_x - 520.0)

func _draw() -> void:
	draw_rect(Rect2(-wall_size/2, wall_size), Color("09051c"), true)
	for i in 14:
		var x := wall_size.x/2 - 10 - (i%4)*16
		var y := -wall_size.y/2 + i*67
		draw_circle(Vector2(x,y), 26, Color(0.35,0.12,0.5,0.35))
