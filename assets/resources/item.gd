extends Resource

class_name Item

@export var name: String
@export var description: String
@export var texture: Texture2D
@export var stackable: bool = false
@export var droppable: bool = false
@export_enum("consumable", "accessory") var type: String
@export_enum("player", "enemy") var target: String

@export var heal_value: int = 0
@export var mana_value: int = 0
@export var stun_duration: int = 0
@export var miss_duration: int = 0
@export var damage_duration: int = 0
@export var damage: int = 0

func use_item(_target):
	if type != "accessory":
		if heal_value != 0:
			_target.health_component.item_heal(self)
		if mana_value != 0:
			_target.mana_component.item_mana(self)
		if stun_duration != 0:
			_target.current_stun_duration = stun_duration
		if miss_duration != 0:
			_target.current_miss_duration = miss_duration
		if damage_duration != 0:
			_target.current_damage_duration = damage_duration
		if damage != 0:
			_target.health_component.item_damage(self)

