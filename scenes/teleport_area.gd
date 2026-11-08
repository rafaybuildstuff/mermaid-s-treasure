extends Area2D

@export_file("*.tscn") var level_2_scene: String

var color_rect: ColorRect

func _ready() -> void:
	# 1. Create a CanvasLayer so the fade covers the whole screen
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	# 2. Create the black overlay box
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 1) # Solid black
	color_rect.modulate = Color(1, 1, 1, 0) # Start invisible (Alpha 0)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(color_rect)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		var remaining_sharks = get_tree().get_nodes_in_group("sharks").size()
		
		if remaining_sharks == 0:
			print("All sharks cleared! Fading and teleporting...")
			start_teleport()
		else:
			print("Cannot teleport yet! Sharks left: ", remaining_sharks)

func start_teleport() -> void:
	# Smoothly fade to black using a Tween (no animation player needed!)
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.6)
	await tween.finished
	
	if level_2_scene != "":
		get_tree().change_scene_to_file(level_2_scene)
	else:
		print("ERROR: Level 2 scene file is not assigned in the Inspector!")
