extends Camera2D

var trauma := 0.0
var max_offset := Vector2(9, 6)

func _ready() -> void:
	DimensionManager.dimension_pulse.connect(func(): shake(0.45))
	get_viewport().size_changed.connect(_apply_readable_zoom)
	_apply_readable_zoom()

func _apply_readable_zoom() -> void:
	var multiplier:=UIFactory.ui_multiplier()
	var readable_zoom:=1.0+(multiplier-1.0)*0.4
	zoom=Vector2.ONE*readable_zoom

func shake(amount := 0.5) -> void:
	if SettingsManager.screen_shake:
		trauma = max(trauma, amount)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = maxf(0.0, trauma - delta * 2.8)
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * max_offset * trauma * trauma
	else:
		offset = offset.lerp(Vector2.ZERO, delta * 12.0)
