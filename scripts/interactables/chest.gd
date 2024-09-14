extends Area2D


@export var collision: CollisionShape2D
@export var dialogue_resource: DialogueResource
@export var inventory: Inventory
var player_inventory: Inventory = load("res://assets/resources/player_inventory.tres")

var entered: bool = false
var player

func _on_body_entered(body):
	if body is Player:
		Global.interactable_entered.emit()
		entered = true
		player = body


func _on_body_exited(body):
	if body is Player:
		entered = false
		player = body
		Global.interactable_exited.emit()


func _process(delta):
	if entered:
		if Input.is_action_just_pressed("interact"):
			if inventory.items:
				for slot in inventory.items:
					#if a slot in the chest exists
					if slot:
						#if the player has the same item as the chest
						if player_inventory.search_inventory(slot.item.name):
							var item_index = player_inventory.search_inventory(slot.item.name)
							#if the chest item can fully merge with the player's item
							if player_inventory.items[item_index].can_fully_merge_with(slot):
								
								set_interactable_dialogue(slot, "item_picked_up")
								await Global.dialogue_ended
								
								player_inventory.items[item_index].fully_merge_with(slot)
								inventory.remove_item(slot.item.name)
							else:
								#the chest item is added onto another slot if it cannot fully merge
								set_interactable_dialogue(slot, "item_picked_up")
								await Global.dialogue_ended
								
								player_inventory.add_item(slot)
								inventory.remove_item(slot.item.name)
						else:
							#the chest item is added onto another slot if it's a new item
							print(slot.quantity)
							set_interactable_dialogue(slot, "item_picked_up")
							await Global.dialogue_ended
							
							player_inventory.add_item(slot)
							inventory.remove_item(slot.item.name)
					else:
						break
			Global.start_interactable_dialogue.emit(dialogue_resource, "no_more_items")


func set_interactable_dialogue(slot: InventorySlot, title: String):
	Global.item_name = slot.item.name
	Global.item_quantity = slot.quantity
	Global.start_interactable_dialogue.emit(dialogue_resource, title)
	
