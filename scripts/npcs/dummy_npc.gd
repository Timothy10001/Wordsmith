extends CharacterBody2D

func _on_npc_player_entered():
	$Sprite2D/HBoxContainer.visible = true

func _on_npc_player_left():
	$Sprite2D/HBoxContainer.visible = false
