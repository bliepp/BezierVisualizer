extends ColorRect
class_name Bezier


enum DIMENSION {QUADRATIC, CUBIC}


func qlerp(a, b, c, t) -> float:
	return lerp(lerp(a, b, t), lerp(b, c, t), t)
func clerp(a, b, c, d, t) -> float:
	return lerp(qlerp(a, b, c, t), qlerp(b, c, d, t), t)


export var start_handle: NodePath
export var end_handle: NodePath
export var modifier_handle1: NodePath
export var modifier_handle2: NodePath
export (float, 1, 10) var width = 2.5
export (int) var segments = 500


export (int, "Off", "On") var draw_dots = 1
export (int, "Off", "On") var draw_handles = 1
export (int, "Off", "On") var draw_casteljau_lines = 0
export (int, "Off", "On") var animate = 1
export (int, "Quadratic", "Cubic") var dimension = DIMENSION.CUBIC
export (float) var animate_speed = 1.0


onready var start = get_node(start_handle)
onready var end = get_node(end_handle)
onready var handle1 = get_node(modifier_handle1)
onready var handle2 = get_node(modifier_handle2)


onready var time = 0.0


func _ready() -> void:
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	if animate:
		time = fmod(time + 0.5*delta*animate_speed, 1.0)
	update()


func _draw() -> void:
	# if both handles of the cubic bezier are at the smae place it is
	# equivalent to a quadratic one. This is of course less optimized
	# but very convenient
	var _handle2 : Node
	match dimension:
		DIMENSION.QUADRATIC:
			_handle2 = handle1
		DIMENSION.CUBIC:
			_handle2 = handle2

	# draw handle lines
	if draw_handles or draw_casteljau_lines:
		draw_line(start.position, handle1.position, Color.gray, width*0.7, true)
		draw_line(end.position, _handle2.position, Color.gray, width*0.7, true)

	# generate casteljau lines explicitly
	if draw_casteljau_lines:
		var lerp_start_h1 = lerp(start.position, handle1.position, time)
		var lerp_middle = lerp(handle1.position, _handle2.position, time)
		var lerp_h2_end = lerp(_handle2.position, end.position, time)
		var inner_1 = lerp(lerp_start_h1, lerp_middle, time)
		var inner_2 = lerp(lerp_middle, lerp_h2_end, time)

		draw_line(handle1.position, _handle2.position, Color.gray, width*0.7, true)
		draw_line(lerp_start_h1, lerp_middle, Color.gray, width*0.7, true)
		draw_line(lerp_middle, lerp_h2_end, Color.gray, width*0.7, true)
		draw_line(inner_1, inner_2, Color.gray, width*0.7, true)

	# generate bezier curve
	var maximum_t = (segments+1)*time
	var points = PoolVector2Array()
	for i in range(maximum_t):
		var t = i/float(segments)
		var p = clerp(start.position, handle1.position, _handle2.position, end.position, t)
		points.append(p)
	if len(points) > 1:
		draw_polyline(points, Color.black, width, true)
		if draw_casteljau_lines and draw_dots:
			draw_circle(points[-1], end.size, Color.gray)

	# draw handle dots
	if draw_dots:
		draw_circle(start.position, start.size, start.color)
		draw_circle(end.position, end.size, end.color)
		draw_circle(handle1.position, handle1.size, handle1.color)
		draw_circle(_handle2.position, _handle2.size, _handle2.color)


func toggle_playpause(button_pressed: bool) -> void:
	animate = int(button_pressed)
func press_start() -> void:
	time = 0.0
func press_end() -> void:
	time = 1.0
func change_speed(index: int) -> void:
	animate_speed = (index+1)*0.5
func toggle_dots(button_pressed: bool) -> void:
	draw_dots = int(button_pressed)
func toggle_handles(button_pressed: bool) -> void:
	draw_handles = int(button_pressed)
func toggle_casteljau(button_pressed: bool) -> void:
	draw_casteljau_lines = int(button_pressed)
func change_segments(value: float) -> void:
	segments = int(value)
func change_dimension(index: int) -> void:
	dimension = index
