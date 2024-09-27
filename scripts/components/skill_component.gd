extends Node2D
class_name SkillComponent

@export var health_component: HealthComponent
@export var skills: Array[Skill]
@export var user: Resource


var miss_chance: int = 0
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
	var armor = float(target["resource"].armor)
	var strength_modifier = float(skill.attack_damage * (1 + (sqrt(strength) / 10)))
	var armor_modifier = 1 - (armor / 100)
	damage = round(strength_modifier * armor_modifier)


func calculate_heal(_skill, _user):
	heal_amount = _skill.heal_amount
	Global.play_sfx.emit("heal")
	Global.skill_description = _skill.description

func calculate_skill_damage(skill, target):
	var strength = user.strength
	var armor = float(target["resource"].armor)
	var armor_modifier = 1 - (armor / 100)
	var strength_modifier
	var missed
	if Global.skill_check_passed:
		strength_modifier = float(skill.attack_damage * (1 + (sqrt(strength) / 3)))
		Global.skill_description = skill.description
	elif !Global.skill_check_passed:
		missed = calculate_miss_chance(80)
		if !missed:
			strength_modifier = float(skill.attack_damage * (1 + (sqrt(strength) / 12)))
			Global.skill_description = skill.description
		else:
			strength_modifier = 0
			Global.skill_description = target["name"] + " could not understand!"
	missed = calculate_miss_chance(miss_chance)
	if !missed:
		damage = round(strength_modifier * armor_modifier)
	else:
		damage = 0

#skill_component of USER
func use_skill(_name: String, target, skill_component: SkillComponent, target_instance, _user):
	for skill in skills:
		if skill.name == _name:
			mana_amount = skill.mana_amount
			mana_cost = skill.mana_cost
			
			if skill.name == "Guard":
				_user["resource"].armor *= 3
				_user["mana_component"].add_mana(skill_component)
				Global.skill_description = skill.description
			
			if _user.has("mana"):
				_user["mana_component"].add_mana(skill_component)
				_user["mana_component"].remove_mana(skill_component)
			
			if skill.deals_damage:
				
				if skill.requires_skill_check:
					calculate_skill_damage(skill, target)
				elif skill.status_effect == "none":
					calculate_damage(skill, target)
				
				if skill.status_effect == "stun":
					target["instance"].current_stun_duration += skill.stun_duration
					target["health_component"].damage(skill_component, target_instance)
				
				if skill.status_effect == "none":
					target["health_component"].damage(skill_component, target_instance)
					
				if !skill.requires_skill_check:
					Global.skill_description = skill.description
				
				if _user["type"] != "Player":
					Global.skill_description = skill.description
				
			elif skill.name != "Guard":
				calculate_heal(skill, _user)
				_user["health_component"].heal(skill_component)
			else:
				pass
		else:
			pass

func calculate_miss_chance(_miss_chance: int):
	var rng = RandomNumberGenerator.new()
	var random_number = rng.randi_range(0, 100)
	if random_number <= _miss_chance:
		return true
	else:
		return false


