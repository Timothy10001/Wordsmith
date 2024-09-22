extends Node2D
@onready var animation_player = $AnimationPlayer

func display_damage_number(value: int, type: String):
	match type:
		"damage":
			$LabelContainer/Label.add_theme_color_override("font_color", Color("ffffff"))
			if value == 0:
				$LabelContainer/Label.text = "MISS!"
			else:
				$LabelContainer/Label.text = "-" + str(value)
		"heal":
			$LabelContainer/Label.add_theme_color_override("font_color", Color("83e04c"))
			$LabelContainer/Label.text = "+" + str(value)
		"mana":
			$LabelContainer/Label.add_theme_color_override("font_color", Color("3898ff"))
			$LabelContainer/Label.text = "+" + str(value)
	
	animation_player.play("Rise and Fade")

