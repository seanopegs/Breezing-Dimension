extends Area2D

@export var hazard_size := Vector2(32, 24)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func configure(size: Vector2) -> void:
	hazard_size = size
	var shape := RectangleShape2D.new(); shape.size = size * Vector2(0.8, 0.65)
	$CollisionShape2D.shape = shape
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body.has_method("die"): body.die()

func _draw() -> void:
	var count := maxi(1, int(hazard_size.x / 16.0))
	var step := hazard_size.x / count
	for i in count:
		var left := -hazard_size.x/2 + i*step
		draw_colored_polygon(PackedVector2Array([Vector2(left,hazard_size.y/2),Vector2(left+step/2,-hazard_size.y/2),Vector2(left+step,hazard_size.y/2)]), Color("e84c78"))
		draw_polyline(PackedVector2Array([Vector2(left,hazard_size.y/2),Vector2(left+step/2,-hazard_size.y/2),Vector2(left+step,hazard_size.y/2)]), Color("ffb4c7"), 2)

