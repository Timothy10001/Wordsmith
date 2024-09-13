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

func remove_selected_slot_data(index: int):
	items[index] = null

func _on_inventory_slot_selected(index: int):
	inventory_interacted.emit(self, index, "select")

