extends Node2D

var lifetime: float = 0.4
var time_elapsed: float = 0.0

func _ready() -> void:
	z_index = 100

func _process(delta: float) -> void:
	time_elapsed += delta
	queue_redraw()
	
	if time_elapsed >= lifetime:
		queue_free()

func _draw() -> void:
	var alpha = max(0.0, 0.5 * (1.0 - (time_elapsed / lifetime)))
	var wave_color = Color(0.05, 0.05, 0.05, alpha)
	
	# Reduced radii and offsets to make the wave smaller and tighter
	draw_arc(Vector2(0, 0), 9.0, -PI/2.2, PI/2.2, 10, wave_color, 2.0, true)
	draw_arc(Vector2(5, 0), 15.0, -PI/2.2, PI/2.2, 10, wave_color, 2.0, true)
