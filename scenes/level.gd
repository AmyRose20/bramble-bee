extends Node2D

# How many lives the bee starts each level with
const STARTING_LIVES := 3

# How many flowers the bee has collected so far
var collected_count := 0
# How many flowers are in this level (counted when the level starts)
var total_flowers := 0
# How many lives the bee has left
var lives := STARTING_LIVES
# Where the bee starts, so we can send it back there when it's hit
var bee_start_position := Vector2.ZERO
# True once all lives are lost
var is_game_over := false

# Shortcuts to nodes in the level
@onready var bee: CharacterBody2D = $Bee
@onready var flower_counter: Label = $HUD/FlowerCounter
@onready var level_complete_label: Label = $HUD/LevelComplete
@onready var lives_display: HBoxContainer = $HUD/Lives
@onready var game_over_label: Label = $HUD/GameOver


func _ready() -> void:
	# Find every flower in the level and listen for "collected"
	var flowers := get_tree().get_nodes_in_group("flowers")
	total_flowers = flowers.size()
	for flower in flowers:
		flower.collected.connect(_on_flower_collected)

	# Find every hazard (brambles, later the wasp) and listen for "bee_hit"
	for hazard in get_tree().get_nodes_in_group("hazards"):
		hazard.bee_hit.connect(_on_bee_hit)

	# Remember where the bee starts
	bee_start_position = bee.position

	update_counter()
	update_lives()


func _process(_delta: float) -> void:
	# After game over, pressing Fly restarts the level
	if is_game_over and Input.is_action_just_pressed("fly"):
		get_tree().reload_current_scene()


func _on_flower_collected() -> void:
	collected_count += 1
	update_counter()

	# All flowers collected? Show the message
	if collected_count == total_flowers:
		level_complete_label.visible = true


func _on_bee_hit() -> void:
	# Ignore hits during the safe period, or once the game is over
	if bee.invincible or is_game_over:
		return

	lives -= 1
	update_lives()

	if lives <= 0:
		game_over()
	else:
		respawn_bee()
		bee.start_invincibility()


func respawn_bee() -> void:
	# Put the bee back at the start, standing still
	bee.position = bee_start_position
	bee.velocity = Vector2.ZERO


func game_over() -> void:
	is_game_over = true
	game_over_label.visible = true
	game_over_label.text = "Game over\nPress Fly to try again"
	# Freeze the bee where it is
	bee.set_physics_process(false)


func update_counter() -> void:
	flower_counter.text = "%d / %d" % [collected_count, total_flowers]


func update_lives() -> void:
	# Show one heart per life left: heart 0 shows if lives > 0, heart 1 if lives > 1, and so on
	var hearts := lives_display.get_children()
	for i in hearts.size():
		hearts[i].visible = i < lives
