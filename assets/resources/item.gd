extends Resource

class_name Item

@export var name: String
@export var description: String
@export var texture: Texture2D
@export_enum("stats_upgrade", "heal", "status_effect", "accessory") var type: String
