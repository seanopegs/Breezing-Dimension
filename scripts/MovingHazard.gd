extends Area2D

@export var end_offset := Vector2(0, -128)
@export var speed := 95.0
@export_enum("ALWAYS:-1", "STILL:0", "BREEZE:1") var active_dimension := -1
var _origin := Vector2.ZERO
var _toward_end := true
var _active := true

func _ready() -> void:
	_origin = global_position
	body_entered.connect(func(body): if body.has_method("die"): body.die())
	DimensionManager.dimension_changed.connect(_dimension_changed)
	_dimension_changed(DimensionManager.current_dimension)
	queue_redraw()

func configure(offset: Vector2, move_speed: float, requirement: int) -> void:
	end_offset = offset; speed = move_speed; active_dimension = requirement

func _physics_process(delta: float) -> void:
	if not _active: return
	var target := _origin + end_offset if _toward_end else _origin
	global_position = global_position.move_toward(target, speed*delta)
	if global_position.distance_to(target) < 1.0: _toward_end = not _toward_end

func _dimension_changed(value: int) -> void:
	_active = active_dimension < 0 or value == active_dimension
	set_deferred("monitoring",_active); modulate.a = 1.0 if _active else 0.15

func _draw() -> void:
	draw_circle(Vector2.ZERO, 14, Color("eb3f77"))
	draw_circle(Vector2.ZERO, 7, Color("421435"))
	for a in 8:
		var dir := Vector2.from_angle(a*TAU/8.0)
		draw_line(dir*12,dir*20,Color("ffadc2"),5)
