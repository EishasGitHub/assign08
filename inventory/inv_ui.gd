#extends Control
#
#@onready var inv: Inv = preload("res://inventory/playerinv.tres")
#@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
#
#func _ready() -> void:
	#inv.update.connect(update_slots)
	#update_slots()
#
#func update_slots():
	#for i in range(min(inv.slots.size(), slots.size())):
		#slots[i].update(inv.slots[i])


extends Control

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var player_reference = null
var selected_slot_index: int = 0

func _ready() -> void:
	inv.update.connect(update_slots)
	update_slots()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
		# Highlight selected slot
		if i == selected_slot_index:
			slots[i].highlight(true)
		else:
			slots[i].highlight(false)

func set_player_reference(player):
	player_reference = player

func set_selected_slot(index: int):
	selected_slot_index = index
	update_slots()
