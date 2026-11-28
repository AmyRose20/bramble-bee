extends Control


func _ready() -> void:
	$Layout/PlayButton.pressed.connect(_on_play_pressed)
	$Layout/LevelsButton.pressed.connect(_on_levels_pressed)


func _on_play_pressed() -> void:
	# Carry on from the furthest level the player has unlocked
	GameData.start_level(GameData.latest_playable_level())


func _on_levels_pressed() -> void:
	# Open the level select screen
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
