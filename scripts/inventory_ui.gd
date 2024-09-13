extends Control
#UI FOR INVENTORY WHETHER PLAYER OR INTERACTABLE

signal inventory_item_dropped(index: int)

const inventory_slot_scene: PackedScene = preload("res://scenes/inventory_slot.tscn")

@onready var ItemIcon: TextureRect = $MarginContainer/HBoxContainer/PanelContainer2/VBoxContainer/ItemIcon
@onready var ItemDescription: Label = $MarginContainer/HBoxContainer/PanelContainer2/VBoxContainer/ItemDescription

@onready var UseButton: Button = $MarginContainer/HBoxContainer/PanelContainer2/VBoxContainer/UseButton
@onready var DropButton: Button = $MarginContainer/HBoxContainer/PanelContainer2/VBoxContainer/DropButton

@onready var ItemGrid: GridContainer = $MarginContainer/HBoxContainer/PanelContainer/ScrollContainer/ItemGrid
var inventory_data: Inventory
var inventory_slots: Array[PanelContainer]

func _ready():
	populate_item_grid(inventory_data)
	UseButton.visible = false
	DropButton.visible = false

func set_inventory_data(_inventory_data: Inventory):
	#sets inventory data from either player or interactable
	inventory_data = _inventory_data
	inventory_data.connect("inventory_updated", populate_item_grid)

func populate_item_grid(inventory: Inventory) -> void:
	#remove current children so that it will be automatically updated
	for child in ItemGrid.get_children():
		ItemGrid.remove_child(child)
		inventory_slots.clear()
		
	for inventory_slot in inventory.items:
		#add all inventory slots
		var inventory_slot_instance = inventory_slot_scene.instantiate()
		ItemGrid.add_child(inventory_slot_instance)
		inventory_slot_instance.visible = false
		inventory_slot_instance.connect("inventory_slot_selected", inventory._on_inventory_slot_selected)
		inventory_slots.append(inventory_slot_instance)
		if inventory_slot != null:
			#if inventory slot isn't null, add slot
			inventory_slot_instance.visible = true
			#adds slot's data
			inventory_slot_instance.set_inventory_slot_data(inventory_slot.item, inventory_slot.quantity)

func get_inventory_slots():
	return inventory_slots

func set_item_details(item: Item):
	if item:
		ItemIcon.texture = item.texture
		ItemDescription.text = item.description
		if item.droppable:
			DropButton.visible = true
		else:
			DropButton.visible = false
		if item.type != "accessory":
			UseButton.visible = true
		else:
			UseButton.visible = false
	else:
		DropButton.visible = false
		UseButton.visible = false
		ItemIcon.texture = null
		ItemDescription.text = ""

func _on_back_button_pressed():
	Input.action_press("back_to_pause_menu")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("back_to_pause_menu")


