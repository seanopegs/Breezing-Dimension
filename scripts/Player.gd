class_name BreezePlayer
extends CharacterBody2D

signal died

@export var move_speed := 230.0
@export var acceleration := 1200.0
@export var deceleration := 1500.0
@export var jump_velocity := -420.0
@export var gravity := 1100.0

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var dimension_cooldown: Timer = $DimensionCooldownTimer
@onready var camera: Camera2D = $Camera2D

var checkpoint_position := Vector2.ZERO
var checkpoint_dimension := 0
var controls_enabled := true
var _was_on_floor := false
var _dying := false
var _wind_force := Vector2.ZERO
var _wind_x := 0.0
var _locomotion_x := 0.0

func _ready() -> void:
	checkpoint_position = global_position
	checkpoint_dimension = DimensionManager.current_dimension
	add_to_group("player")
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dimension_shift") and controls_enabled and dimension_cooldown.is_stopped():
		DimensionManager.toggle_dimension()
		dimension_cooldown.start()
	if event.is_action_pressed("restart") and controls_enabled:
		GameManager.restart_level()

func _physics_process(delta: float) -> void:
	if _dying:
		return
	var on_floor_before := is_on_floor()
	if not controls_enabled:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

	var axis := Input.get_axis("move_left", "move_right")
	if absf(axis) > 0.01:
		_locomotion_x = move_toward(_locomotion_x, axis * move_speed, acceleration * delta)
	else:
		_locomotion_x = move_toward(_locomotion_x, 0.0, deceleration * delta)

	var wind_target := _wind_force.x * 0.72
	var wind_response := 950.0 if absf(_wind_force.x) > 0.1 else 1250.0
	_wind_x = move_toward(_wind_x, wind_target, wind_response * delta)
	velocity.x = _locomotion_x + _wind_x

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if not jump_buffer_timer.is_stopped():
			_jump()

	if (is_on_floor() or not coyote_timer.is_stopped()) and not jump_buffer_timer.is_stopped():
		_jump()
	if Input.is_action_just_released("jump") and velocity.y < -170.0:
		velocity.y = -170.0

	velocity.y += _wind_force.y * 3.0 * delta
	velocity.y = clampf(velocity.y, -560.0, 720.0)
	_wind_force = Vector2.ZERO
	move_and_slide()

	if on_floor_before and not is_on_floor() and velocity.y >= 0.0:
		coyote_timer.start()
	if not on_floor_before and is_on_floor() and velocity.y >= 0.0:
		AudioManager.play_sfx("land")
	_was_on_floor = is_on_floor()
	if global_position.y > 1200.0:
		die()

func _jump() -> void:
	velocity.y = jump_velocity
	jump_buffer_timer.stop()
	coyote_timer.stop()
	AudioManager.play_sfx("jump")

func apply_wind(force: Vector2) -> void:
	if controls_enabled:
		_wind_force += force

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos
	checkpoint_dimension = DimensionManager.current_dimension

func die() -> void:
	if _dying: return
	_dying = true
	controls_enabled = false
	SaveManager.data.deaths = int(SaveManager.data.deaths) + 1
	AudioManager.play_sfx("death")
	if camera.has_method("shake"): camera.shake(1.0)
	died.emit()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.25, 0.45, 0), 0.38)
	await tween.finished
	global_position = checkpoint_position
	DimensionManager.set_dimension(checkpoint_dimension)
	velocity = Vector2.ZERO
	_locomotion_x = 0.0
	_wind_x = 0.0
	_wind_force = Vector2.ZERO
	modulate = Color.WHITE
	_dying = false
	controls_enabled = true

func _on_dimension_changed(_dimension: int) -> void:
	queue_redraw()

func _draw() -> void:
	var breeze := DimensionManager.is_breeze()
	var glow := Color("65fff0") if breeze else Color("aa8cff")
	# Scarf / wind ribbon
	draw_colored_polygon(PackedVector2Array([Vector2(-7,-10), Vector2(-24,-8), Vector2(-15,-3), Vector2(-7,-4)]), glow.darkened(0.15))
	# Body and head
	draw_circle(Vector2(0,-12), 8, Color("eefcff"))
	draw_colored_polygon(PackedVector2Array([Vector2(-8,-5),Vector2(8,-5),Vector2(10,14),Vector2(-10,14)]), Color("26395f"))
	draw_line(Vector2(-5,14), Vector2(-6,19), glow, 4)
	draw_line(Vector2(5,14), Vector2(6,19), glow, 4)
	draw_circle(Vector2(3,-13), 1.5, Color("07112a"))
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color(glow, 0.35), 2)
