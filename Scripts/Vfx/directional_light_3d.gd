extends DirectionalLight3D

var tween : Tween

func _ready():
	GlobalEventHolder.turnEnd.connect(func(_x): _night())
	GlobalEventHolder.turnStart.connect(func(_x): _day())

func _night():
	tween = create_tween()
	tween.tween_property(self,"rotation_degrees:y",-70,0.15)
	tween.tween_property(self,"rotation_degrees:y",-120,0.05)
	tween.tween_callback(func(): rotation_degrees.y = 120)

func _day():
	tween = create_tween()
	tween.tween_property(self,"rotation_degrees:y",0,0.25)
