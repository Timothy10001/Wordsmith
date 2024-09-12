extends Resource

class_name InventorySlot

const MAX_STACK_SIZE: int = 64

@export var item: Item
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1

func set_quantity(value: int):
	quantity = value
	if quantity > 1 and not item.stackable:
		quantity = 1
		push_error("item is not stackable")
