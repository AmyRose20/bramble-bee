extends Node2D

# How many lives the bee starts each level with
const STARTING_LIVES := 3
# The height of one screen, in pixels
const SCREEN_HEIGHT := 1280

# ---------- Level settings (set these in the Inspector for each level) ----------

# Which level this is, shown at the top of the screen
@export var level_number := 1
# How tall this level is: 1280 = one screen, 2560 = two screens, 3840 = three...
@export var level_height := 1280

# ---------- Game state ----------

# How many flowers the bee has collected so far
var collected_count := 0
# How many flowers are in this level (counted when the level starts)
var total_flowers := 0
# How many lives the bee has left
var lives := STARTING_LIVES
# Where the bee starts, so we can send it back there when it's hit
var bee_start_position := Vector2.ZERO
# How long the player has been playing this level (seconds)
var time_taken := 0.0
# True once all lives are lost, or once every flower is collected
var is_game_over := false
var is_level_complete := false

# Shortcuts to nodes in the level
@onready var bee: CharacterBody2D = $Bee
@onready var camera: Camera2D = $Bee/Camera2D
@onready var ceiling: CollisionShape2D = $Bounds/Ceiling
@onready var level_name_label: Label = $HUD/LevelName
@onready var flower_counter: Label = $HUD/FlowerCounter
@onready var lives_display: HBoxContainer = $HUD/Lives
@onready var pause_menu: Control = $HUD/PauseMenu
@onready var level_complete_menu: Control = $HUD/LevelCompleteMenu
@onready var stars_row: HBoxContainer = $HUD/LevelCompleteMenu/Panel/Items/Stars
@onready var stats_label: Label = $HUD/LevelCompleteMenu/Panel/Items/Stats
@onready var next_button: Button = $HUD/LevelCompleteMenu/Panel/Items/NextButton
@onready var game_over_menu: Control = $HUD/GameOverMenu
@onready var game_over_stats: Label = $HUD/GameOverMenu/Panel/Items/GameOverStats


func _ready() -> void:
	# Make sure GameData knows which level this is
	# (useful when testing a single level with F6)
	GameData.current_level = level_number

	# Set up this level using its settings
	setup_level()

	# Find every flower in the level and listen for "collected"
	var flowers := get_tree().get_nodes_in_group("flowers")
	total_flowers = flowers.size()
	for flower in flowers:
		flower.collected.connect(_on_flower_collected)

	# Find every hazard (brambles, wasps) and listen for "bee_hit"
	for hazard in get_tree().get_nodes_in_group("hazards"):
		hazard.bee_hit.connect(_on_bee_hit)

	# Connect the pause button and the pause menu's buttons
	$HUD/PauseButton.pressed.connect(pause_game)
	$HUD/PauseMenu/Panel/Items/ResumeButton.pressed.connect(resume_game)
	$HUD/PauseMenu/Panel/Items/RestartButton.pressed.connect(restart_level)
	$HUD/PauseMenu/Panel/Items/MenuButton.pressed.connect(go_to_menu)

	# Connect the level complete screen's buttons
	next_button.pressed.connect(go_to_next_level)
	$HUD/LevelCompleteMenu/Panel/Items/RetryButton.pressed.connect(restart_level)
	$HUD/LevelCompleteMenu/Panel/Items/MenuButton.pressed.connect(go_to_menu)

	# Connect the game over screen's buttons
	$HUD/GameOverMenu/Panel/Items/TryAgainButton.pressed.connect(restart_level)
	$HUD/GameOverMenu/Panel/Items/MenuButton.pressed.connect(go_to_menu)

	# Remember where the bee starts
	bee_start_position = bee.position

	update_counter()
	update_lives()


func setup_level() -> void:
	# Show the level number at the top
	level_name_label.text = "Level %d" % level_number

	# The ground is at the bottom of the first screen, so the top of
	# the level is (level_height) pixels above the bottom of that screen
	var level_top := SCREEN_HEIGHT - level_height

	# Move the ceiling to the top of the level
	ceiling.position.y = level_top
	# Stop the camera scrolling above the top of the level
	camera.limit_top = level_top


func _process(delta: float) -> void:
	# Count the time while the level is being played
	if not is_game_over and not is_level_complete:
		time_taken += delta


func _on_flower_collected() -> void:
	collected_count += 1
	update_counter()

	# All flowers collected? Level complete!
	if collected_count == total_flowers:
		level_complete()


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
	# Jump the camera straight back too, instead of gliding all the way down
	camera.reset_smoothing()


func level_complete() -> void:
	is_level_complete = true
	get_tree().paused = true    # freeze the level behind the screen

	# Stars: one for each life left (3 lives = 3 stars)
	var stars_earned := lives
	var stars := stars_row.get_children()
	for i in stars.size():
		if i < stars_earned:
			stars[i].modulate = Color(1, 1, 1, 1)      # earned: full colour
		else:
			stars[i].modulate = Color(1, 1, 1, 0.25)   # not earned: faded

	# Stats
	var minutes := int(time_taken) / 60
	var seconds := int(time_taken) % 60
	stats_label.text = "Flowers: %d / %d\nTime: %d:%02d\nLives left: %d" % [
		collected_count, total_flowers, minutes, seconds, lives
	]

	# Save the result and unlock the next level
	GameData.record_result(level_number, stars_earned, time_taken)

	# Only let the player press Next if the next level exists
	next_button.disabled = not GameData.has_next_level()

	level_complete_menu.visible = true


func game_over() -> void:
	is_game_over = true
	get_tree().paused = true    # freeze the level behind the screen

	game_over_stats.text = "Flowers collected: %d / %d" % [collected_count, total_flowers]
	game_over_menu.visible = true


# ---------- Menu buttons ----------

func pause_game() -> void:
	get_tree().paused = true      # freeze the whole game
	pause_menu.visible = true


func resume_game() -> void:
	get_tree().paused = false
	pause_menu.visible = false


func restart_level() -> void:
	get_tree().paused = false     # always unpause before leaving, or the next screen starts frozen
	get_tree().reload_current_scene()


func go_to_next_level() -> void:
	get_tree().paused = false
	GameData.start_next_level()


func go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")


# ---------- Display ----------

func update_counter() -> void:
	flower_counter.text = "%d / %d" % [collected_count, total_flowers]


func update_lives() -> void:
	# Show one heart per life left: heart 0 shows if lives > 0, heart 1 if lives > 1, and so on
	var hearts := lives_display.get_children()
	for i in hearts.size():
		hearts[i].visible = i < lives
