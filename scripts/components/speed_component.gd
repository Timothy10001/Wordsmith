extends Node2D
class_name SpeedComponent

var BASE_SPEED: int
var speed: int

func _ready():
	BASE_SPEED = get_parent().CharacterResource.speed
	speed = BASE_SPEED
	speed = clamp(speed, 0, BASE_SPEED)

func speed_up(skill: SkillComponent):
	speed += skill.speed_amount

func slow_down(skill: SkillComponent):
	speed -= skill.speed_amount
