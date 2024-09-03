extends Node2D
class_name ManaComponent

var MAX_MANA : int 
var mana: int

func _ready():
	MAX_MANA = get_parent().CharacterResource.mana
	mana = MAX_MANA
	mana = clamp(mana, 0, MAX_MANA)

func add_mana(skill: SkillComponent):
	
	mana += skill.mana_amount
	if mana > MAX_MANA:
		mana = MAX_MANA

func remove_mana(skill: SkillComponent):
	mana -= skill.mana_cost
	if mana <= 0:
		mana = 0
