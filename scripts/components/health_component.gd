extends Node2D
class_name HealthComponent

signal health_changed(int)
 
var DamageIndicator: Node2D
var immortal: bool
var MAX_HEALTH: int
var health : int


func _ready():
	if get_parent().CharacterResource.name == "Wordsmith":
		MAX_HEALTH = get_parent().CharacterResource.max_health
		health = get_parent().CharacterResource.health
	else:
		MAX_HEALTH = get_parent().CharacterResource.health
		health = MAX_HEALTH
	health = clamp(health, 0, MAX_HEALTH)
	immortal = get_parent().CharacterResource.immortal
	DamageIndicator = get_parent().get_node("DamageIndicator")

func damage(skill: SkillComponent, instance):
	if !immortal:
		health -= skill.damage
		health_changed.emit(skill.damage)
		DamageIndicator.display_damage_number(skill.damage, false)
	
	#free parent when health goes to zero
	if health <= 0:
		health = 0
		Global.unit_is_dead.emit(instance)
		#play fade animation
		var tween = get_tree().create_tween()
		tween.tween_property(get_parent(), "modulate", Color("fff", 0.0), 1)
		await tween.finished
		#remove unit from battle scene
		get_parent().queue_free()


func heal(skill: SkillComponent):
	#add signal for changed health
	health += skill.heal_amount
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	health_changed.emit(skill.heal_amount)
	DamageIndicator.display_damage_number(skill.heal_amount, true)
	if get_parent().CharacterResource.name == "Wordsmith":
		get_parent().CharacterResource.health = health

func item_heal(item: Item):
	health += item.heal_value
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	health_changed.emit(item.heal_value)
	DamageIndicator.display_damage_number(item.heal_value, true)
	if get_parent().CharacterResource.name == "Wordsmith":
		get_parent().CharacterResource.health = health

func item_damage(item: Item):
	health -= item.damage
	health_changed.emit(item.damage)
	DamageIndicator.display_damage_number(item.damage, false)
	DamageIndicator.display_damage_number(item.damage, false)
	if get_parent().CharacterResource.name == "Wordsmith":
		get_parent().CharacterResource.health = health

