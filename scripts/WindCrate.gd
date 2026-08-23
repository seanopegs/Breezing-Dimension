extends RigidBody2D

var locked_on_switch:=false

func _ready() -> void:
	add_to_group("wind_crate")
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	_on_dimension_changed(DimensionManager.current_dimension)
	queue_redraw()

func _on_dimension_changed(value: int) -> void:
	freeze = locked_on_switch or value == DimensionManager.Dimension.STILL
	gravity_scale = 1.0
	queue_redraw()

func lock_to_switch() -> void:
	locked_on_switch=true
	linear_velocity=Vector2.ZERO
	freeze=true

func _draw() -> void:
	var glow := Color("5dfff0") if DimensionManager.is_breeze() else Color("726889")
	draw_rect(Rect2(-14,-14,28,28), Color("7e644e"), true)
	draw_rect(Rect2(-14,-14,28,28), glow, false, 3)
	draw_line(Vector2(-10,-10), Vector2(10,10), glow, 2)
	draw_line(Vector2(10,-10), Vector2(-10,10), glow, 2)
