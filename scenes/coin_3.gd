extends Area2D

func _ready() -> void:
	# Safely connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the player
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		# Trigger your global score system here (e.g., GameManager.add_coin())
		print("Coin 3 collected!")
		
		# Delete the coin node from the scene
		queue_free()
