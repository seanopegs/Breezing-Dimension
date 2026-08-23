class_name BasePlatform
extends StaticBody2D

@export_enum("ALWAYS:-1", "STILL:0", "BREEZE:1") var dimension_requirement := -1
@export var platform_size := Vector2(32, 32)
var _active := true

func _ready() -> void:
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	_apply_shape()
	_on_dimension_changed(DimensionManager.current_dimension)

func configure(size: Vector2, requirement := -1) -> void:
	platform_size = size
	dimension_requirement = requirement
	if is_inside_tree():
		_apply_shape()
		_on_dimension_changed(DimensionManager.current_dimension)

func _apply_shape() -> void:
	var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collision:
		var shape := RectangleShape2D.new()
		shape.size = platform_size
		collision.shape = shape

func _on_dimension_changed(value: int) -> void:
	_active = dimension_requirement < 0 or value == dimension_requirement
	var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collision: collision.set_deferred("disabled", not _active)
	queue_redraw()

func _draw() -> void:
	var base := Color("263859")
	var edge := Color("5e719d")
	if dimension_requirement == DimensionManager.Dimension.STILL:
		base = Color("40346e") if _active else Color("302a4a")
		edge = Color("a88dff")
	elif dimension_requirement == DimensionManager.Dimension.BREEZE:
		base = Color("126a73") if _active else Color("163b49")
		edge = Color("60f5e5")
	var alpha := 1.0 if _active else 0.18
	draw_rect(Rect2(-platform_size/2.0, platform_size), Color(base, alpha), true)
	draw_line(Vector2(-platform_size.x/2, -platform_size.y/2+2), Vector2(platform_size.x/2, -platform_size.y/2+2), Color(edge, alpha), 3)
	if dimension_requirement >= 0:
		for x in range(int(-platform_size.x/2)+8, int(platform_size.x/2), 12):
			draw_circle(Vector2(x, 2), 2, Color(edge, alpha * 0.8))

