extends Control

var button_box: VBoxContainer
var confirm_panel: PanelContainer
var ending_label: Label
var layout_box: BoxContainer
var title_box: VBoxContainer
var title_label: Label
var quote_label: Label
var menu_margin: MarginContainer

func _ready() -> void:
	_build()
	AudioManager.play_music("menu")
	SaveManager.save_changed.connect(_refresh)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_refresh()

func _build() -> void:
	var background:=Control.new();background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);background.script=load("res://scripts/MenuBackground.gd");add_child(background)
	menu_margin=MarginContainer.new();menu_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(menu_margin)
	layout_box=BoxContainer.new();layout_box.add_theme_constant_override("separation",48);menu_margin.add_child(layout_box)
	title_box=VBoxContainer.new();title_box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title_box.alignment=BoxContainer.ALIGNMENT_CENTER;layout_box.add_child(title_box)
	title_label=UIFactory.title_label("BREEZING\nDIMENSION",68);title_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT;title_box.add_child(title_label)
	var sub:=UIFactory.label("Between stillness and the storm.",20,UIFactory.CYAN);title_box.add_child(sub)
	quote_label=UIFactory.label("ONE WORLD.  TWO DIMENSIONS.\nTHE WIND CONNECTS THEM.",15,UIFactory.MUTED);title_box.add_child(quote_label)
	button_box=VBoxContainer.new();button_box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;button_box.alignment=BoxContainer.ALIGNMENT_CENTER;button_box.add_theme_constant_override("separation",9);layout_box.add_child(button_box)
	for data in [["CONTINUE",GameManager.continue_game],["NEW GAME",_new_game],["LEVEL SELECT",_level_select],["SETTINGS",_settings],["CREDITS",_credits],["QUIT",_quit]]:
		var b:=Button.new();b.name=data[0].replace(" ","");b.text=data[0];UIFactory.style_button(b);b.pressed.connect(data[1]);button_box.add_child(b)
	ending_label=UIFactory.label("",14,UIFactory.MUTED);ending_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;button_box.add_child(ending_label)
	confirm_panel=PanelContainer.new();confirm_panel.visible=false;confirm_panel.add_theme_stylebox_override("panel",UIFactory.panel_style(Color("101b3df8"),16,UIFactory.PURPLE));confirm_panel.anchor_left=0.08;confirm_panel.anchor_top=0.22;confirm_panel.anchor_right=0.92;confirm_panel.anchor_bottom=0.78;add_child(confirm_panel)
	var confirm_box:=VBoxContainer.new();confirm_box.alignment=BoxContainer.ALIGNMENT_CENTER;confirm_box.add_theme_constant_override("separation",14);confirm_panel.add_child(confirm_box)
	var warning:=UIFactory.label("Starting a new game will overwrite\nyour current progress.",20);warning.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;confirm_box.add_child(warning)
	var yes:=Button.new();yes.text="YES — START OVER";UIFactory.style_button(yes);yes.pressed.connect(func():GameManager.start_new_game());confirm_box.add_child(yes)
	var no:=Button.new();no.text="NO";UIFactory.style_button(no,UIFactory.PURPLE);no.pressed.connect(func():confirm_panel.visible=false);confirm_box.add_child(no)

func _apply_responsive_layout()->void:
	if not layout_box:return
	var compact:=get_window().size.x<850
	layout_box.vertical=compact
	menu_margin.add_theme_constant_override("margin_left",24 if compact else 72)
	menu_margin.add_theme_constant_override("margin_right",24 if compact else 72)
	menu_margin.add_theme_constant_override("margin_top",16 if compact else 60)
	menu_margin.add_theme_constant_override("margin_bottom",16 if compact else 45)
	title_label.add_theme_font_size_override("font_size",64 if compact else 68)
	quote_label.visible=not compact
	button_box.add_theme_constant_override("separation",5 if compact else 9)
	for child in button_box.get_children():
		if child is Button:child.custom_minimum_size.y=60 if compact else 48

func _refresh() -> void:
	button_box.get_node("CONTINUE").disabled=not SaveManager.has_save()
	ending_label.text="Endings  %d / 3"%SaveManager.data.endings.size() if SaveManager.has_save() else "No journey begun"

func _new_game()->void:
	if SaveManager.has_save():confirm_panel.visible=true
	else:GameManager.start_new_game()
func _level_select()->void:get_tree().change_scene_to_file("res://scenes/menu/LevelSelect.tscn")
func _settings()->void:get_tree().change_scene_to_file("res://scenes/menu/SettingsMenu.tscn")
func _credits()->void:get_tree().change_scene_to_file("res://scenes/menu/Credits.tscn")
func _quit()->void:get_tree().quit()
