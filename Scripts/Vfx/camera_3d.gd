extends Camera3D

var mouse_pos : Vector2
var fixed : bool = false

@export var focus : Marker3D

func _ready():
	GlobalEventHolder.endAmbush.connect(func(): fixed = false)
	GlobalEventHolder.startAmbush.connect(func(): fixed = true)

func _input(event):
	var view : Vector2 = get_viewport().get_visible_rect().size
	if event is InputEventMouse and not fixed:
		mouse_pos = event.position
		focus.position.x = (mouse_pos.x - view.x/2)/1200
		focus.position.y = (mouse_pos.y - view.y/2)/-800
		look_at(focus.global_position)
