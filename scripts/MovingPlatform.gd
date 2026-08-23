extends AnimatableBody2D

@export var speed := 80.0
@export var end_offset := Vector2(160, 0)
@export_enum("ALWAYS:-1", "STILL:0", "BREEZE:1") var dimension_requirement := -1
var _origin := Vector2.ZERO
var _target_end := true
var _active := true

func _ready() -> void:
	_origin = global_position
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	_on_dimension_changed(DimensionManager.current_dimension)
	queue_redraw()

func configure(offset: Vector2, move_speed: float, requirement: int) -> void:
	end_offset = offset; speed = move_speed; dimension_requirement = requirement

func _physics_process(delta: float) -> void:
	if not _active: return
	var target := _origin + end_offset if _target_end else _origin
	global_position = global_position.move_toward(target, speed * delta)
	if global_position.distance_to(target) < 1.0: _target_end = not _target_end

func _on_dimension_changed(value: int) -> void:
	_active = dimension_requirement < 0 or dimension_requirement == value
	$CollisionShape2D.set_deferred("disabled", not _active)
	modulate.a = 1.0 if _active else 0.16

func _draw() -> void:
	draw_rect(Rect2(-48,-10,96,20), Color("284f69"), true)
	draw_line(Vector2(-44,-7), Vector2(44,-7), Color("6ff5e7"), 3)
	for x in [-28,0,28]: draw_circle(Vector2(x,2), 4, Color("8ea4c7"))

