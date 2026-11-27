extends CharacterBody2D

# How strongly gravity pulls the bee down
const GRAVITY := 1200.0
# How strongly holding Fly pushes the bee up
const FLY_FORCE := 1800.0
# Extra push when you press Fly while falling, so the bee recovers quickly
const FALL_RECOVERY := 2.5
# How fast the bee moves left and right
const MOVE_SPEED := 250.0
# Speed limits, so the bee never moves too fast
const MAX_FALL_SPEED := 550.0
const MAX_RISE_SPEED := 350.0

# True for a short time after being hit, so the bee can't lose two lives at once
var invincible := false


func _ready() -> void:
	# Label the bee so flowers and hazards know it's the bee
	add_to_group("bee")


func start_invincibility() -> void:
	invincible = true

	# Flash the bee: fade to see-through and back, 6 times (about 1.5 seconds)
	var tween := create_tween()
	tween.set_loops(4)
	tween.tween_property(self, "modulate:a", 0.3, 0.12)
	tween.tween_property(self, "modulate:a", 1.0, 0.12)

	# Wait until the flashing has finished, then the bee can be hit again
	await tween.finished
	invincible = false


func _physics_process(delta: float) -> void:
	# 1. Gravity always pulls the bee down
	velocity.y += GRAVITY * delta

	# 2. Holding Fly pushes the bee up
	if Input.is_action_pressed("fly"):
		if velocity.y > 0:
			# Still falling: push up extra hard to recover quickly
			velocity.y -= FLY_FORCE * FALL_RECOVERY * delta
		else:
			# Already rising: normal push
			velocity.y -= FLY_FORCE * delta

	# 3. Keep the up/down speed within the limits
	velocity.y = clamp(velocity.y, -MAX_RISE_SPEED, MAX_FALL_SPEED)

	# 4. Left/right: gives -1 (left), 0 (nothing) or 1 (right)
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	# 5. Move the bee, handling any collisions
	move_and_slide()
