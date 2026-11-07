extends Area2D

@export var move_speed: float = 2.0       # How fast it moves up and down
@export var move_distance: float = 80.0   # How far it travels up and down from its start position

#add
@export var knockback_force: float = 400.0 # Force that throws the player away

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

var start_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	start_y = position.y
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time_passed += delta * move_speed
	position.y = start_y + sin(time_passed) * move_distance

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		#add
		# 1. Calculate direction away from grabber to throw player
		var knockback_direction = (body.global_position - global_position).normalized()
		
		# 2. Apply knockback velocity if player has the method
		if body.has_method("apply_knockback"):
			body.apply_knockback(knockback_direction * knockback_force)
		
		# 3. Call take_damage on player instead of reloading scene instantly
		if body.has_method("take_damage"):
			body.take_damage(1)

#remove
# (Removed _reload_scene completely)
