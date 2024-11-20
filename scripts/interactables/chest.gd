extends Area2D


@export var collision: CollisionShape2D
@export var dialogue_resource: DialogueResource
@export var inventory: Inventory
@export var opened_texture: Sprite2D
@export var closed_texture: Sprite2D
@export var has_AI: bool = false

var player_inventory: Inventory = load("res://assets/resources/player_inventory.tres")

var is_empty: bool = false
var entered: bool = false
var player

func _ready():
	if State.world_inventory:
		if State.world_inventory.has(self.get_path()):
			inventory.items = State.world_inventory[self.get_path()]
			is_empty = true
	
	if closed_texture and opened_texture:
		closed_texture.visible = true
		opened_texture.visible = false

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


func _process(_delta):
	if inventory.items:
		for slot in inventory.items:
			if slot:
				pass
			else:
				if closed_texture and opened_texture:
					closed_texture.visible = false
					opened_texture.visible = true
	if entered:
		if Input.is_action_just_pressed("interact"):
			if closed_texture and opened_texture:
				closed_texture.visible = false
				opened_texture.visible = true
			if !is_empty and has_AI:
				add_chest_items()
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
								Global.show_item.emit(slot.item.texture)
								await Global.dialogue_ended
								
								player_inventory.items[item_index].fully_merge_with(slot)
								player_inventory.inventory_updated.emit(player_inventory)
								inventory.remove_item(slot.item.name)
							else:
								#the chest item is added onto another slot if it cannot fully merge
								set_interactable_dialogue(slot, "item_picked_up")
								Global.show_item.emit(slot.item.texture)
								await Global.dialogue_ended
								
								player_inventory.add_item(slot)
								inventory.remove_item(slot.item.name)
						else:
							#the chest item is added onto another slot if it's a new item
							set_interactable_dialogue(slot, "item_picked_up")
							Global.show_item.emit(slot.item.texture)
							await Global.dialogue_ended
							
							player_inventory.add_item(slot)
							inventory.remove_item(slot.item.name)
					else:
						break
			else:
				Global.start_interactable_dialogue.emit(dialogue_resource, "no_items")
				State.world_inventory[self.get_path()] = inventory.items
				#print(State.world_inventory)
				return
			Global.start_interactable_dialogue.emit(dialogue_resource, "no_more_items")
			State.world_inventory[self.get_path()] = inventory.items
			#print(State.world_inventory)


func set_interactable_dialogue(slot: InventorySlot, title: String):
	Global.item_name = slot.item.name
	Global.item_quantity = slot.quantity
	Global.start_interactable_dialogue.emit(dialogue_resource, title)
	

var item_path_list = ["res://assets/resources/items/apple.tres", "res://assets/resources/items/bread.tres", "res://assets/resources/items/water_bottle.tres", "res://assets/resources/items/strawberry.tres", "res://assets/resources/items/teaching_stick.tres", "res://assets/resources/items/cheese_juice.tres"]

func add_chest_items():
	add_chest_slots()
	add_items_to_slots()
	
	if inventory.items.size() > 1:
		if inventory.has_item(inventory.items[0].item.name):
			if inventory.items[0].can_fully_merge_with(inventory.items[1]):
				inventory.items[0].fully_merge_with(inventory.items[1])
				inventory.inventory_updated.emit(inventory)


func add_items_to_slots():
	if inventory.items:
		for slot in inventory.items:
			if slot:
				if slot.item == null:
					slot.item = item_AI()
					randomize()
					slot.set_quantity(randi_range(1, 5))
					print(str(slot.item.name) + ": " + str(slot.quantity))

func add_chest_slots():
	randomize()
	var slot_count = 2
	for i in range(slot_count):
		inventory.items.append(InventorySlot.new())

var item_list: Array[Item] = []

func item_AI():
	
	item_list.clear()
	
	for item_path in item_path_list:
		item_list.append(load(item_path))
	if player is Player:
		var player_health_percentage = float(player.CharacterResource.health) / float(player.CharacterResource.max_health) * 100
		var player_mana_percentage = float(player.CharacterResource.mana) / float(player.CharacterResource.max_mana) * 100
		#checks if player's health is not 100% to give healing items
		if player_health_percentage != 100:
			#checks if player's health is below 30% to give bread which gives big health boost
			if player_health_percentage <= 30:
				
				return search_item_list("bread")
			
			return get_healing_item()
		
		elif player_mana_percentage != 100:
			
			if player_mana_percentage <= 30:
				return search_item_list("water bottle")
			
			return get_mana_item()
		
		else:
			return search_item_list("teaching stick")

func search_item_list(item_name: String):
	for item in item_list:
		if item.name.to_lower() == item_name:
			return item
		else:
			continue
	return null

func get_healing_item():
	var healing_item_list: Array[Item] = []
	healing_item_list.clear()
	for item in item_list:
		if item.heal_value > 0:
			healing_item_list.append(item)
	return healing_item_list.pick_random()

func get_mana_item():
	var mana_item_list: Array[Item] = []
	mana_item_list.clear()
	for item in item_list:
		if item.mana_value > 0:
			mana_item_list.append(item)
	return mana_item_list.pick_random()
