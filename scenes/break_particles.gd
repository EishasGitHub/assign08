extends GPUParticles3D

func _ready():
	emitting = true

	var cleanup_timer = Timer.new()
	add_child(cleanup_timer)
	cleanup_timer.wait_time = lifetime + 1.5
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(_cleanup)
	cleanup_timer.start()

func _cleanup():
	queue_free()

func set_block_color(color: Color):
	if process_material is ParticleProcessMaterial:
		var material = process_material as ParticleProcessMaterial
		material.color = color
