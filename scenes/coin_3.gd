extends Area2D

@export var float_speed: float = 5.0
@export var float_height: float = 6.0

@onready var start_y: float = global_position.y
@onready var coin_sound = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Smooth floating up and down effect
	var time = Time.get_ticks_msec() / 1000.0
	global_position.y = start_y + sin(time * float_speed) * float_height

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		# Hide the sprite and disable collision so it can't be picked up twice
		$Sprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		
		# Play the sound effect and wait for it to finish before freeing the coin
		if coin_sound:
			coin_sound.play()
			await coin_sound.finished
		
		queue_free()
