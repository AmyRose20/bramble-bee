extends Area2D

# A message this flower sends out when it's collected
signal collected


func _ready() -> void:
	# Put every flower in a "flowers" group so the level can find and count them
	add_to_group("flowers")
	# When something enters this flower's area, run _on_body_entered
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only the bee can collect flowers
	if body.is_in_group("bee"):
		collected.emit()   # tell the level
		queue_free()       # remove this flower from the game
