extends Resource
class_name Enemy

@export var name: String
@export var health: int
@export var strength: float
@export var speed: int
@export var initial_armor: int
@export var armor: int
@export var immortal: bool
@export var experience: int
@export var inventory: Inventory

func enemy_AI(skills, user, target):
	#checks all enemy skills
	for skill in skills:
		for _skill in user.skill_component.skills:
			#checks if the enemy's health is 30% less than max health and if the enemy has a healing skill
			if user["health"] <= (user["max_health"] * 0.3) and !_skill.deals_damage:
				#the enemy heals depending on the chance of healing on the skill
				randomize()
				var heal_chance = randi_range(0, 100)
				if heal_chance <= _skill.chance:
					return _skill.name
			#checks if enemy has debuff skills and if player does not have debuffs
			if _skill.status_effect == "stun" and target.current_stun_duration == 0:
				#the enemy does a debuff skill depending on the chance of debuff on the skill
				randomize()
				var stun_chance = randi_range(0, 100)
				if stun_chance <= _skill.chance:
					return _skill.name
		return skill
