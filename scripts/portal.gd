extends Area2D
# تصدير متغيرات لنقل المشهد 
@export var gr=1
# ربط بالعقد 
@onready var portal_s: AudioStreamPlayer2D = $portal_s
@onready var animation_player: AnimationPlayer = $portal_layer/AnimationPlayer
@onready var sprite_: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if gr==1:
		sprite_.flip_v=false
		sprite_.position.y=0
	elif gr==-1:
		sprite_.flip_v=true
		sprite_.position.y=8

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		timer.start()
		portal_s.play()
		body.camera_change()
		get_tree().current_scene._on_level_finished()
		Gm.open(get_tree().current_scene.level_id)
		Gm.save_game()
func change_scene():
		get_tree().paused=true
		get_tree().paused=false
func _on_timer_timeout() -> void:
		$portal_layer.show_()
