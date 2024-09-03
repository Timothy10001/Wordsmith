extends Node2D
class_name HealthComponent

signal health_changed(int)
signal status_effect_applied(StatusEffectComponent)
signal status_effect_removed(StatusEffectComponent)
 
var DamageIndicator: Node2D
var immortal: bool
var MAX_HEALTH: int
var health : int


func _ready():
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


func apply_status_effect(status_effect: StatusEffectComponent):
	pass

func remove_status_effect(status_effect: StatusEffectComponent):
	pass


