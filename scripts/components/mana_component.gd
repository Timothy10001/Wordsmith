extends Node2D
class_name ManaComponent

signal mana_changed(int)

var DamageIndicator: Node2D
var MAX_MANA : int 
var mana: int

func _ready():
	MAX_MANA = get_parent().CharacterResource.max_mana
	mana = MAX_MANA
	mana = clamp(mana, 0, MAX_MANA)
	DamageIndicator = get_parent().get_node("DamageIndicator")

func add_mana(skill: SkillComponent):
	mana += skill.mana_amount
	if mana > MAX_MANA:
		mana = MAX_MANA
	mana_changed.emit(skill.mana_amount)
	DamageIndicator.display_damage_number(skill.mana_amount, "mana")

func remove_mana(skill: SkillComponent):
	mana -= skill.mana_cost
	if mana <= 0:
		mana = 0
	mana_changed.emit(skill.mana_amount)
	DamageIndicator.display_damage_number(skill.mana_amount, "mana")

func item_mana(item: Item):
	mana += item.mana_value
	if mana > MAX_MANA:
		mana = MAX_MANA
	mana_changed.emit(item.mana_value)
	DamageIndicator.display_damage_number(item.mana_value, "mana")
