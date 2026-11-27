extends Area2D

# A message this bramble sends out when the bee touches it
signal bee_hit


func _ready() -> void:
	# Put every bramble in a "hazards" group so the level can find them
	# (the wasp in Part 5 will join this group too)
	add_to_group("hazards")
	# When something enters this bramble's area, run _on_body_entered
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only the bee gets hurt
	if body.is_in_group("bee"):
		bee_hit.emit()   # tell the level
