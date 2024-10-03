extends CanvasLayer


@onready var ToDoList = $VBoxContainer/ToDoList
var to_do_array: Array[String]

func _ready():
	set_to_do_list()
	Global.add_to_do.connect(add_to_do)
	Global.remove_to_do.connect(remove_to_do)
	Global.clear_to_do.connect(clear_to_do)

func set_to_do_list():
	ToDoList.text = ""
	for item in to_do_array:
		ToDoList.text += item

func add_to_do(to_do: String):
	if to_do not in ToDoList.text:
		if to_do_array.size() >= 1:
			to_do = "\n %s" % to_do
		to_do_array.append(to_do)
		set_to_do_list()
	else:
		return

func remove_to_do(to_do: String):
	for i in range(to_do_array.size()):
		if to_do in to_do_array[i]:
			to_do_array.remove_at(i)
			break
		return
	set_to_do_list()

func clear_to_do():
	to_do_array.clear()
	set_to_do_list()


func _on_back_button_pressed():
	Input.action_press("close_to_do_list")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("close_to_do_list")
