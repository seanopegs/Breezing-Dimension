extends Control

var commands:Array[Dictionary]=[]
var command_index:=-1
var next_destination:="menu"
var current_text:=""
var visible_count:=0.0
var typing:=false
var wait_left:=0.0
var path:=""
var paused_overlay:ColorRect
var scene_background:="procedural://story"
var scene_music:="procedural://story"

@onready var speaker_label:Label=$DialogueBox/Margin/VBox/SpeakerName
@onready var dialogue_label:Label=$DialogueBox/Margin/VBox/DialogueText
@onready var indicator:Label=$DialogueBox/Margin/VBox/ContinueIndicator

func _ready()->void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	path=GameManager.pending_story_path if not GameManager.pending_story_path.is_empty() else "res://data/story/prologue.txt"
	_parse(path)
	$Background.set_mood(scene_background)
	AudioManager.play_music(scene_music)
	_apply_readability_scale()
	$SkipButton.visible=path in SaveManager.data.stories_seen
	$SkipButton.pressed.connect(_finish_story)
	_next_command()

func _apply_readability_scale()->void:
	var multiplier:=UIFactory.ui_multiplier()
	speaker_label.add_theme_font_size_override("font_size",roundi(18*multiplier))
	dialogue_label.add_theme_font_size_override("font_size",roundi(21*multiplier))
	indicator.add_theme_font_size_override("font_size",roundi(14*multiplier))
	$SkipButton.add_theme_font_size_override("font_size",roundi(14*multiplier))

func _parse(file_path:String)->void:
	var file:=FileAccess.open(file_path,FileAccess.READ)
	if file==null:push_error("Missing story: "+file_path);return
	var section:=""
	for raw in file.get_as_text().split("\n"):
		var line:=raw.strip_edges()
		if line.is_empty() or line.begins_with(";"):continue
		if line.begins_with("[") and line.ends_with("]"):
			section=line.trim_prefix("[").trim_suffix("]");continue
		if section=="DIALOGUE" and "|" in line:
			var pair:=line.split("|",true,1);commands.append({"type":"dialogue","speaker":pair[0],"text":pair[1].replace("\\n","\n")})
		elif section=="WAIT":commands.append({"type":"wait","duration":float(line)})
		elif section=="SCENE" and line.begins_with("background="):scene_background=line.trim_prefix("background=")
		elif section=="SCENE" and line.begins_with("music="):scene_music=line.trim_prefix("music=")
		elif section=="END" and line.begins_with("next="):next_destination=line.trim_prefix("next=")

func _process(delta:float)->void:
	if get_tree().paused:return
	if wait_left>0:
		wait_left-=delta
		if wait_left<=0:_next_command()
		return
	if typing:
		visible_count+=SettingsManager.dialogue_speed*delta
		dialogue_label.visible_characters=int(visible_count)
		if visible_count>=current_text.length():
			typing=false;dialogue_label.visible_characters=-1;indicator.visible=true
			if SettingsManager.auto_advance:
				var timer:=get_tree().create_timer(1.4);timer.timeout.connect(func():if not typing:_next_command())

func _unhandled_input(event:InputEvent)->void:
	if event.is_action_pressed("pause"):
		get_tree().paused=not get_tree().paused;$PauseOverlay.visible=get_tree().paused;get_viewport().set_input_as_handled();return
	if get_tree().paused:return
	if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		if typing:
			typing=false;dialogue_label.visible_characters=-1;indicator.visible=true
		else:_next_command()
		get_viewport().set_input_as_handled()

func _next_command()->void:
	command_index+=1;indicator.visible=false
	if command_index>=commands.size():_finish_story();return
	var cmd:=commands[command_index]
	if cmd.type=="wait":wait_left=float(cmd.duration);return
	current_text=str(cmd.text);visible_count=0;typing=true
	speaker_label.text=str(cmd.speaker) if str(cmd.speaker)!="NARRATOR" else ""
	dialogue_label.text=current_text;dialogue_label.visible_characters=0
	$CharacterPortraitLeft.visible=str(cmd.speaker)=="PLAYER"
	$CharacterPortraitRight.visible=str(cmd.speaker)=="AERA"

func _finish_story()->void:
	SaveManager.mark_story_seen(path);get_tree().paused=false;GameManager.route_destination(next_destination)
