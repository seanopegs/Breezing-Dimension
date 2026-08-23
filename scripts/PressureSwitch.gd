extends Area2D

@export var target_id := "A"
@export var crate_only := false
var pressed := false

func _ready() -> void:
	body_entered.connect(func(_body): _update_pressed())
	body_exited.connect(func(_body): _update_pressed())
	queue_redraw()

func configure(id: String, only_crates:=false) -> void:
	target_id=id;crate_only=only_crates

func _update_pressed() -> void:
	await get_tree().physics_frame
	var new_pressed := false
	for body in get_overlapping_bodies():
		if not crate_only or body.is_in_group("wind_crate"):
			new_pressed=true
			if crate_only and body.has_method("lock_to_switch"):body.lock_to_switch()
			break
	if new_pressed == pressed: return
	pressed = new_pressed
	get_tree().call_group("dimension_doors", "set_link_state", target_id, pressed)
	AudioManager.play_sfx("door")
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-48, 7 if pressed else 3, 96, 7), Color("67f5dd") if pressed else Color("9b7cff"), true)
	draw_rect(Rect2(-56,10,112,5), Color("273558"), true)
