class_name BreezingLevelLoader
extends Node

signal level_loaded(data: Dictionary)

const TILE_SIZE := 32
const NORMAL = preload("res://objects/platforms/NormalPlatform.tscn")
const STILL = preload("res://objects/platforms/StillPlatform.tscn")
const BREEZE = preload("res://objects/platforms/BreezePlatform.tscn")
const MOVING = preload("res://objects/platforms/MovingPlatform.tscn")
const PLAYER = preload("res://scenes/game/Player.tscn")
const WIND = preload("res://objects/wind/WindZone.tscn")
const FAN = preload("res://objects/wind/WindFan.tscn")
const CRATE = preload("res://objects/puzzle/WindCrate.tscn")
const SWITCH = preload("res://objects/puzzle/PressureSwitch.tscn")
const DOOR = preload("res://objects/puzzle/DimensionDoor.tscn")
const SPIKE = preload("res://objects/hazards/Spike.tscn")
const MOVING_HAZARD = preload("res://objects/hazards/MovingHazard.tscn")
const VOID = preload("res://objects/hazards/Void.tscn")
const FRAGMENT = preload("res://objects/collectibles/DimensionFragment.tscn")
const MEMORY = preload("res://objects/collectibles/MemoryEcho.tscn")
const CHECKPOINT = preload("res://objects/checkpoint/Checkpoint.tscn")
const GOAL = preload("res://objects/Goal.tscn")
const TUTORIAL = preload("res://objects/TutorialTrigger.tscn")

var level_data: Dictionary = {}
var map_lines: Array[String] = []
var sections: Dictionary = {}
var player: BreezePlayer

func load_level(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to open level file: " + path)
		return
	_parse(file.get_as_text())
	_build_level()
	level_loaded.emit(level_data)

func _parse(text: String) -> void:
	level_data = {}
	map_lines.clear()
	sections.clear()
	var section := ""
	for raw in text.split("\n"):
		var line := raw.strip_edges()
		if line.is_empty() or line.begins_with(";"): continue
		if line.begins_with("[") and line.ends_with("]"):
			section = line.trim_prefix("[").trim_suffix("]")
			if not sections.has(section): sections[section] = []
			continue
		if section == "MAP":
			map_lines.append(raw.strip_edges())
			continue
		if section == "END": continue
		sections[section].append(line)
		if section == "LEVEL" and "=" in line:
			var pair := line.split("=", true, 1)
			level_data[pair[0].strip_edges()] = pair[1].strip_edges()
	level_data["fragment_total"] = sections.get("FRAGMENT", []).size()
	level_data["memory_total"] = sections.get("MEMORY", []).size()

func _build_level() -> void:
	var world := get_parent()
	var tile_objects := world.get_node("TileObjects")
	var dynamics := world.get_node("DynamicObjects")
	var collectibles := world.get_node("Collectibles")
	var player_container := world.get_node("PlayerContainer")
	var spawn_tile := _parse_vec2(_value("PLAYER", "spawn", "2,2"))
	var goal_next := int(_value("GOAL", "next_level", "0"))
	var map_goal_pos := Vector2(-999,-999)
	var map_checkpoint_count := 0

	for y in map_lines.size():
		var x:=0
		while x<map_lines[y].length():
			var symbol := map_lines[y][x]
			var pos := Vector2(x*TILE_SIZE + TILE_SIZE/2, y*TILE_SIZE + TILE_SIZE/2)
			if symbol in ["#","S","B"]:
				var run:=1
				while x+run<map_lines[y].length() and map_lines[y][x+run]==symbol:run+=1
				var scene:PackedScene=NORMAL if symbol=="#" else (STILL if symbol=="S" else BREEZE)
				var platform=scene.instantiate()
				platform.position=Vector2((x+run/2.0)*TILE_SIZE,y*TILE_SIZE+TILE_SIZE/2)
				platform.configure(Vector2(run*TILE_SIZE,TILE_SIZE),platform.dimension_requirement)
				tile_objects.add_child(platform)
				x+=run
				continue
			match symbol:
				"^": _spawn(SPIKE, pos + Vector2(0,4), dynamics)
				"P": spawn_tile = Vector2(x,y)
				"G": map_goal_pos = pos
				"C": _spawn(CHECKPOINT, pos, dynamics); map_checkpoint_count += 1
				"W": _spawn(CRATE, pos, dynamics)
				"D": _spawn(DOOR, pos, dynamics)
				"T": _spawn(SWITCH, pos, dynamics)
			x+=1

	player = PLAYER.instantiate()
	player.global_position = Vector2(spawn_tile.x*TILE_SIZE+16, spawn_tile.y*TILE_SIZE+10)
	player_container.add_child(player)
	player.checkpoint_position = player.global_position

	for line in sections.get("WIND", []):
		var wind_line := str(line)
		if not wind_line.begins_with("zone="): continue
		var values: PackedStringArray = wind_line.trim_prefix("zone=").split(",")
		if values.size() < 7: continue
		var zone = WIND.instantiate()
		zone.position = Vector2((float(values[0])+float(values[2])/2.0)*TILE_SIZE, (float(values[1])+float(values[3])/2.0)*TILE_SIZE)
		zone.configure(Vector2(float(values[2]),float(values[3]))*TILE_SIZE, _direction(values[4]), float(values[5]), _dimension(values[6]))
		dynamics.add_child(zone)

	for line in sections.get("FRAGMENT", []):
		var record := _record(line)
		if record.has("id") and record.has("pos"):
			var item = FRAGMENT.instantiate(); item.configure(record.id, 0)
			item.position = _tile_center(_parse_vec2(record.pos)); collectibles.add_child(item)
	for line in sections.get("MEMORY", []):
		var record := _record(line)
		if record.has("id") and record.has("pos"):
			var item = MEMORY.instantiate(); item.configure(record.id, 1, record.get("text", "A memory stirs in the wind."))
			item.position = _tile_center(_parse_vec2(record.pos)); collectibles.add_child(item)
	for line in sections.get("CHECKPOINT", []):
		var record := _record(line)
		if record.has("pos"): _spawn(CHECKPOINT, _tile_center(_parse_vec2(record.pos)), dynamics)

	for line in sections.get("MOVING", []):
		var record := _record(line)
		if not record.has("pos"): continue
		var item = MOVING.instantiate(); item.position = _tile_center(_parse_vec2(record.pos))
		item.configure(_parse_vec2(record.get("offset", "5,0"))*TILE_SIZE, float(record.get("speed","80")), _dimension(record.get("dimension","ANY")))
		dynamics.add_child(item)
	for line in sections.get("MOVING_HAZARD", []):
		var record := _record(line)
		if not record.has("pos"): continue
		var item = MOVING_HAZARD.instantiate(); item.position = _tile_center(_parse_vec2(record.pos))
		item.configure(_parse_vec2(record.get("offset","0,-4"))*TILE_SIZE, float(record.get("speed","95")), _dimension(record.get("dimension","ANY")))
		dynamics.add_child(item)
	for line in sections.get("DOOR", []):
		var record := _record(line); if not record.has("pos"): continue
		var item = DOOR.instantiate(); item.position = _tile_center(_parse_vec2(record.pos))
		item.configure(record.get("link","A"), _dimension(record.get("dimension","ANY"))); dynamics.add_child(item)
	for line in sections.get("SWITCH", []):
		var record := _record(line); if not record.has("pos"): continue
		var item = SWITCH.instantiate(); item.position = _tile_center(_parse_vec2(record.pos))
		item.configure(record.get("link","A"),str(record.get("crate_only","false")).to_lower()=="true"); dynamics.add_child(item)
	for line in sections.get("FAN", []):
		var record := _record(line); if not record.has("pos"): continue
		var item = FAN.instantiate(); item.position = _tile_center(_parse_vec2(record.pos)); dynamics.add_child(item)
	for line in sections.get("TUTORIAL", []):
		var record := _record(line); if not record.has("pos"): continue
		var item = TUTORIAL.instantiate(); item.position = _tile_center(_parse_vec2(record.pos)); item.configure(record.get("text","")); dynamics.add_child(item)

	var goal_record := _first_record("GOAL")
	var goal_pos := map_goal_pos
	if goal_record.has("pos"): goal_pos = _tile_center(_parse_vec2(goal_record.pos))
	if goal_pos.x > -100:
		var goal = GOAL.instantiate(); goal.position = goal_pos; goal.configure(goal_next); dynamics.add_child(goal)

	if str(level_data.get("start_dimension","STILL")).to_upper() == "BREEZE":
		DimensionManager.set_dimension(DimensionManager.Dimension.BREEZE)
	else: DimensionManager.set_dimension(DimensionManager.Dimension.STILL)
	player.checkpoint_dimension=DimensionManager.current_dimension

	if bool(str(level_data.get("finale","false")).to_lower() == "true"):
		var collapse_void = VOID.instantiate(); collapse_void.position = Vector2(-420, 250); collapse_void.active = true; dynamics.add_child(collapse_void)

func _spawn_platform(scene: PackedScene, pos: Vector2, parent: Node) -> Node:
	var item = scene.instantiate(); item.position = pos; parent.add_child(item); return item

func _spawn(scene: PackedScene, pos: Vector2, parent: Node) -> Node:
	var item = scene.instantiate(); item.position = pos; parent.add_child(item); return item

func _value(section: String, key: String, fallback: String) -> String:
	for line in sections.get(section, []):
		if line.begins_with(key+"="): return line.trim_prefix(key+"=").strip_edges()
	return fallback

func _first_record(section: String) -> Dictionary:
	var lines: Array = sections.get(section, [])
	return _record(lines[0]) if not lines.is_empty() else {}

func _record(line: String) -> Dictionary:
	var result := {}
	var content := line
	if "=" in line:
		var leading_key := line.split("=", true, 1)[0].strip_edges()
		if leading_key not in ["id", "pos", "offset", "text", "link", "speed", "dimension", "next_level", "crate_only"]:
			content = line.split("=", true, 1)[1]
	var parts := content.split(",")
	# Pos consumes two values; other fields are key=value.
	var i := 0
	while i < parts.size():
		var part := parts[i].strip_edges()
		if "=" in part:
			var pair := part.split("=", true, 1)
			var key := pair[0].strip_edges(); var value := pair[1].strip_edges()
			if key in ["pos", "offset"] and i+1 < parts.size() and "=" not in parts[i+1]:
				value += "," + parts[i+1].strip_edges(); i += 1
			if key == "text" and i+1 < parts.size():
				for j in range(i+1,parts.size()): value += "," + parts[j].strip_edges()
				result[key] = value; break
			result[key] = value
		i += 1
	return result

func _parse_vec2(value: String) -> Vector2:
	var parts := value.split(",")
	return Vector2(float(parts[0]), float(parts[1])) if parts.size() >= 2 else Vector2.ZERO

func _tile_center(tile: Vector2) -> Vector2:
	return tile*TILE_SIZE + Vector2(TILE_SIZE/2,TILE_SIZE/2)

func _dimension(value: String) -> int:
	match value.strip_edges().to_upper():
		"STILL": return DimensionManager.Dimension.STILL
		"BREEZE": return DimensionManager.Dimension.BREEZE
		_: return -1

func _direction(value: String) -> Vector2:
	match value.strip_edges().to_upper():
		"LEFT": return Vector2.LEFT
		"UP": return Vector2.UP
		"DOWN": return Vector2.DOWN
		_: return Vector2.RIGHT
