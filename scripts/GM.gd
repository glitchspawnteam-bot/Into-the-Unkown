extends Node
var come=false
const MAX_LVL = 20
var death = 0
var data_save = {
	"un_locked": 1,
	"total": 0,
	"levels": {
		"1": {"coins": 0, "collected": {}},
		"2": {"coins": 0, "collected": {}},
		"3": {"coins": 0, "collected": {}},
		"4": {"coins": 0, "collected": {}},
		"5": {"coins": 0, "collected": {}},
		"6": {"coins": 0, "collected": {}},
		"7": {"coins": 0, "collected": {}},
		"8": {"coins": 0, "collected": {}},
		"9": {"coins": 0, "collected": {}},
		"10": {"coins": 0, "collected": {}},
		"11": {"coins": 0, "collected": {}},
		"12": {"coins": 0, "collected": {}},
		"13": {"coins": 0, "collected": {}},
		"14": {"coins": 0, "collected": {}},
		"15": {"coins": 0, "collected": {}},
		"16": {"coins": 0, "collected": {}},
		"17": {"coins": 0, "collected": {}},
		"18": {"coins": 0, "collected": {}},
		"19": {"coins": 0, "collected": {}},
		"20": {"coins": 0, "collected": {}},
	},
}

func complete_level(level_id, coins_collected, collected):
	data_save["levels"][level_id]["coins"] = coins_collected
	for i in collected:
		data_save["levels"][level_id]["collected"][i] = true
	data_save["total"] = 0
	for i in range(1, MAX_LVL + 1):
		data_save["total"] += data_save["levels"][str(i)]["coins"]


func _process(_delta: float) -> void:
	pass

func is_open(level_id):
	#print(data_save["un_locked"])
	if level_id <= data_save["un_locked"]:
		return true
	else:
		return false

func open(level_id):
	if data_save["un_locked"] < int(level_id) + 1:
		data_save["un_locked"] = int(level_id) + 1

func save_game():
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data_save)
		file.store_line(json_string)
		file.close()
		print("تم الحفظ بنجاح!")

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("لا يوجد ملف حفظ مسبق")
		return

	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if file:
		var json_string = file.get_line()
		file.close()

		var json = JSON.new()
		var error = json.parse(json_string)

		if error == OK:
			data_save = json.data
			print("تم تحميل البيانات بنجاح!")
		else:
			print("خطأ في تحليل ملف الحفظ: ", json.get_error_message())

func _ready() -> void:
	load_game()
	pass
