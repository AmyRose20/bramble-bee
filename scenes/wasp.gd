extends Area2D

# A message this wasp sends out when it touches the bee
signal bee_hit

# How far the wasp flies to the right of its starting point before turning (pixels)
@export var patrol_distance := 200.0
# How fast the wasp flies (pixels per second)
@export var speed := 120.0

# Where the wasp started, so it knows where to turn back
var start_x := 0.0
# Which way it's flying: 1 = right, -1 = left
var direction := 1

# A shortcut to the wasp's picture
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	# Join the "hazards" group, just like the brambles,
	# so the level automatically listens for bee_hit
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	start_x = position.x


func _physics_process(delta: float) -> void:
	# Move left or right
	position.x += direction * speed * delta

	# Turn around at either end of the patrol
	if position.x > start_x + patrol_distance:
		direction = -1
	elif position.x < start_x:
		direction = 1

	# The picture faces left, so flip it when flying right
	sprite.flip_h = direction == 1


func _on_body_entered(body: Node2D) -> void:
	# Only the bee gets hurt
	if body.is_in_group("bee"):
		bee_hit.emit()
