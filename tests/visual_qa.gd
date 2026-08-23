extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size=Vector2i(504,356)
	await _save_scene("res://scenes/menu/MainMenu.tscn","main_menu")
	await _save_scene("res://scenes/menu/SettingsMenu.tscn","settings")
	await _save_scene("res://scenes/menu/LevelSelect.tscn","level_select")
	await _save_scene("res://scenes/menu/Credits.tscn","credits")
	root.get_node("GameManager").pending_story_path="res://data/story/prologue.txt"
	await _save_scene("res://scenes/story/StoryScene.tscn","story")
	root.get_node("GameManager").current_level=2
	await _save_scene("res://scenes/game/GameLevel.tscn","hint",func(scene):scene.get_node("HUD").show_tutorial("Shift to BREEZE while airborne, then return to STILL before landing."))
	await _save_scene("res://scenes/game/GameLevel.tscn","pause",func(scene):scene.get_node("PauseMenu").pause())
	await _save_scene("res://scenes/game/GameLevel.tscn","ending_choice",func(scene):scene._show_ending_choice())
	print("BREEZING_VISUAL_QA_DIR="+ProjectSettings.globalize_path("user://"))
	quit(0)

func _save_scene(path:String,filename:String,setup:=Callable())->void:
	var scene=(load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await physics_frame
	if setup.is_valid():setup.call(scene)
	for i in 8:await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	var image:=root.get_texture().get_image()
	var output:="user://breezing_%s_qa.png"%filename
	image.save_png(output)
	scene.queue_free()
	paused=false
	await process_frame
