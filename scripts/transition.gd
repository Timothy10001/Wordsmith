extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Iris.visible = false
	$Fade.visible = false


func iris_transition():
	$Iris.visible = true
	$AnimationPlayer.play("Fade To Black")

func fade_transition():
	$AnimationPlayer.play("Fade In")
	$Fade.visible = true


func _on_animation_player_animation_finished(anim_name):

	match anim_name:
		"Fade To Black":
			$AnimationPlayer.play("Fade From Black")
			Global.transition_finished.emit()
		"Fade From Black":
			$Iris.visible = false
		"Fade In":
			$AnimationPlayer.play("Fade Out")
			Global.transition_finished.emit()
		"Fade Out":
			$Fade.visible = false

