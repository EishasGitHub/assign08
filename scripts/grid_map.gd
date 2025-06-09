extends GridMap

@export var block_items: Array[InvItem] = []
@export var hit_sound: AudioStream 
@export var break_sound: AudioStream 

signal block_destroyed(item: InvItem, position: Vector3)

var damaged_blocks = {}
var audio_player: AudioStreamPlayer3D

func _ready():
	audio_player = AudioStreamPlayer3D.new()
	add_child(audio_player)
	audio_player.max_distance = 50.0
	audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

func destroy_block(world_coordinate):
	var map_coordinate = local_to_map(world_coordinate)
	var block_index = get_cell_item(map_coordinate)
	
	if block_index == -1:
		return
	
	var current_health = damaged_blocks.get(map_coordinate, 0)
	current_health += 1
	
	if current_health > 2:
		damaged_blocks.erase(map_coordinate)
		
		# Play break sound
		if break_sound and audio_player:
			audio_player.stream = break_sound
			audio_player.global_position = map_to_local(map_coordinate)
			audio_player.play()
		
		create_break_particles(map_to_local(map_coordinate))
		
		if block_index < block_items.size() and block_items[block_index] != null:
			var dropped_item = block_items[block_index]
			block_destroyed.emit(dropped_item, world_coordinate)
		
		set_cell_item(map_coordinate, -1)
		
	else:
		damaged_blocks[map_coordinate] = current_health
		
		if hit_sound and audio_player:
			audio_player.stream = hit_sound
			audio_player.global_position = map_to_local(map_coordinate)
			audio_player.play()
		
		create_hit_particles(map_to_local(map_coordinate))

func place_block(world_coordinate, block_index):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, block_index)
	
	damaged_blocks.erase(map_coordinate)

func create_hit_particles(world_position: Vector3):
	var particles = preload("res://scenes/hit_particles.tscn")
	if particles:
		var particle_instance = particles.instantiate()
		get_tree().current_scene.add_child(particle_instance)
		particle_instance.global_position = world_position
		particle_instance.emitting = true
		
		var timer = Timer.new()
		particle_instance.add_child(timer)
		timer.wait_time = 2.0
		timer.one_shot = true
		timer.timeout.connect(func(): particle_instance.queue_free())
		timer.start()
	else:
		create_simple_hit_particles(world_position)

func create_break_particles(world_position: Vector3):
	var particles = preload("res://scenes/break_particles.tscn")
	
	if particles:
		var particle_instance = particles.instantiate()
		get_tree().current_scene.add_child(particle_instance)
		particle_instance.global_position = world_position
		particle_instance.emitting = true
		
		var timer = Timer.new()
		particle_instance.add_child(timer)
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.timeout.connect(func(): particle_instance.queue_free())
		timer.start()
	else:
		create_simple_break_particles(world_position)

func create_simple_hit_particles(world_position: Vector3):
	var particles = GPUParticles3D.new()
	get_tree().current_scene.add_child(particles)
	particles.global_position = world_position
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	material.gravity = Vector3(0, -9.8, 0)
	material.scale_min = 0.1
	material.scale_max = 0.3
	
	particles.process_material = material
	particles.amount = 10
	particles.lifetime = 1.0
	particles.emitting = true
	
	var timer = Timer.new()
	particles.add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	timer.start()

func create_simple_break_particles(world_position: Vector3):
	var particles = GPUParticles3D.new()
	get_tree().current_scene.add_child(particles)
	particles.global_position = world_position
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 3.0
	material.initial_velocity_max = 8.0
	material.angular_velocity_min = -360.0
	material.angular_velocity_max = 360.0
	material.gravity = Vector3(0, -9.8, 0)
	material.scale_min = 0.2
	material.scale_max = 0.5
	
	particles.process_material = material
	particles.amount = 25
	particles.lifetime = 1.5
	particles.emitting = true
	
	var timer = Timer.new()
	particles.add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	timer.start()

func get_block_health(world_coordinate) -> int:
	var map_coordinate = local_to_map(world_coordinate)
	return damaged_blocks.get(map_coordinate, 0)

func reset_damaged_blocks():
	damaged_blocks.clear()

func get_damaged_blocks() -> Dictionary:
	return damaged_blocks.duplicate()

func set_damaged_blocks(blocks: Dictionary):
	damaged_blocks = blocks
