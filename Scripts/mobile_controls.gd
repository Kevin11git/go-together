extends CanvasLayer
var default_window_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_window_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	get_viewport().size_changed.connect(window_resized)
	window_resized()
	await get_tree().create_timer(0.5).timeout
	window_resized()



func window_resized():
	var new_size: Vector2 = get_viewport().get_window().size
	var height_multiplier: float = new_size.y / default_window_size.y
	%RightButtonsAnchor.global_position.x = new_size.x * 1/height_multiplier
