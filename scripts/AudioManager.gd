extends Node

var music_player: AudioStreamPlayer
var breeze_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var _phase_a := 0.0
var _phase_b := 0.0
var _music_style := "menu"

func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	music_player = _make_generator_player("Music")
	breeze_player = _make_generator_player("Music")
	for i in 6:
		sfx_players.append(_make_generator_player("SFX", 22050.0, 0.12))
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	SettingsManager.apply_settings()
	play_music("menu")

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _make_generator_player(bus_name: String, rate := 22050.0, length := 0.5) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = rate
	stream.buffer_length = length
	player.stream = stream
	player.bus = bus_name
	add_child(player)
	return player

func play_music(style: String) -> void:
	_music_style = style
	if not music_player.playing: music_player.play()
	if not breeze_player.playing: breeze_player.play()
	_on_dimension_changed(DimensionManager.current_dimension)

func _process(_delta: float) -> void:
	_fill_music(music_player, false)
	_fill_music(breeze_player, true)

func _fill_music(player: AudioStreamPlayer, breeze: bool) -> void:
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null: return
	var rate := 22050.0
	var base := 55.0 if "finale" in _music_style or "collapse" in _music_style else (65.4 if "story" in _music_style or "ending" in _music_style else 73.4)
	var phase := _phase_b if breeze else _phase_a
	var frames: int = mini(playback.get_frames_available(), 2048)
	for i in frames:
		var t := phase / rate
		var freq := base * (2.0 if breeze else 1.0)
		var wave := sin(TAU * freq * t) * 0.055
		wave += sin(TAU * freq * (1.5 if breeze else 2.0) * t) * 0.022
		if breeze: wave += sin(TAU * 3.0 * t) * sin(TAU * 220.0 * t) * 0.012
		playback.push_frame(Vector2(wave, wave))
		phase += 1.0
	if breeze: _phase_b = phase
	else: _phase_a = phase

func _on_dimension_changed(dimension: int) -> void:
	if not music_player or not breeze_player: return
	var tween := create_tween().set_parallel(true)
	if dimension == DimensionManager.Dimension.STILL:
		tween.tween_property(music_player, "volume_db", -3.0, 0.4)
		tween.tween_property(breeze_player, "volume_db", -35.0, 0.4)
	else:
		tween.tween_property(music_player, "volume_db", -16.0, 0.4)
		tween.tween_property(breeze_player, "volume_db", -2.0, 0.4)

func play_sfx(kind: String) -> void:
	var player: AudioStreamPlayer
	for candidate in sfx_players:
		if not candidate.playing:
			player = candidate
			break
	if player == null: player = sfx_players[0]
	player.stop()
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null: return
	var freq_map := {"jump": 330.0, "land": 110.0, "shift": 620.0, "fragment": 880.0, "memory": 520.0, "checkpoint": 740.0, "death": 95.0, "click": 440.0, "door": 165.0}
	var freq := float(freq_map.get(kind, 260.0))
	var frames := int(22050.0 * (0.18 if kind == "shift" else 0.1))
	for i in frames:
		var p := float(i) / frames
		var sweep := freq * (1.0 + (0.8 * p if kind in ["shift", "fragment"] else -0.35 * p))
		var sample := sin(TAU * sweep * float(i) / 22050.0) * (1.0 - p) * 0.22
		playback.push_frame(Vector2(sample, sample))

func _exit_tree() -> void:
	for player in [music_player,breeze_player]:
		if player:
			player.stop();player.stream=null
	for player in sfx_players:
		player.stop();player.stream=null
	sfx_players.clear()
