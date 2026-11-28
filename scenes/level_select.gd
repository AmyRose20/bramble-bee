extends Control

# The star picture, loaded once and reused for every level
const STAR_TEXTURE := preload("res://art/star.svg")

@onready var grid: GridContainer = $Layout/Grid


func _ready() -> void:
	$Layout/BackButton.pressed.connect(_on_back_pressed)

	# Make one button (with stars underneath) for each level
	for level in range(1, GameData.LEVEL_COUNT + 1):
		grid.add_child(make_level_cell(level))


func make_level_cell(level: int) -> VBoxContainer:
	var cell := VBoxContainer.new()

	# The level button
	var button := Button.new()
	button.text = str(level)
	button.custom_minimum_size = Vector2(160, 120)
	button.add_theme_font_size_override("font_size", 48)

	# Playable if it's unlocked AND it's been built
	var playable := level <= GameData.unlocked_level and GameData.level_exists(level)
	button.disabled = not playable
	if playable:
		# .bind(level) means "call start_level with this level's number"
		button.pressed.connect(GameData.start_level.bind(level))
	cell.add_child(button)

	# The row of 3 stars underneath
	var stars_row := HBoxContainer.new()
	stars_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var earned: int = GameData.best_stars.get(level, 0)
	for i in 3:
		var star := TextureRect.new()
		star.texture = STAR_TEXTURE
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(36, 35)
		if i < earned:
			star.modulate = Color(1, 1, 1, 1)      # earned: full colour
		else:
			star.modulate = Color(1, 1, 1, 0.25)   # not earned: faded
		stars_row.add_child(star)
	cell.add_child(stars_row)

	return cell


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn")
