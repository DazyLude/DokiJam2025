extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# pause here
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_node("CoinContainer/CoinCount").text = "x%d" % GameState.dokicoins


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		# unpause here or in another place the menu is exited
		get_viewport().set_input_as_handled();
		queue_free();
