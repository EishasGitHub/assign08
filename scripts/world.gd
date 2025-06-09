extends Node3D

# Adjust these node paths to match your scene structure
@onready var player = $Player  # Path to your player node
@onready var gridmap = $GridMap  # Path to your gridmap node
@onready var inventory = $Player/Inv_UI

func _ready():
	# Connect player to gridmap for block collection
	player.set_gridmap_reference(gridmap)
	
	# Connect inventory UI to player
	inventory.set_player_reference(player)
	
	# Set up the block items array
	setup_block_items()
	
	# Connect player slot selection to UI
	connect_player_to_ui()

func setup_block_items():
	# Create array of your 10 block items
	var block_items_array: Array[InvItem] = []
	
	# IMPORTANT: Replace these paths with the actual paths to your .tres files
	# The index in this array should match the index in your GridMap's MeshLibrary
	block_items_array.append(preload("res://inventory/items/bricks_grey.tres"))      # Index 0 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/diamond.tres"))     # Index 1 in MeshLibrary  
	block_items_array.append(preload("res://inventory/items/dirt.tres"))      # Index 2 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/grass.tres"))     # Index 3 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/leaves.tres"))      # Index 4 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/snow.tres"))    # Index 5 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/stone.tres"))     # Index 6 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/wood.tres"))      # Index 7 in MeshLibrary
	block_items_array.append(preload("res://inventory/items/wood_planks.tres"))      # Index 8 in MeshLibrary
	
	# Assign the array to GridMap
	gridmap.block_items = block_items_array

func connect_player_to_ui():
	# Connect player's slot change signal to inventory UI
	player.slot_changed.connect(inventory.set_selected_slot)

#extends Node3D
#
## Adjust these node paths to match your scene structure
#@onready var player = $Player  # Path to your player node
#@onready var gridmap = $GridMap  # Path to your gridmap node
#
#func _ready():
	## Connect player to gridmap for block collection
	#player.set_gridmap_reference(gridmap)
	#
	## Set up the block items array
	#setup_block_items()
#
#func setup_block_items():
	## Create array of your 10 block items
	#var block_items_array: Array[InvItem] = []
	#
	## IMPORTANT: Replace these paths with the actual paths to your .tres files
	## The index in this array should match the index in your GridMap's MeshLibrary
	#block_items_array.append(preload("res://inventory/items/bricks_grey.tres"))      # Index 0 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/diamond.tres"))     # Index 1 in MeshLibrary  
	#block_items_array.append(preload("res://inventory/items/dirt.tres"))      # Index 2 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/grass.tres"))     # Index 3 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/leaves.tres"))      # Index 4 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/snow.tres"))    # Index 5 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/stone.tres"))     # Index 6 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/wood.tres"))      # Index 7 in MeshLibrary
	#block_items_array.append(preload("res://inventory/items/wood_planks.tres"))      # Index 8 in MeshLibrary
	#
	## Assign the array to GridMap
	#gridmap.block_items = block_items_array
