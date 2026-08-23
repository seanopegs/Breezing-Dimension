extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

func fade_in(duration:=0.35) -> void:
	overlay.modulate.a=1.0; create_tween().tween_property(overlay,"modulate:a",0.0,duration)

func fade_out(duration:=0.35) -> void:
	overlay.modulate.a=0.0; await create_tween().tween_property(overlay,"modulate:a",1.0,duration).finished

func transition_to_scene(path:String) -> void:
	await fade_out(); get_tree().change_scene_to_file(path)

