extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label
@onready var selected_slot: Sprite2D = $Sprite2D

func update(slot: InvSlot):
	if !slot.item:
		item_visual.visible = false
		amount_text.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		item_visual.scale = Vector2(5, 5)
		
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)
		else:
			amount_text.visible = false

func highlight(is_selected: bool):
	if is_selected:
		modulate = Color(1.5, 1.5, 1.5)  

	else:
		modulate = Color(0.8, 0.8, 0.8) 
