extends Node2D

@export var direction := Vector2.RIGHT
@export var strength := 350.0
@export var zone_size := Vector2(160,64)
var _time := 0.0

func _ready() -> void:
	var zone = $WindZone
	zone.configure(zone_size,direction,strength,DimensionManager.Dimension.BREEZE)
	zone.position = direction.normalized() * maxf(zone_size.x,zone_size.y) * 0.5

func _process(delta: float) -> void:
	if DimensionManager.is_breeze(): _time += delta*8.0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-16,-16,32,32),Color("293c59"),true)
	draw_circle(Vector2.ZERO,13,Color("65f5e8"),false,3)
	for i in 4:
		var a := _time+i*TAU/4
		var d := Vector2.from_angle(a)
		draw_colored_polygon(PackedVector2Array([Vector2.ZERO,d*11,d.rotated(0.8)*6]),Color("72e8db"))
	draw_circle(Vector2.ZERO,3,Color.WHITE)
