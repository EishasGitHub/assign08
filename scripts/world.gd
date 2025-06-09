extends Node3D

@onready var player = $Player 
@onready var gridmap = $GridMap  
@onready var inventory = $Player/Inv_UI

func _ready():
	player.set_gridmap_reference(gridmap)
	
	inventory.set_player_reference(player)
	
	setup_block_items()
	
	connect_player_to_ui()

func setup_block_items():
	var block_items_array: Array[InvItem] = []
	
	block_items_array.append(preload("res://inventory/items/bricks_grey.tres"))   
	block_items_array.append(preload("res://inventory/items/diamond.tres"))     
	block_items_array.append(preload("res://inventory/items/dirt.tres"))    
	block_items_array.append(preload("res://inventory/items/grass.tres"))    
	block_items_array.append(preload("res://inventory/items/leaves.tres"))      
	block_items_array.append(preload("res://inventory/items/snow.tres"))   
	block_items_array.append(preload("res://inventory/items/stone.tres"))     
	block_items_array.append(preload("res://inventory/items/wood.tres"))      
	block_items_array.append(preload("res://inventory/items/wood_planks.tres"))     
	
	gridmap.block_items = block_items_array

func connect_player_to_ui():
	player.slot_changed.connect(inventory.set_selected_slot)
