extends Resource
class_name Enemy

@export var name: String
@export var health: int
@export var strength: float
@export var speed: int
@export var armor: int
@export var immortal: bool

#SKILLS ARE NAMES OF SKILL
func enemy_AI(skills, user, target):
	for skill in skills:
		for _skill in user.skill_component.skills:
			if _skill.status_effect == "stun" and target.current_stun_duration == 0:
				var stun_chance = randi_range(0, 100)
				if stun_chance <= _skill.stun_chance:
					return _skill.name
		return skill
