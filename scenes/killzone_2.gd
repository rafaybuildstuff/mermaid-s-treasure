extends Area2D

func _ready() -> void:
	# Connect the body_entered signal via code so it triggers automatically
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering the zone is the player
	if body.name == "player" or body.is_in_group("player"):
		# Option A: Reload the current scene (quickest way to reset the level)
		get_tree().reload_current_scene()
		
		# Option B: If you prefer to teleport them instead of reloading, 
		# uncomment the line below and point it to a spawn position node:
		# body.global_position = Vector2(100, 100)
