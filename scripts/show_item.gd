extends CanvasLayer

@onready var texture_rect = $TextureRect
@onready var animation_player = $AnimationPlayer

func _ready():
	await get_tree().create_timer(0.1).timeout
	animation_player.play("Show Item")
	#print(texture_rect.texture)



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Show Item":
		queue_free()
