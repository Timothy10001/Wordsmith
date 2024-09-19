extends Node2D
class_name SkillComponent

@export var health_component: HealthComponent
@export var status_effect_component: StatusEffectComponent
@export var skills: Array[Skill]
@export var user: Resource

var skill_list = []
var damage: int
var heal_amount: int
var mana_amount: int
var mana_cost: int

func _ready():
	for skill in skills:
		skill_list.push_back(skill.name)

func calculate_damage(skill, target):
	var strength = user.strength
	var armor = target["resource"].armor
	var strength_modifier = skill.attack_damage * (1 + (sqrt(strength) / 10))
	var armor_modifier = 1 - (armor / 100)
	damage = strength_modifier * armor_modifier


func calculate_heal(skill):
	print("Heal deez")

func calculate_skill_damage(skill, target):
	var strength = user.strength
	var armor = target["resource"].armor
	var armor_modifier = 1 - (armor / 100)
	var strength_modifier
	var rng = RandomNumberGenerator.new()
	if Global.skill_check_passed:
		strength_modifier = skill.attack_damage * (1 + (sqrt(strength) / 3))
		Global.skill_description = skill.description
	elif !Global.skill_check_passed:
		var miss_chance = rng.randi_range(1, 5)
		if miss_chance == 4:
			strength_modifier = skill.attack_damage * (1 + (sqrt(strength) / 12))
			Global.skill_description = skill.description
		else:
			strength_modifier = 0
			Global.skill_description = target["name"] + " could not understand!"
	damage = strength_modifier * armor_modifier

#skill_component of USER
func use_skill(_name: String, target, skill_component: SkillComponent, target_instance, _user):
	for skill in skills:
		if skill.name == _name:
			mana_amount = skill.mana_amount
			mana_cost = skill.mana_cost
			
			if _user.has("mana"):
				_user["mana_component"].add_mana(skill_component)
				_user["mana_component"].remove_mana(skill_component)
			
			if skill.deals_damage:
				
				if skill.requires_skill_check:
					calculate_skill_damage(skill, target)
				else:
					calculate_damage(skill, target)
				
				target["health_component"].damage(skill_component, target_instance)
				
				if !skill.requires_skill_check:
					Global.skill_description = skill.description
				
				if _user["type"] != "Player":
					Global.skill_description = skill.description
				
			else:
				calculate_heal(skill)
		else:
			print("No such skill")
