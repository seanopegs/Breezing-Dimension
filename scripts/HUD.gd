extends CanvasLayer

var dimension_label: Label
var fragment_label: Label
var level_label: Label
var tutorial_panel: PanelContainer
var tutorial_label: Label
var lore_panel: PanelContainer
var lore_label: Label
var total_fragments := 0
var level_id := 1
var _tutorial_tween: Tween
var _lore_tween: Tween

func _ready() -> void:
	_build()
	DimensionManager.dimension_changed.connect(_dimension_changed)
	get_viewport().size_changed.connect(_apply_readability_scale)
	_apply_readability_scale()
	_dimension_changed(DimensionManager.current_dimension)

func configure(data: Dictionary) -> void:
	level_id = int(data.get("id",GameManager.current_level))
	total_fragments = int(data.get("fragment_total",0))
	level_label.text = "%02d  —  %s" % [level_id, str(data.get("name","UNKNOWN"))]
	refresh_collectibles()

func _build() -> void:
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",24); margin.add_theme_constant_override("margin_top",20)
	margin.add_theme_constant_override("margin_right",24); margin.add_theme_constant_override("margin_bottom",20); add_child(margin)
	var root := VBoxContainer.new(); root.mouse_filter = Control.MOUSE_FILTER_IGNORE; margin.add_child(root)
	level_label = UIFactory.label("",14,UIFactory.MUTED); root.add_child(level_label)
	dimension_label = UIFactory.label("STILL",24,UIFactory.PURPLE); root.add_child(dimension_label)
	var spacer := Control.new(); spacer.custom_minimum_size.y=4; root.add_child(spacer)
	fragment_label = UIFactory.label("◆ 0 / 0",18); root.add_child(fragment_label)

	tutorial_panel = PanelContainer.new(); tutorial_panel.add_theme_stylebox_override("panel",UIFactory.panel_style()); tutorial_panel.visible=false
	tutorial_panel.anchor_left=0.08; tutorial_panel.anchor_top=1.0; tutorial_panel.anchor_right=0.92; tutorial_panel.anchor_bottom=1.0
	tutorial_panel.offset_left=0; tutorial_panel.offset_top=-132; tutorial_panel.offset_right=0; tutorial_panel.offset_bottom=-44; add_child(tutorial_panel)
	tutorial_label=UIFactory.label("",18); tutorial_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; tutorial_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	tutorial_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; tutorial_label.clip_text=false; tutorial_panel.add_child(tutorial_label)
	lore_panel = PanelContainer.new(); lore_panel.add_theme_stylebox_override("panel",UIFactory.panel_style(Color("1b1747ee"),12,UIFactory.PURPLE)); lore_panel.visible=false
	lore_panel.anchor_left=0.1; lore_panel.anchor_top=0.5; lore_panel.anchor_right=0.9; lore_panel.anchor_bottom=0.5
	lore_panel.offset_left=0; lore_panel.offset_top=-72; lore_panel.offset_right=0; lore_panel.offset_bottom=72; add_child(lore_panel)
	lore_label=UIFactory.label("",19); lore_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; lore_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; lore_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; lore_panel.add_child(lore_label)

func _dimension_changed(value: int) -> void:
	dimension_label.text = "BREEZE" if value == 1 else "STILL"
	dimension_label.add_theme_color_override("font_color", UIFactory.CYAN if value == 1 else UIFactory.PURPLE)
	dimension_label.scale = Vector2(1.3,1.3); create_tween().tween_property(dimension_label,"scale",Vector2.ONE,0.18)

func _apply_readability_scale() -> void:
	var multiplier:=UIFactory.ui_multiplier()
	level_label.add_theme_font_size_override("font_size",roundi(14*multiplier))
	dimension_label.add_theme_font_size_override("font_size",roundi(24*multiplier))
	fragment_label.add_theme_font_size_override("font_size",roundi(18*multiplier))
	tutorial_label.add_theme_font_size_override("font_size",roundi(18*multiplier))
	lore_label.add_theme_font_size_override("font_size",roundi(19*multiplier))
	if multiplier>1.2:
		tutorial_panel.offset_top=-182;tutorial_panel.offset_bottom=-62
	else:
		tutorial_panel.offset_top=-132;tutorial_panel.offset_bottom=-44

func refresh_collectibles() -> void:
	fragment_label.text = "◆ %d / %d" % [SaveManager.fragments_for_level(level_id), total_fragments]

func show_tutorial(text: String) -> void:
	if _tutorial_tween and _tutorial_tween.is_valid(): _tutorial_tween.kill()
	tutorial_label.text=text; tutorial_panel.visible=true; tutorial_panel.modulate.a=1
	_tutorial_tween=create_tween(); _tutorial_tween.tween_interval(5.0); _tutorial_tween.tween_property(tutorial_panel,"modulate:a",0.0,0.35); _tutorial_tween.tween_callback(func():tutorial_panel.visible=false)

func show_lore(text: String) -> void:
	if _lore_tween and _lore_tween.is_valid(): _lore_tween.kill()
	lore_label.text="MEMORY ECHO\n\n“%s”"%text; lore_panel.visible=true; lore_panel.modulate.a=0
	_lore_tween=create_tween(); _lore_tween.tween_property(lore_panel,"modulate:a",1.0,0.25); _lore_tween.tween_interval(4.8); _lore_tween.tween_property(lore_panel,"modulate:a",0.0,0.4); _lore_tween.tween_callback(func():lore_panel.visible=false)
