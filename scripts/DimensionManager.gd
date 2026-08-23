extends Node

signal dimension_changed(new_dimension)
signal dimension_pulse

enum Dimension { STILL, BREEZE }
var current_dimension: Dimension = Dimension.STILL
var can_shift := true

func set_dimension(value: Dimension, animate := false) -> void:
	current_dimension = value
	dimension_changed.emit(current_dimension)
	if animate:
		dimension_pulse.emit()

func toggle_dimension() -> void:
	if not can_shift:
		return
	current_dimension = Dimension.BREEZE if current_dimension == Dimension.STILL else Dimension.STILL
	dimension_changed.emit(current_dimension)
	dimension_pulse.emit()
	AudioManager.play_sfx("shift")
	can_shift = false
	get_tree().create_timer(0.18).timeout.connect(func(): can_shift = true)

func is_breeze() -> bool:
	return current_dimension == Dimension.BREEZE

