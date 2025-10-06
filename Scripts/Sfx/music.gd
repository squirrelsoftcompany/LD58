extends AudioStreamPlayer3D

@onready var music : AudioStreamPlaybackInteractive = self.get_stream_playback()

func _ready():
	GlobalEventHolder.startAmbush.connect(func(_x):_ambush_in())
	GlobalEventHolder.endAmbush.connect(_ambush_out)

func _ambush_in():
	music.switch_to_clip(1)

func _ambush_out():
	music.switch_to_clip(0)
