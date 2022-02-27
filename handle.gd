extends Position2D
class_name BezierHandle


export (float, 1, 10) var size = 5.0 setget set_size, get_size
export (Color, RGBA) var color = Color.black

onready var collider: CollisionShape2D = CollisionShape2D.new()

var dragging: bool = false
var hover: bool = false

func _ready() -> void:	
	var area = Area2D.new()
	area.connect("mouse_entered", self, "mouse_entered")
	area.connect("mouse_exited", self, "mouse_exited")
	add_child(area)
	
	collider.shape = CircleShape2D.new()
	collider.shape.radius = self.size*1.1
	area.add_child(collider)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and hover:
			dragging = true
		else: dragging = false
	if event is InputEventMouseMotion and dragging:
		position += event.get_relative()


func set_size(new_size: float):
	size = new_size

func get_size() -> float:
	return size


func mouse_entered():
	hover = true
func mouse_exited():
	hover = false
