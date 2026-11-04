extends CharacterBody2D

## Movement Settings
@export var speed: float = 250.0
@export var acceleration: float = 600.0
@export var friction: float = 400.0

@onready var sprite: Sprite2D = $Sprite2D  # Adjust node name to match your scene layout

func _physics_process(delta: float) -> void:
	# 1. Get input vector for 8-directional underwater swimming
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Apply movement smooth dynamics (water physics feel)
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 3. Handle Sprite Flipping (Left / Right facing direction)
	if input_vector.x < 0:
		sprite.flip_h = true
	elif input_vector.x > 0:
		sprite.flip_h = false

	# 4. Apply velocity using CharacterBody2D built-in physics
	move_and_slide()
