extends Area2D

# Drag your end scene (.tscn) into this Inspector slot
@export var end_scene: PackedScene 
@onready var treasure_sound = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		# Hide the treasure instantly so it disappears visually
		visible = false
		
		# Disable collision so it can't be triggered twice
		monitoring = false 
		
		# Play the audio sound effect and wait for it to finish playing
		if treasure_sound:
			treasure_sound.play()
			await treasure_sound.finished
		
		# Change to the end scene
		if end_scene:
			get_tree().change_scene_to_packed(end_scene)
		else:
			print("Error: No end_scene assigned to Treasure!")
			queue_free()
