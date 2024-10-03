extends CanvasLayer

@onready var InteractButton = $MarginContainer/InteractButton
@onready var PauseButton = $MarginContainer2/HBoxContainer/PauseButton
@onready var ToDoButton = $MarginContainer2/HBoxContainer/ToDoButton

func _ready():
	Global.connect("dialogue_active", _on_dialogue_active)
	Global.connect("dialogue_ended", _on_dialogue_ended)
	Global.overlay_active.connect(_on_overlay_active)
	Global.overlay_inactive.connect(_on_overlay_inactive)
	Global.interactable_entered.connect(_on_interactable_entered)
	Global.interactable_exited.connect(_on_interactable_exited)
	InteractButton.visible = false

func _process(_delta):
	if Global.chased or Global.is_inside_detection_area:
		InteractButton.visible = false
	if State.current_area == "lobby":
		ToDoButton.visible = false
	else:
		ToDoButton.visible = true

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


func _on_interact_button_pressed():
	Input.action_press("interact")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("interact")
	


func _on_pause_button_pressed():
	Input.action_press("pause")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("pause")


func _on_to_do_button_pressed():
	Input.action_press("open_to_do_list")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("open_to_do_list")
