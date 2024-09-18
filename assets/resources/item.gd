extends Resource

class_name Item

@export var name: String
@export var description: String
@export var texture: Texture2D
@export var stackable: bool = false
@export var droppable: bool = false
@export_enum("consumable", "accessory") var type: String
@export_enum("player", "enemy") var target: String

func use_item():
	pass

