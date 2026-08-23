extends Control

var content: VBoxContainer

func _ready()->void:
	_build()

func _build()->void:
	var bg:=ColorRect.new();bg.color=UIFactory.BG;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
	var card:=PanelContainer.new();card.add_theme_stylebox_override("panel",UIFactory.panel_style());card.anchor_left=0.06;card.anchor_top=0.04;card.anchor_right=0.94;card.anchor_bottom=0.96;add_child(card)
	var scroll:=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;card.add_child(scroll)
	content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",9);scroll.add_child(content);content.add_child(UIFactory.title_label("SETTINGS",40))
	_section("AUDIO")
	_slider("Master Volume",SettingsManager.master_volume,func(v):SettingsManager.master_volume=v)
	_slider("Music Volume",SettingsManager.music_volume,func(v):SettingsManager.music_volume=v)
	_slider("SFX Volume",SettingsManager.sfx_volume,func(v):SettingsManager.sfx_volume=v)
	_section("DISPLAY")
	_toggle("Fullscreen",SettingsManager.fullscreen,func(v):SettingsManager.fullscreen=v)
	_toggle("VSync",SettingsManager.vsync,func(v):SettingsManager.vsync=v)
	_toggle("Screen Shake",SettingsManager.screen_shake,func(v):SettingsManager.screen_shake=v)
	_section("GAMEPLAY")
	var speed_value:=inverse_lerp(15.0,80.0,SettingsManager.dialogue_speed);_slider("Dialogue Speed",speed_value,func(v):SettingsManager.dialogue_speed=lerp(15.0,80.0,v))
	_toggle("Auto Advance Dialogue",SettingsManager.auto_advance,func(v):SettingsManager.auto_advance=v)
	var back:=Button.new();back.text="SAVE & BACK";UIFactory.style_button(back);back.pressed.connect(func():SettingsManager.save_settings();GameManager.go_to_main_menu());content.add_child(back)

func _section(text:String)->void:
	var l:=UIFactory.label(text,15,UIFactory.CYAN);content.add_child(l)
func _slider(text:String,value:float,callback:Callable)->void:
	var row:=HBoxContainer.new();var l:=UIFactory.label(text,17);l.custom_minimum_size.x=150;row.add_child(l);var s:=HSlider.new();s.custom_minimum_size=Vector2(120,28);s.size_flags_horizontal=Control.SIZE_EXPAND_FILL;s.min_value=0;s.max_value=1;s.step=.01;s.value=value;s.value_changed.connect(func(v):callback.call(v);SettingsManager.apply_settings());row.add_child(s);content.add_child(row)
func _toggle(text:String,value:bool,callback:Callable)->void:
	var t:=CheckButton.new();t.text=text;t.button_pressed=value;t.add_theme_font_size_override("font_size",roundi(17*UIFactory.ui_multiplier()));t.toggled.connect(func(v):callback.call(v));content.add_child(t)
