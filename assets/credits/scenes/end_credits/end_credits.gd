@tool
extends Credits

@export_file("*.tscn") var main_menu_scene : String
@onready var init_mouse_filter = mouse_filter

func _end_reached():
	%EndMessagePanel.show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	super._end_reached()

func _on_MenuButton_pressed():
	get_tree().change_scene_to_file(main_menu_scene)
	# If Maaack's Scene Loader is installed, use this instead:
	# SceneLoader.load_scene(main_menu_scene)


func _on_ExitButton_pressed():
	var main_menu = load("res://scenes/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)

func _ready():
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()
	super._ready()

func reset():
	super.reset()
	%EndMessagePanel.hide()
	mouse_filter = init_mouse_filter

func _unhandled_input(event):
	if not enabled: return
	if event.is_action_pressed("ui_cancel"):
		if not %EndMessagePanel.visible:
			_end_reached()
		else:
			get_tree().quit()
