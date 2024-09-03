extends CanvasLayer


func _ready():
	Global.connect("dialogue_active", _on_dialogue_active)
	Global.connect("dialogue_ended", _on_dialogue_ended)
	Global.overlay_active.connect(_on_overlay_active)
	Global.overlay_inactive.connect(_on_overlay_inactive)
	
func _on_dialogue_active():
	self.visible = false

func _on_dialogue_ended():
	self.visible = true

func _on_overlay_active():
	self.visible = false

func _on_overlay_inactive():
	self.visible = true
