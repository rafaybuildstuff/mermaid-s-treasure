extends CharacterBody2D

@export var max_health: int = 15
@onready var current_health: int = max_health

@export var ink_scene: PackedScene 
@export var treasure_scene: PackedScene 

@onready var detection_area = $DetectionArea
@onready var boss_health_bar = get_node_or_null("boss health")
@onready var boss_die_sound = $"die sound"

var player_in_range: Node2D = null
var ink_timer: Timer

func _ready() -> void:
	add_to_group("boss")
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	ink_timer = Timer.new()
	ink_timer.wait_time = 1.0 
	ink_timer.autostart = false
	ink_timer.timeout.connect(_on_ink_timer_timeout)
	add_child(ink_timer)
	
	if boss_health_bar:
		boss_health_bar.update_health_display(current_health)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		player_in_range = body
		ink_timer.start()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		ink_timer.stop()

func _on_ink_timer_timeout() -> void:
	if player_in_range and ink_scene:
		throw_ink()

func throw_ink() -> void:
	var ink = ink_scene.instantiate() as Node2D
	ink.global_position = global_position 
	var direction = (player_in_range.global_position - global_position).normalized()
	if "direction" in ink:
		ink.direction = direction
	get_tree().current_scene.add_child(ink)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Boss took damage! Health left: ", current_health, "/", max_health)
	
	if boss_health_bar:
		boss_health_bar.update_health_display(current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Boss defeated!")
	
	# Hide the boss sprite & disable collision immediately so it looks dead
	$Sprite2D.visible = false
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	if detection_area:
		detection_area.monitoring = false

	# Spawn the treasure right away
	spawn_treasure()
	
	# Remove the health bar UI
	if boss_health_bar:
		boss_health_bar.queue_free()
	
	# Play the sound effect completely before removing the boss node
	if boss_die_sound:
		boss_die_sound.play()
		await boss_die_sound.finished
	
	queue_free()

func spawn_treasure() -> void:
	if treasure_scene:
		var treasure = treasure_scene.instantiate() as Node2D
		treasure.global_position = global_position 
		get_tree().current_scene.add_child(treasure)
