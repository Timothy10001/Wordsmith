extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Fade Out")
	
	$SkipButton.visible = false
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(20.0).timeout
	$SkipButton.visible = true



func _on_skip_button_pressed():
	get_tree().change_scene_to_packed(load("res://scenes/main_menu.tscn"))
