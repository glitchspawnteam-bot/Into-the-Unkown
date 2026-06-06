extends Node2D


@onready var win: AudioStreamPlayer2D = $win
@onready var normal: AudioStreamPlayer2D = $normal

func _ready() -> void:
	normal.play()
func switch():
	normal.stop()
	win.play()
	win.autoplay=true
