extends Area2D

@export var move_speed: float = 2.0       # How fast it moves up and down
@export var move_distance: float = 80.0   # How far it travels up and down from its start position

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

var start_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	# Remember its original vertical starting position in the scene
	start_y = position.y
	
	# Connect the collision signal safely
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Advance time for the vertical motion wave
	time_passed += delta * move_speed
	
	# Move up and down smoothly along the Y axis using a sine wave
	position.y = start_y + sin(time_passed) * move_distance

func _on_body_entered(body: Node2D) -> void:
	# If the mermaid touches the grabber, safely reload the scene
	if body.name == "player" or body.is_in_group("player"):
		call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()
