extends CanvasLayer

@onready var click: AudioStreamPlayer2D = $click
func change_scean(text_,target):
	click.play()
	$Label.text=text_
	$AnimationPlayer.play("Fade")
	# انتظار انتهاء الأنميشن قبل تغيير المشهد
	await $AnimationPlayer.animation_finished# تغيير 
	get_tree().change_scene_to_file(target)
	get_tree().paused=true
	await  get_tree().process_frame
	$AnimationPlayer.play_backwards("Fade")
	await $AnimationPlayer.animation_finished
	get_tree().paused=false
