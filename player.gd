extends CharacterBody2D

## Movement Settings
@export var speed: float = 250.0
@export var acceleration: float = 600.0
@export var friction: float = 400.0
@export var rotation_speed: float = 8.0  # How fast she tilts

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Track the last facing horizontal direction ("left" or "right") for idle states
var facing_dir: String = "right"

func _physics_process(delta: float) -> void:
	# 1. Use built-in default UI actions
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Apply movement smooth dynamics (water physics feel)
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 3. Handle Animations, Direction, and Tilting
	update_animations(input_vector)
	handle_rotation(input_vector, delta)

	# 4. Apply velocity using CharacterBody2D built-in physics
	move_and_slide()

func update_animations(input_vector: Vector2) -> void:
	# Update horizontal facing direction when moving horizontally
	if input_vector.x < 0:
		facing_dir = "left"
	elif input_vector.x > 0:
		facing_dir = "right"

	# Determine animation based on movement state and direction
	if input_vector != Vector2.ZERO:
		if input_vector.y < 0:
			animated_sprite.play(facing_dir + " up")
		elif input_vector.y > 0:
			animated_sprite.play(facing_dir + " down")
		else:
			animated_sprite.play(facing_dir + " walk")
	else:
		animated_sprite.play(facing_dir + " idle")

func handle_rotation(input_vector: Vector2, delta: float) -> void:
	var target_rotation: float = 0.0
	
	# If moving downwards, tilt to 160 degrees (converted to radians)
	if input_vector.y > 0:
		# 160 degrees converted to radians. 
		# If she faces left, we tilt the other way (-160 degrees) so she leans naturally.
		var angle_deg = 160.0 if facing_dir == "right" else -160.0
		target_rotation = deg_to_rad(angle_deg)
	else:
		target_rotation = 0.0  # Default upright

	# Smoothly interpolate rotation
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
