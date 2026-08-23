extends Node

signal save_changed

const SAVE_PATH := "user://savegame.json"
const DEFAULT_DATA := {
	"current_level": 1,
	"unlocked_level": 1,
	"fragments": [],
	"memories": [],
	"endings": [],
	"stories_seen": [],
	"play_time": 0.0,
	"deaths": 0
}

var data: Dictionary = DEFAULT_DATA.duplicate(true)
var _play_timer := 0.0

func _ready() -> void:
	load_game()

func _process(delta: float) -> void:
	if get_tree().current_scene and not get_tree().paused:
		_play_timer += delta
		if _play_timer >= 30.0:
			data.play_time = float(data.get("play_time", 0.0)) + _play_timer
			_play_timer = 0.0
			save_game()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func new_game() -> void:
	data = DEFAULT_DATA.duplicate(true)
	_play_timer = 0.0
	save_game()

func load_game() -> void:
	if not has_save():
		data = DEFAULT_DATA.duplicate(true)
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		data = DEFAULT_DATA.duplicate(true)
		for key in parsed:
			data[key] = parsed[key]

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
	save_changed.emit()

func collect_fragment(id: String) -> bool:
	if id in data.fragments:
		return false
	data.fragments.append(id)
	save_game()
	return true

func collect_memory(id: String) -> bool:
	if id in data.memories:
		return false
	data.memories.append(id)
	save_game()
	return true

func has_collectible(id: String) -> bool:
	return id in data.fragments or id in data.memories

func unlock_level(level: int) -> void:
	data.unlocked_level = max(int(data.unlocked_level), level)
	data.current_level = level
	save_game()

func add_ending(id: String) -> void:
	if id not in data.endings:
		data.endings.append(id)
	save_game()

func mark_story_seen(path: String) -> void:
	if path not in data.stories_seen:
		data.stories_seen.append(path)
		save_game()

func can_true_ending() -> bool:
	return data.fragments.size() >= 18 and data.memories.size() >= 5

func fragments_for_level(level: int) -> int:
	var prefix := "L%d_F" % level
	var count := 0
	for id in data.fragments:
		if String(id).begins_with(prefix): count += 1
	return count

func has_memory_for_level(level: int) -> bool:
	return "L%d_MEMORY" % level in data.memories

