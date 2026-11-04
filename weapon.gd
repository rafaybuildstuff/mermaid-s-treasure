extends Area2D

@export var speed: float = 500.0          
@export var max_range: float = 400.0      

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var wave_spawn_point: Node2D = $WaveSpawnPoint

var player: Node2D = null
var is_active: bool = false
var start_position: Vector2 = Vector2.ZERO
var travel_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	player = get_parent() as Node2D
	hide_weapon()

func _physics_process(delta: float) -> void:
	if not player:
		return

	if not is_active and Input.is_action_just_pressed("FIRE"):
		fire_weapon()

	if is_active:
		global_position += travel_direction * speed * delta
		
		if global_position.distance_to(start_position) >= max_range:
			return_to_player()
			
		check_hit()

func fire_weapon() -> void:
	is_active = true
	show_weapon()
	
	var mouse_pos = get_global_mouse_position()
	travel_direction = (mouse_pos - player.global_position).normalized()
	
	start_position = player.global_position
	global_position = start_position + (travel_direction * 20.0)
	
	rotation = travel_direction.angle()
	
	if travel_direction.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

	spawn_wave_effect()

func return_to_player() -> void:
	is_active = false
	hide_weapon()

func hide_weapon() -> void:
	visible = false
	collision_shape.disabled = true

func show_weapon() -> void:
	visible = true
	collision_shape.disabled = false

func spawn_wave_effect() -> void:
	var wave = Node2D.new()
	wave.set_script(preload("res://weapon_wave.gd"))
	
	if wave_spawn_point:
		wave_spawn_point.add_child(wave)
		wave.position = Vector2.ZERO
	else:
		add_child(wave)
		wave.position = Vector2.ZERO

func check_hit() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body != player and body.has_method("take_damage"):
			body.take_damage(10)
			return_to_player()
