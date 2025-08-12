extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# LMG Note: Version 1 - works just fine too
#	if get_tree().paused:
#		$HUD.visible = false
#	else:
#		$HUD.visible = true

# When pressing the pause key, hide the HUD
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed(&"pause"):
		$HUD.visible = !$HUD.visible
