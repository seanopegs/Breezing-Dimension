extends Area2D

@export_multiline var tutorial_text := ""
var shown := false

func _ready() -> void:
	body_entered.connect(_show)
	var shape := RectangleShape2D.new(); shape.size = Vector2(80,96)
	$CollisionShape2D.shape = shape

func configure(text: String) -> void: tutorial_text = text

func _show(body: Node) -> void:
	if shown or not body.is_in_group("player"): return
	shown = true
	get_tree().call_group("game_level", "show_tutorial", tutorial_text)

