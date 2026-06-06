extends CanvasLayer


@onready var click: AudioStreamPlayer2D = $click

func change_scean(level_number,text_):
	
	click.play()
	if level_number!=0:
		$Label.add_theme_font_override("font",LanguageManager.get_font())
		var level_word = "المستوى: " if LanguageManager.current_lang == 1 else "Level: "
		$Label.text = level_word + str(level_number)+"\n"+text_
		
	else:
		$Label.text=text_
	$AnimationPlayer.play("Fade")
	# انتظار انتهاء الأنميشن قبل تغيير المشهد
	await $AnimationPlayer.animation_finished# تغيير 
	if level_number<=Gm.MAX_LVL:
		get_tree().change_scene_to_file("res://scenes/levels/"+str(level_number)+".tscn")
		get_tree().paused=true
		await  get_tree().process_frame
		# إنهاء الأنميشن (ظهور المرحلة الج
		$AnimationPlayer.play_backwards("Fade")
		await $AnimationPlayer.animation_finished
		get_tree().paused=false
	
