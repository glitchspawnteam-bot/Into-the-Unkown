extends CanvasLayer
@onready var click: AudioStreamPlayer2D = $click
var level_num=1


var messages = [
	{"en": "you must die", "ar": "يجب أن تموت"},
	{"en": "Forget your friends", "ar": "انسَ أصدقاءك"},
	{"en": "All of this", "ar": "كل هذا"},
	{"en": "is your bad alone", "ar": "بسبب سوءك وحدك"},
	{"en": "Gravity empties", "ar": "الجاذبية تفرغ"},
	{"en": "gravity is grave", "ar": "الجاذبية قبر"}
]
#متغير الي بعبعث ميساج لما تموت 
func _ready() -> void:
	
	$PauseMenu.hide()
	$death_screen.hide()
	$control.show()
func _physics_process(delta: float) -> void:
	%score.text=str(get_tree().current_scene.coins_collected)
	$control/info/num_lvl.text="lvl:"+str(get_tree().current_scene.level_id)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	level_num=get_tree().current_scene.level_id
	pass
func show_death_screen():
	$death_screen/DeathMessage.add_theme_font_override("font",LanguageManager.get_font())
	# 1. نختار قاموساً عشوائياً من المصفوفة
	var random_msg = messages.pick_random()
	
	# 2. نحدد اللغة بناءً على LanguageManager
	var display_text = ""
	if LanguageManager.current_lang == 0: # إنجليزي
		display_text = random_msg["en"]
	else: # عربي
		display_text = random_msg["ar"]
	
	# 3. نضع النص في الـ Label
	$death_screen/DeathMessage.text = display_text
	
	# بقية كودك كما هو
	get_tree().paused = true
	$death_screen.show()
	$PauseMenu.hide()
	$control.hide()
	
# عند الضغط علىكل زر
# مكان طبقة التحكم
func _on_pause_button_pressed() -> void:
	click.play()
	get_tree().paused=true
	$death_screen.hide()
	$PauseMenu.show()
	$control.hide()


#مكان طيقة التوقف
func _on_retry_pressed() -> void:
	click.play()
	get_tree().paused=false
	get_tree().reload_current_scene()
func _on_resume_pressed() -> void:
	click.play()
	$PauseMenu.hide()
	$death_screen.hide()
	$control.show()
	get_tree().paused=false
func _on_setting_pressed() -> void:
	TrnBack.change_scean("home","res://scenes/main_select.tscn")
	pass # Replace with function body.



# مكان ازرار طبقة  الموت   
func _on_retry_death_pressed() -> void:
	click.play()
	
	get_tree().paused=false
	get_tree().reload_current_scene()
func _on_home_death_pressed() -> void:
	TrnBack.change_scean("home","res://scenes/main_select.tscn")
	pass # Replace with function body.
