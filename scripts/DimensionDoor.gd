extends StaticBody2D

@export var link_id := "A"
@export_enum("STILL:0", "BREEZE:1", "ANY:-1") var open_dimension := -1
@export var door_size := Vector2(28, 192)
var switch_open := false
var open := false

func _ready() -> void:
	add_to_group("dimension_doors")
	var shape:=RectangleShape2D.new();shape.size=door_size;$CollisionShape2D.shape=shape
	DimensionManager.dimension_changed.connect(func(_value): _refresh())
	_refresh()

func configure(id: String, requirement: int) -> void:
	link_id = id; open_dimension = requirement
	if is_inside_tree(): _refresh()

func set_link_state(id: String, value: bool) -> void:
	if id == link_id:
		switch_open = value; _refresh()

func _refresh() -> void:
	open = switch_open or (open_dimension >= 0 and DimensionManager.current_dimension == open_dimension)
	$CollisionShape2D.set_deferred("disabled", open)
	queue_redraw()

func _draw() -> void:
	var alpha := 0.18 if open else 0.95
	draw_rect(Rect2(-door_size/2.0,door_size), Color(0.25,0.2,0.48,alpha), true)
	draw_rect(Rect2(-door_size/2.0,door_size), Color(0.45,1,0.93,alpha), false, 3)
	for y in range(int(-door_size.y/2)+10, int(door_size.y/2)-4, 16): draw_line(Vector2(-9,y),Vector2(9,y),Color(0.6,0.5,1,alpha),2)
