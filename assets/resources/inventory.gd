extends Resource

class_name Inventory

signal inventory_updated(inventory: Inventory)
signal inventory_interacted(inventory: Inventory, index: int)

@export var items: Array[InventorySlot]

func selected_slot_data(index: int):
	var item = items[index]
	#returns the selected slot's item data
	if item:
		return item
	else:
		return null

func add_item(_item: Item):
	pass

func remove_selected_slot_data(index: int):
	items[index] = null
	inventory_updated.emit(self)

func _on_inventory_slot_selected(index: int):
	inventory_interacted.emit(self, index, "select")

func _on_inventory_item_dropped():
	inventory_interacted.emit(self, 0, "drop")

#returns index
func search_inventory(_item: Item):
	for i in items.size():
		if items[i] == _item:
			return i
		else:
			return null
