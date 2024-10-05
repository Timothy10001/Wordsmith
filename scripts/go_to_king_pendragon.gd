extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.dialogue_active.connect(_on_dialogue_active)


func _on_dialogue_active():
	queue_free()
