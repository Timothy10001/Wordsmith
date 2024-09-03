extends CanvasLayer

@onready var MissionTitle = $Panel/VBoxContainer/MissionTitle
@onready var MissionDescription = $Panel/VBoxContainer/MissionDescription




func _on_yes_pressed():
	Global.confirm_mission.emit()
	queue_free()


func _on_no_pressed():
	Global.cancel_mission.emit()
	queue_free()
