extends Resource
class_name Enemy

@export var name: String
@export var health: int
@export var strength: float
@export var speed: int
@export var armor: int
@export var immortal: bool

#SKILLS ARE NAMES OF SKILL
func enemy_AI(skills, target):
	for skill in skills:
		return skill
		
		"""
		means skill deals damage
		if skill[1]:
			pass
		"""
