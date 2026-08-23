extends Area2D

@export var direction := Vector2.RIGHT
@export var strength := 350.0
@export_enum("STILL:0", "BREEZE:1", "ALWAYS:-1") var active_dimension := 1
@export var zone_size := Vector2(128, 64)
var active := false

func _ready() -> void:
	add_to_group("wind_zone")
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	_apply_shape()
	_on_dimension_changed(DimensionManager.current_dimension)

func configure(size: Vector2, dir: Vector2, force: float, requirement: int) -> void:
	zone_size = size; direction = dir.normalized(); strength = force; active_dimension = requirement
	if is_inside_tree(): _apply_shape(); _on_dimension_changed(DimensionManager.current_dimension)

func _apply_shape() -> void:
	var shape := RectangleShape2D.new(); shape.size = zone_size; $CollisionShape2D.shape = shape

func _physics_process(_delta: float) -> void:
	if not active or not monitoring: return
	for body in get_overlapping_bodies():
		if body.has_method("apply_wind"):
			body.apply_wind(direction * strength)
		elif body is RigidBody2D:
			body.sleeping=false
			body.linear_velocity+=direction*strength*_delta*3.0
			if body.linear_velocity.length()>360.0:body.linear_velocity=body.linear_velocity.normalized()*360.0

func _on_dimension_changed(value: int) -> void:
	active = active_dimension < 0 or value == active_dimension
	set_deferred("monitoring",active)
	queue_redraw()

func _draw() -> void:
	var alpha := 0.28 if active else 0.045
	draw_rect(Rect2(-zone_size/2, zone_size), Color(0.2, 0.95, 0.92, alpha * 0.25), true)
	var perpendicular := Vector2(-direction.y, direction.x)
	for i in 5:
		var lane: float = (float(i)-2.0) * minf(zone_size.x, zone_size.y) / 6.0
		var start: Vector2 = -direction * minf(zone_size.x, zone_size.y) * 0.25 + perpendicular * lane
		var finish: Vector2 = start + direction * minf(zone_size.x, zone_size.y) * 0.45
		draw_line(start, finish, Color(0.45,1,0.95,alpha), 2)
		draw_line(finish, finish-direction*8+perpendicular*5, Color(0.45,1,0.95,alpha), 2)
