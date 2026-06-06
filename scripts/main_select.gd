extends Control
@onready var music: HSlider = $CanvasLayer/Music
@onready var sounds: HSlider = $CanvasLayer/Sounds
@onready var music_on = $CanvasLayer/Music/MusicOn
@onready var music_off = $CanvasLayer/Music/MusicOff
@onready var sfx_on = $CanvasLayer/Sounds/SoundsOn
@onready var sfx_off = $CanvasLayer/Sounds/SoundsOff
var current_version = 1  # رقم النسخة الحالية في اللعبة
var itch_url ="https://aliaprince916-commits.itch.io/gravity-fills" # ضع رابط صفحتك هنا

@onready var http_request = HTTPRequest.new()
func _ready() -> void:
	if LanguageManager.current_lang==1:
			$about_c/ABOUT_US_BODY2.visible=true
			$about_c/ABOUT_US_BODY.visible=false
	if LanguageManager.current_lang==0:
			$about_c/ABOUT_US_BODY2.visible=false
			$about_c/ABOUT_US_BODY.visible=true
	if Gm.come==true:
		if LanguageManager.current_lang==0:
			$CanvasLayer4/AnimationPlayer.play("new_animation")
			$CanvasLayer4/T_AR.visible=false
		if LanguageManager.current_lang==1:
			$CanvasLayer4/AnimationPlayer.play("new_animation")
			$CanvasLayer4/T.visible=false
	add_child(http_request)
	
	# ربط إشارة انتهاء الطلب بالفنكشن الخاصة بنا
	http_request.request_completed.connect(_on_request_completed)
	
	# إرسال طلب لصفحة Itch.io لقراءتها
	var error = http_request.request(itch_url)
	if error != OK:
		print("حدث خطأ في الاتصال بالإنترنت")
	LanguageManager.apply_translations(self)
	await get_tree().process_frame
	setup_slider(music, "music")
	setup_slider(sounds, "sfx")
	$main.show()
	$levels.hide()
	$about_c.hide()
	if Gm.is_open(Gm.MAX_LVL):
		$main/BigStar.show()
func _process(delta: float) -> void:
	
	%score.text=str(int(Gm.data_save["total"]))+"/38"
	if Gm.is_open(20):
		$"world/grace/AnimationSheetCharacter(1)".show()
		$world/grace/DoorClosed.modulate=Color()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_play_pressed() -> void:
	
	$click.play()
	$main.hide()
	$levels.show()
	$about_c.hide()
func _on_home_pressed() -> void:
	
	
	$click.play()
	$main.show()
	$levels.hide()
	$about_c.hide()
func _on_maded_pressed() -> void:
	$main/Animtion/AnimationPlayer.play("hide_show")
	pass # Replace with function body.
func _on_youtube_pressed() -> void:
	OS.shell_open("https://www.youtube.com/@aliaPrince-z8l")
func _on_instagrame_pressed() -> void:
	OS.shell_open("https://www.instagram.com/glitch_spawn_/")
func _on_itch_pressed() -> void:
	OS.shell_open("https://aliaprince916-commits.itch.io/")
func _on_about_pressed() -> void:
	$click.play()
	$CanvasLayer.show()
func _on_quit_pressed() -> void:
	get_tree().quit()
func _on_home__pressed() -> void:
	
	$CanvasLayer.hide()
	$main/SETTINGS.show()
	$click.play()
	$main.show()
	$levels.hide()
	$about_c.hide()
func _on_settings_pressed() -> void:
	$CanvasLayer.visible=true
	%Settings.visible=false
	pass # Replace with function body.
func _on_cross_pressed() -> void:
	$CanvasLayer.visible=false
	pass # Replace with function body.
func _on_about_2_pressed() -> void:
	
	$click.play()
	$main.hide()
	$levels.hide()
	$about_c.show()
	
func setup_slider(slider: HSlider, bus_name: String):
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	
	await get_tree().process_frame
	
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(bus_idx)
	var is_muted = AudioServer.is_bus_mute(bus_idx)
	
	# ضبط قيمة السلايدر بناءً على حالة الصوت الحقيقية
	if is_muted or current_db <= -79:
		slider.value = 0.0
	else:
		slider.value = db_to_linear(current_db)
	
	print("UI_Settings: تم ضبط السلايدر لـ ", bus_name, " على قيمة: ", slider.value)
	
	_update_icon_visibility(bus_name, slider.value)
	
	# نربط الإشارة الآن فقط، بعد أن انتهينا من ضبط القيمة الابتدائية
	if not slider.value_changed.is_connected(_on_slider_changed):
		slider.value_changed.connect(func(val):
			_on_slider_changed(val, bus_name)
		)

func _on_slider_changed(value, bus_name):
	AudioManager.set_volume(bus_name, value)
	_update_icon_visibility(bus_name, value)
# 3. أضف هذه الدالة الجديدة تماماً في أسفل السكربت:
func _update_icon_visibility(bus_name: String, value: float):
	if bus_name == "music":
		music_on.visible = value > 0.01
		music_off.visible = value <= 0.01
	elif bus_name == "sfx":
		sfx_on.visible = value > 0.01
		sfx_off.visible = value <= 0.01


func _on_arabic_pressed() -> void:
	LanguageManager.current_lang=1
	$CanvasLayer.visible=false
	TrnBack.change_scean("arabic","res://scenes/main_select.tscn")
func _on_english_pressed() -> void:
	LanguageManager.current_lang=0
	$CanvasLayer.visible=false
	TrnBack.change_scean("english","res://scenes/main_select.tscn")
	
	pass # Replace with function body.



		
func _on_reward_button_pressed() -> void:
	
	$click.play()
		
		
			# 4. إظهار رسالة الشكر أو البانل
	$main/AD/Panel.show()
	$main/AD/Panel/AudioStreamPlayer2D.play()
			
	await get_tree().create_timer(2).timeout
			
	$main/AD/Panel/AudioStreamPlayer2D.stop()
	$main/AD/Panel.hide()

	


func _on_cross_2_pressed() -> void:
	$CanvasLayer2.visible=false
	pass # Replace with function body








# --- إعدادات النسخة ---



	# إضافة عقدة الطلب برمجياً لتجنب نسيانها
	

func _on_request_completed(result, response_code, headers, body):
	# التأكد أن الصفحة فتحت بنجاح (كود 200)
	if response_code == 200:
		var html_text = body.get_string_from_utf8()
		
		# البحث عن كلمة Update: داخل كود الصفحة
		if html_text.contains("Update:"):
			# تقسيم النص للحصول على الرقم الذي بعد الكلمة
			var parts = html_text.split("Update:")
			# أخذ أول حرف بعد الكلمة وتحويله لرقم
			var web_version = parts[1].substr(0, 1).to_int()
			
			# إذا كان رقم الموقع أكبر من رقم اللعبة، أظهر الشاشة
			if web_version > current_version:
				show_update_ui()

func show_update_ui():
	# تأكد أن لديك عقدة اسمها UpdateScreen وهي مخفية في البداية
	if has_node("CanvasLayer2"):
		get_node("CanvasLayer2").show()


func _on_download_pressed() -> void:
	OS.shell_open("https://aliaprince916-commits.itch.io/gravity-fills")
	pass # Replace with function body.
