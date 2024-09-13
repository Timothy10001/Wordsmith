extends PanelContainer

signal inventory_slot_selected(index: int)

@onready var ItemIcon: TextureRect = $MarginContainer/HBoxContainer2/ItemIcon
@onready var ItemName: Label = $MarginContainer/HBoxContainer2/ItemName
@onready var ItemCount: Label = $MarginContainer/HBoxContainer/ItemCount

var selected: bool = false

func _process(delta):
	if selected:
		self.theme_type_variation = "ItemSelected"
	else:
		self.theme_type_variation = "Item"

func set_inventory_slot_data(item: Item, quantity: int):
	ItemIcon.texture = item.texture
	ItemName.text = item.name
	ItemCount.text = "x " + str(quantity)


func _on_gui_input(event):
	var rect = $MarginContainer.get_rect()
	if event is InputEventScreenTouch:
		if event.pressed and rect.has_point(event.position):
			inventory_slot_selected.emit(get_index())
