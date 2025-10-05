extends OmniLight3D

var tween : Tween

func _ready():
	GlobalEventHolder.turnEnd.connect(func(_x): _night())
	GlobalEventHolder.turnStart.connect(func(_x): _day())

func _night():
	tween = create_tween()
	tween.tween_property(self,"visible",true,0.1)

func _day():
	tween = create_tween()
	tween.tween_property(self,"visible",false,0.15)
