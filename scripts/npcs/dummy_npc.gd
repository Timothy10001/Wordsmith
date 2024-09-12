extends CharacterBody2D

func _on_npc_player_entered():
	$Sprite2D/MarginContainer.visible = true

func _on_npc_player_left():
	$Sprite2D/MarginContainer.visible = false
