extends Node

const LEVEL_SCENE := "res://scenes/game/GameLevel.tscn"
const STORY_SCENE := "res://scenes/story/StoryScene.tscn"
const MENU_SCENE := "res://scenes/menu/MainMenu.tscn"
const CREDITS_SCENE := "res://scenes/menu/Credits.tscn"
const TRANSITION_SCENE := preload("res://scenes/SceneTransition.tscn")

var current_level := 1
var pending_story_path := ""
var level_started_at := 0
var _changing_scene := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_new_game() -> void:
	SaveManager.new_game()
	current_level = 1
	go_to_story("res://data/story/prologue.txt")

func continue_game() -> void:
	current_level = clampi(int(SaveManager.data.current_level), 1, 6)
	load_level(current_level)

func load_level(level: int) -> void:
	current_level = clampi(level, 1, 6)
	SaveManager.data.current_level = current_level
	SaveManager.save_game()
	level_started_at = Time.get_ticks_msec()
	DimensionManager.set_dimension(DimensionManager.Dimension.STILL)
	_change_scene(LEVEL_SCENE)

func restart_level() -> void:
	load_level(current_level)

func complete_level(next_level: int) -> void:
	if current_level < 6:
		SaveManager.unlock_level(min(current_level + 1, 6))
		go_to_story("res://data/story/after_level_%02d.txt" % current_level)
	else:
		SaveManager.unlock_level(6)

func go_to_story(path: String) -> void:
	pending_story_path = path
	_change_scene(STORY_SCENE)

func route_destination(destination: String) -> void:
	if destination.begins_with("level_"):
		if destination == "level_final": load_level(6)
		else: load_level(int(destination.trim_prefix("level_")))
	elif destination == "credits":
		_change_scene(CREDITS_SCENE)
	else:
		go_to_main_menu()

func choose_ending(ending_id: String) -> void:
	SaveManager.add_ending(ending_id)
	go_to_story("res://data/story/ending_%s.txt" % ending_id.trim_prefix("ending_"))

func go_to_main_menu() -> void:
	get_tree().paused = false
	_change_scene(MENU_SCENE)

func _change_scene(path: String) -> void:
	if _changing_scene:
		return
	_changing_scene = true
	get_tree().paused = false
	var transition = TRANSITION_SCENE.instantiate()
	get_tree().root.add_child(transition)
	await transition.fade_out(0.22)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	transition.fade_in(0.28)
	await get_tree().create_timer(0.3).timeout
	transition.queue_free()
	_changing_scene = false

func format_time(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]
