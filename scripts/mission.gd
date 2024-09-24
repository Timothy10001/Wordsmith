extends CanvasLayer

@onready var MissionTitle = $Panel/VBoxContainer/MissionTitle
@onready var MissionDescription = $Panel/VBoxContainer/MissionDescription

var mission_title_list: Array[String] = ["Tutorial", "[center]Mr. Cheese's Dilemma", "[center]Icy Intersection Intervention"]
var mission_description_list: Array[String] = ["Tutorial", "[center]Help out Mr. Cheese with his rat problem!", "[center]Help out the snowmen by teaching the drivers how to read!"]


func _on_yes_pressed():
	Global.confirm_mission.emit()


func _on_no_pressed():
	Global.cancel_mission.emit()
