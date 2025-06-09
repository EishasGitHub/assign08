extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 12

var sensitivity = 0.005
var gravity = 24.0

@export var inv : Inv

var gridmap_reference = null
var selected_slot_index: int = 0 
var held_item: InvItem = null    

signal slot_changed(index: int)  


func _read():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_held_item()  
	
	if has_node("CraftingSystem"):
		var crafting_system = get_node("CraftingSystem")
		crafting_system.player_inventory = inv

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * sensitivity
		$Camera3D.rotation.x = $Camera3D.rotation.x - event.relative.y * sensitivity
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-70), deg_to_rad(80))
	
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			selected_slot_index = event.keycode - KEY_1  
			update_held_item()
			slot_changed.emit(selected_slot_index)
			
		elif event.keycode == KEY_0:
			selected_slot_index = 9
			update_held_item()
			slot_changed.emit(selected_slot_index)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_just_pressed("remove_block"):
		if $Camera3D/RayCast3D.is_colliding():
			if $Camera3D/RayCast3D.get_collider().has_method("destroy_block"):
				var collision_point = $Camera3D/RayCast3D.get_collision_point()
				var collision_normal = $Camera3D/RayCast3D.get_collision_normal()
				$Camera3D/RayCast3D.get_collider().destroy_block(collision_point - collision_normal)

	if Input.is_action_just_pressed("place_block"):
		if $Camera3D/RayCast3D.is_colliding() and held_item != null:
			if $Camera3D/RayCast3D.get_collider().has_method("place_block"):
				var collision_point = $Camera3D/RayCast3D.get_collision_point()
				var collision_normal = $Camera3D/RayCast3D.get_collision_normal()
				
				var block_index = get_block_index_for_item(held_item)
				if block_index != -1:
					$Camera3D/RayCast3D.get_collider().place_block(collision_point + collision_normal, block_index)
					
					use_held_item()

	move_and_slide()

func player():
	pass
	
func collect(item):
	inv.insert(item)

func set_gridmap_reference(gridmap):
	gridmap_reference = gridmap
	if gridmap_reference:
		gridmap_reference.block_destroyed.connect(_on_block_destroyed)

func _on_block_destroyed(item: InvItem, position: Vector3):
	collect(item)
	update_held_item() 

func update_held_item():
	if selected_slot_index < inv.slots.size():
		var slot = inv.slots[selected_slot_index]
		if slot.item != null and slot.amount > 0:
			held_item = slot.item
		else:
			held_item = null
	else:
		held_item = null

func use_held_item():
	if selected_slot_index < inv.slots.size():
		var slot = inv.slots[selected_slot_index]
		if slot.item != null and slot.amount > 0:
			slot.amount -= 1
			if slot.amount <= 0:
				slot.item = null
				slot.amount = 0
				held_item = null
			inv.update.emit()  

func get_block_index_for_item(item: InvItem) -> int:
	if gridmap_reference and gridmap_reference.block_items:
		for i in range(gridmap_reference.block_items.size()):
			if gridmap_reference.block_items[i] == item:
				return i
	return -1
