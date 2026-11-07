extends CharacterBody2D

## Movement Settings
@export var speed: float = 250.0
@export var acceleration: float = 600.0
@export var friction: float = 400.0
@export var rotation_speed: float = 8.0  # How fast she tilts

## Health Settings
@export var max_health: int = 3
@onready var current_health: int = max_health

# Reference to your healthbar's AnimatedSprite2D. 
# Make sure this path matches where your healthbar node is located under your Player or CanvasLayer!
@onready var healthbar_sprite: AnimatedSprite2D = $healthbar/AnimatedSprite2D
# Invincibility frame tracking so player doesn't instantly die in one frame
var is_invincible: bool = false
@export var invincibility_duration: float = 2.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Track the last facing horizontal direction ("left" or "right") for idle states
var facing_dir: String = "right"

func _ready() -> void:
	update_healthbar()

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

	# 4. Apply velocity using CharacterBody2D built-in physics and check collisions
	move_and_slide()
	
	# Check for collisions with hazards/enemies using move_and_slide collisions
	check_hazard_collisions()

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

# --- Health & Damage System ---

func check_hazard_collisions() -> void:
	if is_invincible:
		return
		
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Make sure collider exists, is in hazards, AND is NOT the player itself
		if collider and collider.is_in_group("hazards") and collider != self:
			take_damage(1)
			break

func take_damage(amount: int) -> void:
	if is_invincible:
		return
		
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	start_invincibility()
	update_healthbar()
	
	# Trigger the camera shake and knockback feedback here!
	shake_camera()
	
	if current_health <= 0:
		die()

func shake_camera(intensity: float = 8.0, duration: float = 0.2) -> void:
	var camera = $Camera2D # Direct path to the child Camera2D node
	if camera:
		var tween = create_tween()
		for i in range(5):
			var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
			tween.tween_property(camera, "offset", offset, duration / 5.0)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
	else:
		start_invincibility()

func update_healthbar() -> void:
	if not healthbar_sprite:
		return
		
	match current_health:
		3:
			healthbar_sprite.play("full")
		2:
			healthbar_sprite.play("2 heart")
		1:
			healthbar_sprite.play("1 heart")
		0:
			healthbar_sprite.play("dead")

func start_invincibility() -> void:
	is_invincible = true
	# Optional: make sprite flash or look damaged here if you want
	
	# Wait for the invincibility duration using a scene tree timer
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

func die() -> void:
	print("Player died!")
	# This reloads the active scene immediately
	get_tree().reload_current_scene()
