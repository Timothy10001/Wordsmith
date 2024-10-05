extends Control



func _on_skip_button_pressed():
	queue_free()



func _on_tree_exiting():
	Global.tutorial_closed.emit()
