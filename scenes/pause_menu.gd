extends Control

enum {
	#MASTER,
	MUSIC,
	SFX
}

var slider_data: Dictionary[int, Dictionary] = {
	MUSIC: {
		"node": -1,
		"bus": -1
	},
	SFX: {
		"node": -1,
		"bus": -1
	},
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# pause here
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_parent().get_node("HUD").visible = false
	get_tree().paused = true
	# Initialize slider data dictionary
	slider_data[MUSIC]["node"] = get_node("MusicContainer/VolumeSlider")
	slider_data[MUSIC]["bus"] = AudioServer.get_bus_index("music")
	slider_data[SFX]["node"] = get_node("SFXContainer/VolumeSlider")
	slider_data[SFX]["bus"] = AudioServer.get_bus_index("sfx")
	# Update Coin Display
	get_node("CoinContainer/CoinCount").text = "x%d" % GameState.dokicoins
	# Update slider data
	update_slider_value(MUSIC)
	update_slider_value(SFX)
	# Update Ketchup Meter
	get_node("KetchupMeter").value = GameState.juice/GameState.juice_cap * 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## pause button pressed
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		# unpause here or in another place the menu is exited
		close_pause_menu()

## close the pause menu and remove from memory
func close_pause_menu() -> void:
	get_tree().paused = false
	get_parent().get_node("HUD").visible = true
	get_viewport().set_input_as_handled();
	queue_free();

## update the value of the slider directly
func update_slider_value(container_id: int) -> void:
	var slider = slider_data[container_id]
	slider["node"].value = AudioServer.get_bus_volume_linear(slider["bus"]) * 100

## update the volume of a bus with a new value
func update_volume_value(container_id: int, new_value: float) -> void:
	var slider = slider_data[container_id]
	new_value = snapped(new_value/100, 0.01)
	AudioServer.set_bus_volume_linear(slider["bus"], new_value)

## saves the value of the audio bus
func save_volume_value(container_id: int) -> void:
	var save_file: Object
	var volume_data: Dictionary
	var json_string: String
	if OS.is_userfs_persistent():
		save_file = FileAccess.open(GameState.options_file, FileAccess.WRITE)
		volume_data = {
			"music": slider_data[MUSIC]["node"].value,
			"sfx": slider_data[SFX]["node"].value
		}
		json_string = JSON.stringify(volume_data)
		save_file.store_string(json_string)
		
		print("Saved volume value")

## change the music volume slider
func _on_music_volume_changed(value: float) -> void:
	update_volume_value(MUSIC, value)

## change the sfx volume slider
func _on_sfx_volume_changed(value: float) -> void:
	update_volume_value(SFX, value)

## stop moving the music volume slider
func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		save_volume_value(MUSIC)

## stop moving the sfx volume slider
func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		save_volume_value(SFX)

## closes the pause menu and resumes the game
func _on_resume_pressed() -> void:
	close_pause_menu()

## exit the game back to the main menu
func _on_menu_pressed() -> void:
	get_tree().paused = false
	#get_viewport().set_input_as_handled();
	get_tree().change_scene_to_file("res://scenes/menu.tscn");
