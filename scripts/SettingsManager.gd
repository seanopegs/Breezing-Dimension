extends Node

signal settings_changed

const SETTINGS_PATH := "user://settings.cfg"
var master_volume := 0.8
var music_volume := 0.65
var sfx_volume := 0.8
var fullscreen := false
var vsync := true
var screen_shake := true
var dialogue_speed := 38.0
var auto_advance := false

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	master_volume = float(cfg.get_value("audio", "master", master_volume))
	music_volume = float(cfg.get_value("audio", "music", music_volume))
	sfx_volume = float(cfg.get_value("audio", "sfx", sfx_volume))
	fullscreen = bool(cfg.get_value("display", "fullscreen", fullscreen))
	vsync = bool(cfg.get_value("display", "vsync", vsync))
	screen_shake = bool(cfg.get_value("display", "screen_shake", screen_shake))
	dialogue_speed = float(cfg.get_value("gameplay", "dialogue_speed", dialogue_speed))
	auto_advance = bool(cfg.get_value("gameplay", "auto_advance", auto_advance))

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("display", "vsync", vsync)
	cfg.set_value("display", "screen_shake", screen_shake)
	cfg.set_value("gameplay", "dialogue_speed", dialogue_speed)
	cfg.set_value("gameplay", "auto_advance", auto_advance)
	cfg.save(SETTINGS_PATH)
	apply_settings()
	settings_changed.emit()

func apply_settings() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	_set_bus("Master", master_volume)
	_set_bus("Music", music_volume)
	_set_bus("SFX", sfx_volume)

func _set_bus(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		AudioServer.set_bus_volume_db(index, linear_to_db(max(linear, 0.001)))
		AudioServer.set_bus_mute(index, linear <= 0.001)

