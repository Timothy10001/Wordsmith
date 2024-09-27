extends Control

var player_inventory = load("res://scenes/inventory_ui.tscn")
var player_inventory_resource = load("res://assets/resources/player_inventory.tres")
var player = load("res://scenes/player.tscn")
var player_instance

var dialogue_resource: DialogueResource = load("res://assets/resources/dialogues/interactables/inventory_confirmation.dialogue")

var selected_inventory_slot: InventorySlot
var selected_inventory_slot_index: int
var player_inventory_instance


func _ready():
	show_player_inventory()

func show_player_inventory():
	#shows only the player inventory
	player_instance = player.instantiate()
	add_child(player_instance)
	player_instance.visible = false
	player_inventory_instance = player_inventory.instantiate()
	player_inventory_instance.set_inventory_data(player_inventory_resource)
	add_child(player_inventory_instance)
	player_inventory_instance.DropButton.connect("pressed", player_inventory_instance.inventory_data._on_inventory_item_dropped)
	player_inventory_instance.UseButton.connect("pressed", player_inventory_instance.inventory_data._on_inventory_item_used)
	player_inventory_instance.inventory_data.connect("inventory_interacted", _on_inventory_interacted)


func _on_inventory_interacted(inventory: Inventory, index: int, type: String):
	match type:
		"select":
			Global.play_sfx.emit("button_click")
			#set selected slot data
			selected_inventory_slot = inventory.selected_slot_data(index)
			selected_inventory_slot_index = index
			#highlight selected slot
			update_selected_slot()
		"drop":
			inventory.remove_selected_slot_data(selected_inventory_slot_index)
			selected_inventory_slot = null
			update_selected_slot()
		"use":
			inventory.use_item(selected_inventory_slot_index, player_instance)
			update_selected_slot()
		_:
			pass


func update_selected_slot():
	#highlights selected slot
	var inventory_slots = player_inventory_instance.get_inventory_slots()
	for i in inventory_slots.size():
		if i == selected_inventory_slot_index:
			inventory_slots[i].selected = true
			if selected_inventory_slot != null:
				player_inventory_instance.set_item_details(selected_inventory_slot.item)
			else:
				player_inventory_instance.set_item_details(null)
		else:
			inventory_slots[i].selected = false

