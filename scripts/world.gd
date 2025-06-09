extends Node3D

@onready var player = $Player 
@onready var gridmap = $GridMap  
@onready var inventory = $Player/Inv_UI

@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var timer: Timer = $Timer
var time_of_day: float = 0.0  
var cycle_duration := 120.0
var night_color = Color(0.05, 0.05, 0.1)
var day_color = Color(1, 1, 1)

func _ready():
	player.set_gridmap_reference(gridmap)
	
	inventory.set_player_reference(player)
	
	setup_block_items()
	
	connect_player_to_ui()
	
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# Advance time_of_day
	time_of_day += timer.wait_time / cycle_duration
	if time_of_day > 1.0:
		time_of_day = 0.0

	update_day_night_cycle()


func update_day_night_cycle():
	var angle = time_of_day * TAU
	var sun_height = sin(angle)

	sun.rotation_degrees.x = -cos(angle) * 45.0  

	sun.light_color = day_color.lerp(night_color, 1.0 - clamp(sun_height, 0.0, 1.0))

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
