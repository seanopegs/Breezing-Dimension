extends Control

func _ready()->void:
	var bg:=ColorRect.new();bg.color=Color("07112a");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
	var box:=VBoxContainer.new();box.anchor_left=0.08;box.anchor_top=0.03;box.anchor_right=0.92;box.anchor_bottom=0.97;box.alignment=BoxContainer.ALIGNMENT_CENTER;box.add_theme_constant_override("separation",12);add_child(box)
	box.add_child(UIFactory.title_label("BREEZING DIMENSION",44))
	var scroll:=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;box.add_child(scroll)
	var text:="GAME DESIGN & PROGRAMMING\nBreezing Dimension Team\n\nART & VISUAL DIRECTION\nProcedural worlds between stillness and wind\n\nMUSIC & SOUND\nGenerative dimensional soundscape\n\nSPECIAL THANKS\nGodot Engine Community\nEveryone who lets a world breathe"
	if "ending_true" in SaveManager.data.endings:text+="\n\nThank you for letting the world breathe again."
	var label:=UIFactory.label(text,18);label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;scroll.add_child(label)
	var back:=Button.new();back.text="RETURN TO MAIN MENU";UIFactory.style_button(back);back.pressed.connect(GameManager.go_to_main_menu);box.add_child(back)
