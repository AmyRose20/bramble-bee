extends Control


func _ready() -> void:
	# When the Play button is pressed, run _on_play_pressed
	$Layout/PlayButton.pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	# Swap the title screen for the level
	get_tree().change_scene_to_file("res://scenes/level.tscn")
