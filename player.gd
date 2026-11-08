extends CharacterBody2D

## Movement Settings
@export var speed: float = 250.0
@export var acceleration: float = 600.0
@export var friction: float = 400.0
@export var rotation_speed: float = 8.0

## Health Settings
@export var max_health: int = 3
@onready var current_health: int = max_health

@onready var healthbar_sprite: AnimatedSprite2D = $healthbar/AnimatedSprite2D
var is_invincible: bool = false
@export var invincibility_duration: float = 2.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_dir: String = "right"

func _ready() -> void:
	# Register player in the "player" group for enemy tracking
	add_to_group("player")
	update_healthbar()

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	update_animations(input_vector)
	handle_rotation(input_vector, delta)
	move_and_slide()
	check_hazard_collisions()

func update_animations(input_vector: Vector2) -> void:
	if input_vector.x < 0:
		facing_dir = "left"
	elif input_vector.x > 0:
		facing_dir = "right"

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
	
	if input_vector.y > 0:
		var angle_deg = 160.0 if facing_dir == "right" else -160.0
		target_rotation = deg_to_rad(angle_deg)
	else:
		target_rotation = 0.0

	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

func check_hazard_collisions() -> void:
	if is_invincible:
		return
		
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Detect colliders tagged as "hazards" or "enemy"
		if collider and (collider.is_in_group("hazards") or collider.is_in_group("enemy")) and collider != self:
			take_damage(1)
			break

func take_damage(amount: int) -> void:
	if is_invincible:
		return
		
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	start_invincibility()
	update_healthbar()
	shake_camera()
	
	if current_health <= 0:
		die()

func shake_camera(intensity: float = 8.0, duration: float = 0.2) -> void:
	var camera = get_node_or_null("Camera2D")
	if camera:
		var tween = create_tween()
		for i in range(5):
			var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
			tween.tween_property(camera, "offset", offset, duration / 5.0)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

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
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

func die() -> void:
	print("Player died!")
	get_tree().reload_current_scene()
