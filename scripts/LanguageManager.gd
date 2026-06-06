extends Node
# تأكد من أن أسماء الخطوط صحيحة داخل مجلد Fonts
var font_ar = preload("res://Fonts/arabic.ttf") 
var font_en = preload("res://Fonts/english.ttf")
@export var size_en:int=25
@export var size_ar:int=18
var current_lang = 0 # (0 للإنجليزي، 1 للعربي)
var words = {
	"cong":["congratulation :;","تهانينا :;"],
	#"Level": [" level1:", "المستوى 1:"],
	"PROGRESS": ["This is your progress inthis level, and in general.You can replay the level \n if you,want to complete it entirely.", "هذا هو تقدمك في هذا المستوى، وفي لعموم. يمكنك إعادة لعب المستوى إذا كنت تريد إكماله بالكامل."],
	"TOTAL": ["TOTAL SCORE: ", "المجموع الكلي:"],
	"SCORE": [",lvl_score:", ",درجة_المستوى:"],
	"SETTINGS": ["SETTINGS", "الإعدادات"],
	"SOUNDS & LANGUAGE": ["SOUNDS & LANGUAGE", "  الأصوات واللغة  "],
	"ABOUT2": ["About AS!", "حولنا!"],
	"END_STORY": [
	"You have freed yourself from the damn life,\nand you no longer need existential anxiety and\nconstant fear of your presence in life.\nThis pain is over, you have not thought about\nyour future and you will not be afraid of it,\nyour responsibilities and your harsh and\ninappropriate living conditions.\nEnjoy your death.",
	"لقد حررت نفسك من هذه الحياة اللعينة،\nولم تعد بحاجة إلى القلق الوجودي والخوف\nالمستمر من وجودك في الحياة.\nانتهى هذا الألم، لم تعد تفكر في مستقبلك\nولن تخاف منه بعد الآن، ولا من مسؤولياتك\nوظروفك المعيشية القاسية وغير الملائمة.\nاستمتع بموتك."],
	"THANKS_MESSAGE": [
	"thanks for playing / We hope you\nenjoyed the game. Don't forget to wait\nfor the full version on March 14, 2026.\nIf you want to support us, you can watch an ad\nor check out the latest new games and content.",
	"شكراً لك على اللعب / نتمنى أنك\nاستمتعت باللعبة. لا تنسَ انتظار\nالنسخة الكاملة في 14 مارس 2026.\nإذا كنت تريد دعمنا، يمكنك مشاهدة إعلان\nأو تفقد أحدث ألعابنا ومحتوياتنا الجديدة."],



	# نصوص القائمة الرئيسية (Main Menu)
	"PLAY": ["PLAY", "اللعب"],
	"SKIP": ["SKIP", "تخطي"],
	"HOME": ["HOME", "المنزل"],
	"NEXT": ["NEXT", "التالي"],
	#"ABOUT": ["ABOUT", "حول اللعبة"],
	"QUIT": ["QUIT", "خروج"],
	"AD":["support as!","ادعمنا!!" ],
	"THX":["Thank you, hero!\n Your support helps\n us make the game better ❤️"," شكراً لك يا بطل\n دعمك يساعدنا على جعل \n اللعبة أفضل ❤️ " ],
	
	# نصوص قائمة التوقف (Pause Menu)
	"PAUSE_MENU": ["PAUSE MENU", "قائمة التوقف"],
	"RESUME": ["RESUME", "استئناف"],
	"RETRY": ["RETRY", "إعادة"],
	"LVL": ["LVL:", "المستوى:"],
	
	# نصوص "حولنا" (About Us)
	
	
	
	# نصوص الرسائل والقصة
	"MISSION_COMPLETE": [
		"COMPLETE YOUR MISSION TOWARDS YOUR GRAVE.\nYOUR MISSION IS DEATH.\nYOU STRONGLY DESIRE DEATH. HELP YOURSELF TO\nDIE IN YOUR GRAVE.\nSEARCH FOR YOUR GRAVE.\nYOU MUST ALSO GATHER 38 SOULS WITH YOU TO OPEN\nTHE GRAVE AND BE FREED FROM THE CURSE OF IMMORTALITY.",
		
		"أكمل مهمتك نحو قبرك.\nمهمتك هي الموت.\nأنت ترغب في الموت بشدة. ساعد نفسك\nلتموت في قبرك.\nابحث عن قبرك.\nيجب عليك أيضاً جمع 38 روحاً معك لفتح\nالقبر وتتحرر من لعنة الخلود."
		],
	"DEATH_MESSAGE": [
		"YOU HAVE DIED, OR IN FACT, YOU HAVE NOT DIED YET, BUT PERHAPS YOU FAILED TO GO TO YOUR GRAVE.\nIF YOU HAVEN'T DONE THIS YET, WHAT ARE YOU WAITING FOR?",
		"لقد مت، أو في الحقيقة، أنت لم تمت بعد، ولكن ربما فشلت في الذهاب إلى قبرك.\nإذا لم تفعل هذا بعد، فماذا تنتظر؟"
	],

	# 2. نص الإعلانات (من صورة شاشة الخسارة/الإعادة)
	"REPLAY_AD": [
		"YOU CAN REPLAY THE GAME, CONTINUE PLAYING,\nGO BACK A TURN,\nOR SKIP A TURN IN EXCHANGE FOR AN AD.",
		"يمكنك إعادة اللعبة، أو مواصلة اللعب،\nأو العودة دوراً للخلف،\nأو تخطي دور مقابل مشاهدة إعلان."
	],
	
	"LEVEL_WORD":["Level","المرحلة"],
}
func get_text(key):
	if words.has(key):
		return words[key][current_lang]
	return key

func get_font():
	return font_ar if current_lang == 1 else font_en
func apply_translations(root_node):
	
	# نبحث في العقدة الحالية وكل أبنائها
	for child in root_node.get_children():
		# إذا وجدنا Label أو Button (لأن الأزرار فيها نصوص أيضاً)
		if child is Label or child is Button:
			if words.has(child.name):
				child.text = get_text(child.name)
				child.add_theme_font_override("font", get_font())
				if child is Label:child.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT if current_lang==1 else HORIZONTAL_ALIGNMENT_LEFT
				child.layout_direction = Control.LAYOUT_DIRECTION_RTL if current_lang == 1 else Control.LAYOUT_DIRECTION_LTR
		if child.get_child_count() > 0:
			apply_translations(child)
var save_path = "user://language_settings.cfg"
var config = ConfigFile.new()
var player_name = ""
func save_language(lang_index):
	current_lang = lang_index
	config.load(save_path) # تحميل الملف أولاً لضمان عدم مسح البيانات الأخرى
	config.set_value("Settings", "language", lang_index)
	config.save(save_path)
	print("تم حفظ اللغة بنجاح: ", lang_index)
func save_player_name(new_name):
	player_name = new_name
	config.load(save_path) 
	config.set_value("Profile", "player_name", new_name)
	config.save(save_path)
	print("تم حفظ الاسم بنجاح: ", new_name)
func load_all_data():
	var err = config.load(save_path)
	if err == OK:
		current_lang = config.get_value("Settings", "language", 0)
		player_name = config.get_value("Profile", "player_name", "")
func _ready() -> void:
	load_all_data() # (0 للإنجليزي، 1 للعربي)
	pass
