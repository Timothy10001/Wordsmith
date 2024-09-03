extends Node2D
@onready var animation_player = $AnimationPlayer

func display_damage_number(value: int, is_heal: bool = false):
	if value == 0:
		$LabelContainer/Label.text = "MISS!"
	else:
		$LabelContainer/Label.text = "-" + str(value)
	if is_heal:
		$LabelContainer/Label.text = "+" + str(value)
		$LabelContainer/Label.add_theme_color_override("font_color", Color("83e04c"))
	animation_player.play("Rise and Fade")

