extends Control

@export var facing_right:=true
@export var identity:="AERA"

func _ready()->void:queue_redraw()

func _draw()->void:
	var center:=Vector2(size.x/2,size.y*.5)
	var color:=Color(0.32,0.95,0.92,0.28) if identity=="AERA" else Color(0.65,0.48,1,0.2)
	draw_circle(center+Vector2(0,-75),42,color)
	draw_colored_polygon(PackedVector2Array([center+Vector2(-42,-28),center+Vector2(42,-28),center+Vector2(72,145),center+Vector2(-72,145)]),color)
	for r in [48,58]:draw_arc(center+Vector2(0,-75),r,0,TAU,32,Color(color,0.2),2)

