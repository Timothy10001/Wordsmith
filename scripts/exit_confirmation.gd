extends CanvasLayer




func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	Input.action_press("back_to_pause_menu")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("back_to_pause_menu")
