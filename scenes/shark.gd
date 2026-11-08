extends CharacterBody2D

enum State { PATROL, CHARGE, STUNNED }
var current_state = State.PATROL

@export var max_health: int = 3
var current_health: int = max_health

@export var patrol_speed: float = 120.0
@export var charge_speed: float = 120.0
@export var direction: int = 1

# Strict horizontal patrol boundaries
@export var min_x: float = 1257.0
@export var max_x: float = 2157.0

@onready var detection_area: Area2D = $DetectionArea
@onready var stun_timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D

var charge_time_left: float = 0.0
@export var max_charge_duration: float = 2.5 

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("hazards")
	show()
	if sprite:
		sprite.show()
		sprite.modulate = Color(1, 1, 1, 1)
		z_index = 10

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			velocity.x = direction * patrol_speed
			velocity.y = 0
			
			if global_position.x <= min_x:
				global_position.x = min_x
				direction = 1
			elif global_position.x >= max_x:
				global_position.x = max_x
				direction = -1
			
			if sprite:
				sprite.flip_h = (direction > 0)
				sprite.modulate = Color(1, 1, 1, 1)
				
			if is_on_wall():
				direction *= -1
				
		State.CHARGE:
			charge_time_left -= delta
			
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				var player = players[0] as Node2D
				var target_dir = (player.global_position - global_position).normalized()
				velocity = target_dir * charge_speed
				
				# Face the shark accurately toward the player's horizontal direction
				
			else:
				velocity = Vector2.ZERO

			if charge_time_left <= 0 or is_on_wall():
				current_state = State.PATROL
				charge_time_left = max_charge_duration

		State.STUNNED:
			velocity = Vector2.ZERO
			if sprite:
				sprite.modulate = Color(0.5, 0.5, 0.5, 1)

	move_and_slide()

func take_damage(damage: int) -> void:
	current_health -= damage
	flash_hit()
	
	if current_health <= 0:
		die()

func flash_hit() -> void:
	if sprite:
		# Flash pure red when taking weapon damage
		sprite.modulate = Color(1, 0, 0, 1)
		await get_tree().create_timer(0.15).timeout
		if current_state == State.CHARGE:
			sprite.modulate = Color(1, 0.2, 0.2, 1) # Return to red eyes
		else:
			sprite.modulate = Color(1, 1, 1, 1) # Return to normal

func die() -> void:
	queue_free.call_deferred()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state == State.PATROL:
		current_state = State.CHARGE
		charge_time_left = max_charge_duration

func start_stun() -> void:
	current_state = State.STUNNED
	stun_timer.start(1.5)

func _on_timer_timeout() -> void:
	current_state = State.PATROL
