extends Node

var RECIPES = {}

@export var player_inventory: Inv
var player_node: CharacterBody3D

var recipes_header_label: Label
var recipe_buttons: Array[Button] = []
var crafting_ui_container: Control

var wood_item: InvItem
var wood_planks_item: InvItem
var stick_item: InvItem

func _ready():
	player_node = get_parent()
	
	if player_node and player_node.inv:
		player_inventory = player_node.inv
	
	load_item_resources()
	
	setup_recipes()
	
	setup_crafting_ui()
	
	update_recipe_display()

func load_item_resources():
	wood_item = load("res://inventory/items/wood.tres") as InvItem
	
	if ResourceLoader.exists("res://inventory/items/wood_planks.tres"):
		wood_planks_item = load("res://inventory/items/wood_planks.tres") as InvItem
	else:
		print("Warning: wood_planks.tres not found - you need to create this item")
		wood_planks_item = null
	
	if ResourceLoader.exists("res://inventory/items/stick.tres"):
		stick_item = load("res://inventory/items/stick.tres") as InvItem
	else:
		print("Warning: stick.tres not found - you need to create this item")
		stick_item = null

func setup_recipes():
	if wood_item and wood_planks_item:
		RECIPES["Wood Planks"] = {
			"ingredients": {wood_item: 1},
			"result": wood_planks_item,
			"count": 4
		}
	
	if wood_planks_item and stick_item:
		RECIPES["Stick"] = {
			"ingredients": {wood_planks_item: 2},
			"result": stick_item,
			"count": 4
		}

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_C:
			toggle_crafting_ui()

func setup_crafting_ui():
	crafting_ui_container = Control.new()
	crafting_ui_container.name = "CraftingUI"
	crafting_ui_container.visible = false
	
	if player_node.has_node("Inv_UI"):
		player_node.get_node("Inv_UI").add_child(crafting_ui_container)
	else:
		get_tree().current_scene.add_child(crafting_ui_container)
	
	var background = NinePatchRect.new()
	background.position = Vector2(10, 100)
	background.size = Vector2(400, 250)
	background.modulate = Color(0.2, 0.2, 0.2, 0.8)
	crafting_ui_container.add_child(background)
	
	recipes_header_label = Label.new()
	recipes_header_label.text = "Recipes (Press C to close):"
	recipes_header_label.position = Vector2(20, 110)
	recipes_header_label.add_theme_font_size_override("font_size", 18)
	crafting_ui_container.add_child(recipes_header_label)
	
	var y_offset = 140
	var recipe_index = 0
	
	for recipe_name in RECIPES.keys():
		var recipe_button = Button.new()
		recipe_button.text = get_recipe_display_text(recipe_name)
		recipe_button.position = Vector2(20, y_offset + (recipe_index * 35))
		recipe_button.size = Vector2(360, 30)
		recipe_button.pressed.connect(_on_recipe_selected.bind(recipe_name))
		
		crafting_ui_container.add_child(recipe_button)
		recipe_buttons.append(recipe_button)
		
		recipe_index += 1

func get_recipe_display_text(recipe_name: String) -> String:
	var recipe = RECIPES[recipe_name]
	var ingredients_text = ""
	
	for item in recipe.ingredients.keys():
		var count = recipe.ingredients[item]
		if ingredients_text != "":
			ingredients_text += " + "
		ingredients_text += str(count) + " " + item.name
	
	var result_item = recipe.result
	var result_count = recipe.count
	
	return ingredients_text + " -> " + str(result_count) + " " + result_item.name

func toggle_crafting_ui():
	if crafting_ui_container:
		crafting_ui_container.visible = !crafting_ui_container.visible
		if crafting_ui_container.visible:
			update_recipe_display()
			print("Crafting UI opened - Current inventory:")
			debug_inventory()

func update_recipe_display():
	for i in range(recipe_buttons.size()):
		var recipe_name = RECIPES.keys()[i]
		var button = recipe_buttons[i]
		
		if button is Button:
			var can_craft = can_craft_recipe(recipe_name)
			button.disabled = !can_craft
			
			var base_text = get_recipe_display_text(recipe_name)
			if can_craft:
				button.text = "✓ " + base_text
				button.modulate = Color.WHITE
			else:
				button.text = "✗ " + base_text
				button.modulate = Color(0.7, 0.7, 0.7)

func can_craft_recipe(recipe_name: String) -> bool:
	if not player_inventory:
		print("No player inventory found!")
		return false
	
	var recipe = RECIPES[recipe_name]
	var ingredients = recipe.ingredients
	
	for item in ingredients.keys():
		var required_count = ingredients[item]
		var available_count = get_item_count_in_inventory(item)
		
		print("Recipe: " + recipe_name + " - " + item.name + " requires " + str(required_count) + ", have " + str(available_count))
		
		if available_count < required_count:
			return false
	
	return true

func get_item_count_in_inventory(target_item: InvItem) -> int:
	if not player_inventory:
		return 0
	
	var total_count = 0
	
	for slot in player_inventory.slots:
		if slot.item == target_item: 
			total_count += slot.amount
	
	return total_count

func _on_recipe_selected(recipe_name: String):
	print("Recipe selected: " + recipe_name)
	if can_craft_recipe(recipe_name):
		craft_recipe(recipe_name)
	else:
		print("Cannot craft " + recipe_name + " - insufficient materials")

func craft_recipe(recipe_name: String):
	if not can_craft_recipe(recipe_name):
		print("Cannot craft " + recipe_name + " - insufficient materials")
		return
	
	var recipe = RECIPES[recipe_name]
	
	for item in recipe.ingredients.keys():
		var required_count = recipe.ingredients[item]
		remove_items_from_inventory(item, required_count)
	
	var result_item = recipe.result
	for i in range(recipe.count):
		player_inventory.insert(result_item)
	
	update_recipe_display()
	
	print("Successfully crafted " + str(recipe.count) + " " + result_item.name)

func remove_items_from_inventory(target_item: InvItem, count: int):
	var remaining_to_remove = count
	
	for slot in player_inventory.slots:
		if remaining_to_remove <= 0:
			break
			
		if slot.item == target_item: 
			var remove_from_slot = min(slot.amount, remaining_to_remove)
			slot.amount -= remove_from_slot
			remaining_to_remove -= remove_from_slot
			
			if slot.amount <= 0:
				slot.item = null
				slot.amount = 0
	
	player_inventory.update.emit()

func debug_inventory():
	if not player_inventory:
		print("No inventory!")
		return
		
	print("=== INVENTORY DEBUG ===")
	for i in range(player_inventory.slots.size()):
		var slot = player_inventory.slots[i]
		if slot.item:
			print("Slot " + str(i) + ": " + slot.item.name + " x" + str(slot.amount))
		else:
			print("Slot " + str(i) + ": Empty")
	print("=== LOADED ITEMS ===")
	print("Wood item: " + (wood_item.name if wood_item else "NULL"))
	print("Wood planks item: " + (wood_planks_item.name if wood_planks_item else "NULL"))
	print("Stick item: " + (stick_item.name if stick_item else "NULL"))
	print("=====================")
