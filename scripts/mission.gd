extends CanvasLayer

@onready var MissionTitle = $Panel/VBoxContainer/MissionTitle
@onready var MissionDescription = $Panel/VBoxContainer/MissionDescription

var mission_title_list: Array[String] = ["Tutorial", "[center]Mr Cheese's Dilemma"]
var mission_description_list: Array[String] = ["Tutorial", "[center]Help out Mr. Cheese with his rat problem!"]


func _on_yes_pressed():
	Global.confirm_mission.emit()


func _on_no_pressed():
	Global.cancel_mission.emit()
