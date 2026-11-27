extends Node2D

# How many flowers the bee has collected so far
var collected_count := 0
# How many flowers are in this level (counted when the level starts)
var total_flowers := 0

# Shortcuts to the text on screen
@onready var flower_counter: Label = $HUD/FlowerCounter
@onready var level_complete_label: Label = $HUD/LevelComplete


func _ready() -> void:
	# Find every flower in the level
	var flowers := get_tree().get_nodes_in_group("flowers")
	total_flowers = flowers.size()

	# Listen for each flower's "collected" message
	for flower in flowers:
		flower.collected.connect(_on_flower_collected)

	update_counter()


func _on_flower_collected() -> void:
	collected_count += 1
	update_counter()

	# All flowers collected? Show the message
	if collected_count == total_flowers:
		level_complete_label.visible = true


func update_counter() -> void:
	flower_counter.text = "%d / %d" % [collected_count, total_flowers]
