extends Area2D

func _ready() -> void:
	# Connect the body_entered signal via code so it triggers automatically
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering the zone is the player
	if body.name == "player" or body.is_in_group("player"):
		# Safely reload the scene at the end of the frame to prevent physics errors
		get_tree().reload_current_scene.call_deferred()
