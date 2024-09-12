extends CanvasLayer

const inventory_slot_scene: PackedScene = preload("res://scenes/inventory_slot.tscn")

@onready var ItemGrid: GridContainer = $UI/MarginContainer/PanelContainer/ItemGrid

func _ready():
	var inventory_data = preload("res://assets/resources/player_inventory.tres")
	populate_item_grid(inventory_data.items)

func populate_item_grid(inventory_slots: Array[InventorySlot]) -> void:
	for child in ItemGrid.get_children():
		ItemGrid.remove_child(child)
	
	for inventory_slot in inventory_slots:
		var inventory_slot_instance = inventory_slot_scene.instantiate()
		ItemGrid.add_child(inventory_slot_instance)
		inventory_slot_instance.visible = false
		if inventory_slot != null:
			inventory_slot_instance.visible = true
			inventory_slot_instance.set_inventory_slot_data(inventory_slot.item, inventory_slot.quantity)


func _on_back_button_pressed():
	Input.action_press("back_to_pause_menu")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("back_to_pause_menu")
