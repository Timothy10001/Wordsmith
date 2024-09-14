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

func add_item(other_item: InventorySlot):
	for slot in items:
		if slot:
			pass
		else:
			items.append(other_item)
			inventory_updated.emit(self)
			break

func remove_item(other_item_name: String):
	for i in items.size():
		#if the slot exists
		if items[i]:
			if items[i].item.name == other_item_name:
				items[i] = null
				inventory_updated.emit(self)

func remove_selected_slot_data(index: int):
	items[index] = null
	inventory_updated.emit(self)

func _on_inventory_slot_selected(index: int):
	inventory_interacted.emit(self, index, "select")

func _on_inventory_item_dropped():
	inventory_interacted.emit(self, 0, "drop")

#returns index
func search_inventory(_item_name: String):
	for i in items.size():
		if items[i]:
			if _item_name == items[i].item.name:
				return i
	return null

