extends Control

const LEVEL_NAMES:=["First Breath","Crosswind","Weight of the Wind","Fractured Sky","Eye of the Storm","Dimension Core"]
const TOTALS:=[3,4,4,5,5,0]

func _ready()->void:_build()

func _build()->void:
	var bg:=ColorRect.new();bg.color=UIFactory.BG;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
	var margin:=MarginContainer.new();margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);margin.add_theme_constant_override("margin_left",32);margin.add_theme_constant_override("margin_right",32);margin.add_theme_constant_override("margin_top",28);margin.add_theme_constant_override("margin_bottom",28);add_child(margin)
	var root_box:=VBoxContainer.new();root_box.add_theme_constant_override("separation",9);margin.add_child(root_box);root_box.add_child(UIFactory.title_label("LEVEL SELECT",42))
	var scroll:=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;root_box.add_child(scroll)
	var box:=VBoxContainer.new();box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_theme_constant_override("separation",9);scroll.add_child(box)
	for i in 6:
		var unlocked:=i+1<=int(SaveManager.data.unlocked_level)
		var b:=Button.new();b.custom_minimum_size.y=64
		if unlocked:
			var memory:="FOUND" if i<5 and SaveManager.has_memory_for_level(i+1) else ("—" if i<5 else "N/A")
			b.text="%02d — %s          Fragments: %d/%d   Memory: %s"%[i+1,LEVEL_NAMES[i],SaveManager.fragments_for_level(i+1),TOTALS[i],memory]
			var level:=i+1;b.pressed.connect(func():GameManager.load_level(level))
		else:b.text="%02d — ???                              LOCKED"%(i+1);b.disabled=true
		UIFactory.style_button(b,UIFactory.CYAN if i==5 else UIFactory.PURPLE);b.custom_minimum_size.x=0;box.add_child(b)
	var back:=Button.new();back.text="BACK";UIFactory.style_button(back);back.pressed.connect(GameManager.go_to_main_menu);root_box.add_child(back)
