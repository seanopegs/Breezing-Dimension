extends Control

var _time:=0.0
var _breeze:=false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	DimensionManager.set_dimension(DimensionManager.Dimension.STILL)
	var timer:=Timer.new();timer.wait_time=4.5;timer.autostart=true;timer.timeout.connect(_toggle);add_child(timer)

func _toggle() -> void:
	_breeze=not _breeze;DimensionManager.set_dimension(DimensionManager.Dimension.BREEZE if _breeze else DimensionManager.Dimension.STILL,true);queue_redraw()

func _process(delta:float)->void:
	_time+=delta;queue_redraw()

func _draw()->void:
	var bg:=Color("0a1735") if not _breeze else Color("0a5365")
	draw_rect(Rect2(Vector2.ZERO,size),bg,true)
	for i in 16:
		var x:=i*90-fmod(_time*(24 if _breeze else 4),90)
		var h:=120+sin(i*1.73)*70
		draw_colored_polygon(PackedVector2Array([Vector2(x,size.y),Vector2(x+14,size.y-h),Vector2(x+45,size.y-h-25),Vector2(x+74,size.y)]),Color("071128aa"))
	var moon:=Vector2(size.x*.78,size.y*.25)
	draw_circle(moon,76,Color(0.38,1,0.93,0.12 if _breeze else 0.05))
	draw_arc(moon,76,0,TAU,64,Color(0.45,1,0.96,0.3),2)
	for i in 24:
		var p:=Vector2(fmod(i*173.0+_time*(70 if _breeze else 8),size.x+160)-80,fmod(i*79.0, size.y))
		draw_line(p,p+Vector2(35 if _breeze else 8,0),Color(0.55,1,0.96,0.28),2)

