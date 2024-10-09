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

func enemy_AI(_skills, user, target):
	var chosen_skill = ""
	for _skill in user.skill_component.skills:
		#checks if the enemy's health is 30% less than max health and if the enemy has a healing skill
		if user["health"] <= (user["max_health"] * 0.3) and !_skill.deals_damage:
			#the enemy heals depending on the chance of healing on the skill
			randomize()
			var heal_chance = randi_range(1, 100)
			if heal_chance <= _skill.chance:
				chosen_skill = _skill.name
				continue
			else:
				continue
		#checks if enemy has debuff skills and if player does not have debuffs
		elif _skill.status_effect == "stun" and target.current_stun_duration == 0:
			#the enemy does a debuff skill depending on the chance of debuff on the skill
			randomize()
			var stun_chance = randi_range(1, 100)
			if stun_chance <= _skill.chance:
				chosen_skill = _skill.name
				continue
			else:
				continue
		elif _skill.deals_damage:
			chosen_skill = _skill.name
			continue
	return chosen_skill

