extends Area2D

var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Automatically destroy the ink after 4 seconds so it doesn't stay forever
	await get_tree().create_timer(4.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Move the ink in the direction of the player
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if it hits the player
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		if body.has_method("take_damage"):
			body.take_damage(1) # Deal 1 damage to the player
		queue_free() # Remove ink on impact
