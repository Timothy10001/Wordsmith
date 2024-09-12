extends PanelContainer

@onready var ItemIcon: TextureRect = $MarginContainer/HBoxContainer2/ItemIcon
@onready var ItemName: Label = $MarginContainer/HBoxContainer2/ItemName
@onready var ItemCount: Label = $MarginContainer/HBoxContainer/ItemCount



func set_inventory_slot_data(item: Item, quantity: int):
	ItemIcon.texture = item.texture
	ItemName.text = item.name
	ItemCount.text = "x " + str(quantity)
