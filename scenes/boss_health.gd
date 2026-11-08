extends CanvasLayer

# Get a reference to the AnimatedSprite2D child node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("health_bar"):
		animated_sprite.play("health_bar")
		animated_sprite.pause()

# This function receives the health value from your boss script
func update_health_display(current_health: int) -> void:
	var health = clampi(current_health, 0, 15)
	if animated_sprite:
		animated_sprite.frame = 15 - health
