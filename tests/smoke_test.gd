extends SceneTree

const MENU_SCENES := [
	"res://scenes/menu/MainMenu.tscn",
	"res://scenes/menu/SettingsMenu.tscn",
	"res://scenes/menu/LevelSelect.tscn",
	"res://scenes/menu/Credits.tscn"
]
const STORY_FILES := [
	"res://data/story/prologue.txt",
	"res://data/story/after_level_01.txt",
	"res://data/story/after_level_02.txt",
	"res://data/story/after_level_03.txt",
	"res://data/story/after_level_04.txt",
	"res://data/story/after_level_05.txt",
	"res://data/story/ending_escape.txt",
	"res://data/story/ending_sacrifice.txt",
	"res://data/story/ending_true.txt"
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size=Vector2i(504,356)
	for path in MENU_SCENES:
		await _exercise_scene(path)
	root.size=Vector2i(1152,648)
	for level in range(1, 7):
		root.get_node("GameManager").current_level = level
		var game_scene = await _exercise_scene("res://scenes/game/GameLevel.tscn", false)
		assert(game_scene.get_node("PlayerContainer").get_child_count() == 1, "Level %d has no player" % level)
		var expected: int = [3, 4, 4, 5, 5, 0][level - 1]
		var saved_count: int = root.get_node("SaveManager").fragments_for_level(level)
		assert(game_scene.get_node("Collectibles").get_child_count() + saved_count >= expected, "Level %d collectible parse failed" % level)
		if level == 1:
			await _verify_dimension_collision(game_scene)
			await _verify_wind_response(game_scene)
			await _verify_still_route_blocked(game_scene)
		if level == 3:
			await _verify_crate_gate(game_scene)
		game_scene.queue_free()
		await process_frame
	for story in STORY_FILES:
		root.get_node("GameManager").pending_story_path = story
		var story_scene = await _exercise_scene("res://scenes/story/StoryScene.tscn", false)
		assert(story_scene.commands.size() > 0, "Story parse failed: " + story)
		story_scene.queue_free()
		await process_frame
	await _verify_compact_hint()
	_verify_level_design_files()
	print("BREEZING_SMOKE_TEST_OK")
	quit(0)

func _exercise_scene(path: String, free_after := true) -> Node:
	var packed := load(path) as PackedScene
	assert(packed != null, "Unable to load " + path)
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await physics_frame
	await process_frame
	if free_after:
		scene.queue_free()
		await process_frame
	return scene

func _verify_dimension_collision(game_scene: Node) -> void:
	var breeze_platform: Node
	for child in game_scene.get_node("TileObjects").get_children():
		if "dimension_requirement" in child and int(child.get("dimension_requirement")) == 1:
			breeze_platform = child
			break
	assert(breeze_platform != null, "Level 1 needs a Breeze platform")
	root.get_node("DimensionManager").set_dimension(0)
	await physics_frame
	assert(breeze_platform.get_node("CollisionShape2D").disabled, "Breeze platform must be intangible in STILL")
	root.get_node("DimensionManager").set_dimension(1)
	await physics_frame
	assert(not breeze_platform.get_node("CollisionShape2D").disabled, "Breeze platform must be solid in BREEZE")
	root.get_node("DimensionManager").set_dimension(0)

func _verify_compact_hint() -> void:
	root.size=Vector2i(504,356)
	root.get_node("GameManager").current_level=2
	var scene=(load("res://scenes/game/GameLevel.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var hud=scene.get_node("HUD")
	hud.show_tutorial("Shift to BREEZE while airborne, then return to STILL before landing.")
	await process_frame
	var panel:Control=hud.tutorial_panel
	var canvas_transform:=panel.get_viewport().get_final_transform()*panel.get_global_transform_with_canvas()
	var screen_top_left:=canvas_transform*Vector2.ZERO
	var screen_bottom_right:=canvas_transform*panel.size
	assert(screen_top_left.x>=-1.0 and screen_bottom_right.x<=root.size.x+1,"Tutorial exceeds horizontal safe area")
	assert(screen_top_left.y>=-1.0 and screen_bottom_right.y<=root.size.y+1,"Tutorial exceeds vertical safe area")
	scene.queue_free()
	await process_frame
	root.size=Vector2i(1152,648)

func _verify_wind_response(game_scene:Node)->void:
	var player=game_scene.get_node("PlayerContainer").get_child(0)
	for i in 12:
		player.apply_wind(Vector2(500,0))
		await physics_frame
	assert(float(player.get("_wind_x"))>120.0,"Horizontal wind must materially affect movement")
	player.global_position=player.checkpoint_position
	player.velocity=Vector2.ZERO
	player.set("_wind_x",0.0);player.set("_locomotion_x",0.0)

func _verify_still_route_blocked(game_scene:Node)->void:
	var player=game_scene.get_node("PlayerContainer").get_child(0)
	root.get_node("DimensionManager").set_dimension(0)
	Input.action_press("move_right")
	var furthest:float=player.global_position.x
	for frame in 300:
		if frame%42==0:Input.action_press("jump")
		await physics_frame
		if frame%42==1:Input.action_release("jump")
		furthest=maxf(furthest,player.global_position.x)
	Input.action_release("move_right");Input.action_release("jump")
	assert(furthest<700.0,"Level 1 can still be crossed in STILL without its Breeze bridge")

func _verify_level_design_files()->void:
	for level in range(1,7):
		var suffix:="final" if level==6 else "%02d"%level
		var file:=FileAccess.open("res://data/levels/level_%s.txt"%suffix,FileAccess.READ)
		assert(file!=null,"Missing level data %d"%level)
		var text:=file.get_as_text()
		var map_text:=text.split("[MAP]",true,1)[1].split("[WIND]",true,1)[0]
		assert(map_text.count("P")==1 and map_text.count("G")==1,"Level %d must have exactly one spawn and goal"%level)
		if level in [1,2,4,5,6]:assert(map_text.count("^")>=10,"Level %d still has a cheeseable safe-floor route"%level)
		if level in [2,4,5,6]:assert("B" in map_text and "S" in map_text,"Level %d must require both dimensions"%level)
	if true:
		var file:=FileAccess.open("res://data/levels/level_03.txt",FileAccess.READ)
		var text:=file.get_as_text()
		var map_text:=text.split("[MAP]",true,1)[1].split("[WIND]",true,1)[0]
		assert(text.count("door=pos=")>=3 and map_text.count("W")>=3,"Level 3 must keep three crate-gate puzzles")

func _verify_crate_gate(game_scene:Node)->void:
	root.get_node("DimensionManager").set_dimension(1)
	for i in 240:await physics_frame
	var first_door:Node
	for child in game_scene.get_node("DynamicObjects").get_children():
		if "link_id" in child and str(child.get("link_id"))=="A":first_door=child;break
	assert(first_door!=null and bool(first_door.get("open")),"Wind crate must settle on switch A and open its gate")
