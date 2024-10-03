extends CanvasLayer

@onready var MissionTitle = $Panel/VBoxContainer/MissionTitle
@onready var MissionDescription = $Panel/VBoxContainer/MissionDescription

var mission_title_list: Array[String] = ["Tutorial", "[center]Mr. Cheese's Dilemma", "[center]Icy Intersection Intervention", "[center]Literacy Learning at Lexonia Academy"]
var mission_description_list: Array[String] = ["Tutorial", "[center]Help out Mr. Cheese with his rat problem!", "[center]Help out the snowmen by teaching the drivers how to read!", "[center]Help out the teachers and students of Lexonia Academy."]


func _on_yes_pressed():
	Global.play_sfx.emit("button_click")
	Global.confirm_mission.emit()


func _on_no_pressed():
	Global.play_sfx.emit("button_click")
	Global.cancel_mission.emit()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Global.play_sfx.emit("button_click")
		Global.cancel_mission.emit()
