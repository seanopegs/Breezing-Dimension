extends Node2D

@onready var loader: BreezingLevelLoader = $LevelLoader
@onready var hud: CanvasLayer = $HUD
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

var level_data: Dictionary = {}
var level_deaths_start := 0
var completed := false

func _ready() -> void:
	add_to_group("game_level")
	level_deaths_start = int(SaveManager.data.deaths)
	loader.level_loaded.connect(_on_loaded)
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	DimensionManager.dimension_pulse.connect(_flash_dimension)
	var filename := "level_final.txt" if GameManager.current_level == 6 else "level_%02d.txt" % GameManager.current_level
	loader.load_level("res://data/levels/" + filename)
	_on_dimension_changed(DimensionManager.current_dimension)

func _process(_delta: float) -> void:
	var player:=get_tree().get_first_node_in_group("player")
	if player:
		$Effects/WindParticles.global_position=player.global_position

func _on_loaded(data: Dictionary) -> void:
	level_data = data
	hud.configure(data)
	$Background/Backdrop.set_mood(str(data.get("background","fractured_ruins")))
	AudioManager.play_music(str(data.get("music","finale" if GameManager.current_level == 6 else "level")))
	var player:=get_tree().get_first_node_in_group("player")
	if player: player.died.connect(_on_player_died)
	var title := UIFactory.label("%02d — %s" % [int(data.get("id",1)),str(data.get("name",""))],24,UIFactory.TEXT)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title.anchor_left=0.18; title.anchor_right=0.82; title.offset_top=65; title.offset_bottom=105; $HUD.add_child(title)
	title.modulate.a=0
	var tween:=create_tween(); tween.tween_property(title,"modulate:a",1.0,0.4); tween.tween_interval(1.4); tween.tween_property(title,"modulate:a",0.0,0.5); tween.tween_callback(title.queue_free)

func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("debug_menu"):
		var goal:=get_node_or_null("DynamicObjects/Goal")
		var player:=get_tree().get_first_node_in_group("player")
		if goal and player: player.global_position=goal.global_position-Vector2(48,0)

func _on_dimension_changed(value: int) -> void:
	canvas_modulate.color = Color("8a91bd") if value == 0 else Color("c5fffb")
	$Effects/WindParticles.emitting = value == 1

func _flash_dimension() -> void:
	var flash:=ColorRect.new(); flash.color=Color(0.45,1,0.95,0.45); flash.mouse_filter=Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); $HUD.add_child(flash)
	var tween:=create_tween(); tween.tween_property(flash,"modulate:a",0.0,0.16); tween.tween_callback(flash.queue_free)

func collectible_picked(type: int, lore: String) -> void:
	hud.refresh_collectibles()
	if type == 1: hud.show_lore(lore)

func show_tutorial(text: String) -> void:
	hud.show_tutorial(text.replace("\\n","\n"))

func _on_player_died() -> void:
	var player:=get_tree().get_first_node_in_group("player")
	if player:
		for collapse_void in get_tree().get_nodes_in_group("collapse_void"):
			collapse_void.retreat_behind(player.checkpoint_position.x)

func level_goal_reached(_next_level: int) -> void:
	if completed:return
	completed=true
	var player:=get_tree().get_first_node_in_group("player")
	if player: player.controls_enabled=false
	if GameManager.current_level == 6: _show_ending_choice()
	else: _show_completion()

func _base_overlay(title_text: String) -> VBoxContainer:
	var layer:=CanvasLayer.new(); layer.layer=30; add_child(layer)
	var shade:=ColorRect.new(); shade.color=Color(0.01,0.02,0.07,0.86); shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); layer.add_child(shade)
	var card:=PanelContainer.new(); card.add_theme_stylebox_override("panel",UIFactory.panel_style(Color("0d193bf5"),18,UIFactory.CYAN)); card.anchor_left=0.08;card.anchor_top=0.06;card.anchor_right=0.92;card.anchor_bottom=0.94;layer.add_child(card)
	var box:=VBoxContainer.new();box.alignment=BoxContainer.ALIGNMENT_CENTER;box.add_theme_constant_override("separation",14);card.add_child(box);box.add_child(UIFactory.title_label(title_text,38));return box

func _show_completion() -> void:
	SaveManager.unlock_level(min(GameManager.current_level+1,6))
	var box:=_base_overlay("LEVEL COMPLETE")
	var elapsed:=(Time.get_ticks_msec()-GameManager.level_started_at)/1000.0
	var stats:="Fragments      %d / %d\nMemory Echo    %s\nTime           %s\nDeaths         %d"%[SaveManager.fragments_for_level(GameManager.current_level),int(level_data.get("fragment_total",0)),"FOUND" if SaveManager.has_memory_for_level(GameManager.current_level) else "—",GameManager.format_time(elapsed),int(SaveManager.data.deaths)-level_deaths_start]
	var label:=UIFactory.label(stats,19);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT;box.add_child(label)
	var continue_button:=Button.new();continue_button.text="CONTINUE";UIFactory.style_button(continue_button,UIFactory.CYAN);continue_button.pressed.connect(func():GameManager.complete_level(int(level_data.get("next_level",GameManager.current_level+1))));box.add_child(continue_button)
	var replay:=Button.new();replay.text="REPLAY";UIFactory.style_button(replay,UIFactory.PURPLE);replay.pressed.connect(GameManager.restart_level);box.add_child(replay)
	continue_button.grab_focus()

func _show_ending_choice() -> void:
	var box:=_base_overlay("THE CORE IS WAITING.")
	box.add_child(UIFactory.label("One world. Two dimensions. One final choice.",17,UIFactory.MUTED))
	_add_ending_button(box,"ESCAPE","ending_escape")
	_add_ending_button(box,"SAVE AERA","ending_sacrifice")
	if SaveManager.can_true_ending():
		_add_ending_button(box,"MERGE THE DIMENSIONS","ending_true",UIFactory.CYAN)
	else:
		var locked:=Button.new();locked.text="???   (18 fragments + 5 memories)";UIFactory.style_button(locked);locked.disabled=true;box.add_child(locked)

func _add_ending_button(parent: VBoxContainer, text: String, id: String, accent:=UIFactory.PURPLE) -> void:
	var button:=Button.new();button.text=text;UIFactory.style_button(button,accent);button.pressed.connect(func():GameManager.choose_ending(id));parent.add_child(button)
