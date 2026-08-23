extends CanvasLayer

var panel: Control
var settings_box: VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_build()
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused and visible: resume()
		elif not get_tree().paused: pause()
		get_viewport().set_input_as_handled()

func pause() -> void:
	get_tree().paused = true; visible = true; settings_box.visible=false

func resume() -> void:
	get_tree().paused = false; visible = false

func _build() -> void:
	var shade:=ColorRect.new(); shade.color=Color(0.01,0.02,0.07,0.82); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(shade)
	var card:=PanelContainer.new(); card.add_theme_stylebox_override("panel",UIFactory.panel_style(Color("0c1738f5"),16,Color("4b6695")))
	card.anchor_left=0.08;card.anchor_top=0.03;card.anchor_right=0.92;card.anchor_bottom=0.97;add_child(card)
	var box:=VBoxContainer.new(); box.alignment=BoxContainer.ALIGNMENT_CENTER; box.add_theme_constant_override("separation",10); card.add_child(box)
	box.add_child(UIFactory.title_label("PAUSED",36))
	for data in [["RESUME",resume],["RESTART CHECKPOINT",_restart_checkpoint],["RESTART LEVEL",GameManager.restart_level],["SETTINGS",_toggle_settings],["RETURN TO MAIN MENU",GameManager.go_to_main_menu]]:
		var button:=Button.new(); button.text=data[0]; UIFactory.style_button(button); button.pressed.connect(data[1]); box.add_child(button)
	settings_box=VBoxContainer.new(); settings_box.visible=false; settings_box.add_theme_constant_override("separation",8); box.add_child(settings_box)
	var shake:=CheckButton.new(); shake.text="Screen Shake"; shake.button_pressed=SettingsManager.screen_shake; shake.toggled.connect(func(v):SettingsManager.screen_shake=v;SettingsManager.save_settings()); settings_box.add_child(shake)
	var auto:=CheckButton.new(); auto.text="Auto Advance Dialogue"; auto.button_pressed=SettingsManager.auto_advance; auto.toggled.connect(func(v):SettingsManager.auto_advance=v;SettingsManager.save_settings()); settings_box.add_child(auto)

func _restart_checkpoint() -> void:
	var player=get_tree().get_first_node_in_group("player")
	if player:
		DimensionManager.set_dimension(player.checkpoint_dimension);player.global_position=player.checkpoint_position; player.velocity=Vector2.ZERO
		for collapse_void in get_tree().get_nodes_in_group("collapse_void"):collapse_void.retreat_behind(player.checkpoint_position.x)
	resume()

func _toggle_settings() -> void:
	settings_box.visible=not settings_box.visible
