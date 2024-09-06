extends CanvasLayer

@onready var InteractButton = $MarginContainer/InteractButton
@onready var PauseButton = $HBoxContainer2/PauseButton

func _ready():
	Global.connect("dialogue_active", _on_dialogue_active)
	Global.connect("dialogue_ended", _on_dialogue_ended)
	Global.overlay_active.connect(_on_overlay_active)
	Global.overlay_inactive.connect(_on_overlay_inactive)
	Global.interactable_entered.connect(_on_interactable_entered)
	Global.interactable_exited.connect(_on_interactable_exited)
	InteractButton.visible = false
	
func _on_dialogue_active():
	self.visible = false

func _on_dialogue_ended():
	self.visible = true

func _on_overlay_active():
	self.visible = false

func _on_overlay_inactive():
	self.visible = true

func _on_interactable_entered():
	InteractButton.visible = true

func _on_interactable_exited():
	InteractButton.visible = false
