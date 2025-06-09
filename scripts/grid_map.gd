extends GridMap

@export var block_items: Array[InvItem] = []
signal block_destroyed(item: InvItem, position: Vector3)

#func destroy_block(world_coordinate):
	#var map_coordinate = local_to_map(world_coordinate)
	#set_cell_item(map_coordinate, -1)
#
#func place_block(world_coordinate, block_index):
	#var map_coordinate = local_to_map(world_coordinate)
	#set_cell_item(map_coordinate, block_index)

func destroy_block(world_coordinate):
	var map_coordinate = local_to_map(world_coordinate)
	var block_index = get_cell_item(map_coordinate)
	
	# Check if there's actually a block here and we have an item for it
	if block_index != -1 and block_index < block_items.size() and block_items[block_index] != null:
		var dropped_item = block_items[block_index]
		# Emit signal with the item and world position for player to collect
		block_destroyed.emit(dropped_item, world_coordinate)
	
	# Remove the block from the grid
	set_cell_item(map_coordinate, -1)

func place_block(world_coordinate, block_index):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, block_index)
