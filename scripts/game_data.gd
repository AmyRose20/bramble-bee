extends Node

# How many levels the game has
const LEVEL_COUNT := 10
# Where progress is saved (the app's own private storage)
const SAVE_PATH := "user://save.cfg"

# Which level is being played right now
var current_level := 1
# The highest level the player is allowed to play
var unlocked_level := 1
# Best results for each level, looked up by level number
var best_stars := {}   # e.g. { 1: 3, 2: 2 }
var best_times := {}   # e.g. { 1: 42.5, 2: 65.0 }  (seconds)


func _ready() -> void:
	# Load any saved progress when the game starts
	load_progress()


# The file path for a level number, e.g. 1 -> res://scenes/levels/level_01.tscn
func level_path(level: int) -> String:
	return "res://scenes/levels/level_%02d.tscn" % level


# Has this level been built yet?
func level_exists(level: int) -> bool:
	return ResourceLoader.exists(level_path(level))


# The furthest unlocked level that actually exists
# (so Play never tries to open a level that hasn't been built)
func latest_playable_level() -> int:
	var level := unlocked_level
	while level > 1 and not level_exists(level):
		level -= 1
	return level


# Open a level
func start_level(level: int) -> void:
	if not level_exists(level):
		push_warning("Level %d doesn't exist yet" % level)
		return
	current_level = level
	get_tree().change_scene_to_file(level_path(level))


# Is there a next level, and has it been built yet?
func has_next_level() -> bool:
	var next := current_level + 1
	return next <= LEVEL_COUNT and level_exists(next)


func start_next_level() -> void:
	start_level(current_level + 1)


# Called when a level is finished: keep the best results and unlock the next level
func record_result(level: int, stars: int, time: float) -> void:
	# More stars than before? Keep them
	if stars > best_stars.get(level, 0):
		best_stars[level] = stars

	# Faster than before (or first time)? Keep the time
	if not best_times.has(level) or time < best_times[level]:
		best_times[level] = time

	# Unlock the next level
	if level + 1 > unlocked_level and level < LEVEL_COUNT:
		unlocked_level = level + 1

	save_progress()


# ---------- Saving and loading ----------

func save_progress() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "unlocked_level", unlocked_level)
	save.set_value("progress", "best_stars", best_stars)
	save.set_value("progress", "best_times", best_times)
	save.save(SAVE_PATH)


func load_progress() -> void:
	var save := ConfigFile.new()
	# No save file yet (first time playing)? Keep the starting values
	if save.load(SAVE_PATH) != OK:
		return
	unlocked_level = save.get_value("progress", "unlocked_level", 1)
	best_stars = save.get_value("progress", "best_stars", {})
	best_times = save.get_value("progress", "best_times", {})


# Wipe all progress (handy for testing)
func reset_progress() -> void:
	unlocked_level = 1
	best_stars = {}
	best_times = {}
	save_progress()
