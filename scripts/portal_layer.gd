extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LanguageManager.apply_translations(self)
	hide()
var level_num=1

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float ) -> void:
	
	
	if LanguageManager.current_lang==0:
		%Level.text="level:"+str(get_tree().current_scene.level_id)
		$Control/Control.show()
		$Control/Control2.hide()
	else:
		%Level_AR.text=  "المستوى:"+str(get_tree().current_scene.level_id)
		$Control/Control.hide()
		$Control/Control2.show()
		

	level_num=get_tree().current_scene.level_id
	%score_lvl .text=str(get_tree().current_scene.coins_collected)
	%score_lvl_AR.text=str(get_tree().current_scene.coins_collected)
	%score_total.text=str(int(Gm.data_save["total"]))
	%score_total_AR.text=str(int(Gm.data_save["total"]))
	if get_tree().current_scene.coins_collected==2:
		$how/ThumbsUp.show()
		$how/ThumbsDown.hide()
	else:
		$how/ThumbsUp.hide()
		$how/ThumbsDown.show()
func show_():
	get_tree().paused=true
	show()
	$AnimationPlayer.play()
func _on_retry_win_pressed() -> void:
	get_tree().paused=false
	%click.play()
	get_tree().reload_current_scene()
func _on_lvl_pressed() -> void:
	$".".hide()
	TrnBack.change_scean("home lvls","res://scenes/main_select.tscn")
func _on_next_pressed() -> void:
	Trnsitionlayer.get_node("Label").add_theme_font_override("font",LanguageManager.get_font())
	if LanguageManager.current_lang==0:
		Trnsitionlayer.change_scean(int(level_num)+1,"you must be die")
	else:
		Trnsitionlayer.change_scean(int(level_num)+1,"يجب أن تموت" )
	get_tree().paused=false
  
