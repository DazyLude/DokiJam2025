extends Node


# this class is an Autoload, a singleton pattern implementation for godot
# it holds data related to the current game session


# Options file
var options_file: String = "user://options.ini"


# RNG
var rng := RandomNumberGenerator.new();


# stamina
const JUICE_DEFAULT_VALUE : float = 10.0; # in seconds of juice usage time
var juice := JUICE_DEFAULT_VALUE;
var juice_cap := JUICE_DEFAULT_VALUE;


# currency
var dokicoins : float = 0.0;


# upgrades
var upgrades := Upgrade.new();
var selected_skinsuit : int = Upgrade.SKINSUIT_TOMATO;


# player
var player : Player;


# stage management
var current_stage := StageData.get_stage_data_by_name("tomato fields");


func _init() -> void:
	load_options_file()


func restart() -> void:
	juice = juice_cap + 10.0 * upgrades.get_upgrade_level(Upgrade.KETCHUP_TANK);
	current_stage.rng.state = current_stage.fresh_state;


func load_stage(stage: String) -> void:
	restart();
	upgrades.check_for_unlocks(stage);
	current_stage = StageData.get_stage_data_by_name(stage);
	get_tree().change_scene_to_file("res://scenes/game.tscn");


func load_options_file() -> void:
	var save_file: Object
	var json: Object
	var save_data: Dictionary
	var json_string: String
	if FileAccess.file_exists(options_file):
		save_file = FileAccess.open(options_file, FileAccess.READ)
		json = JSON.new()
		json_string = save_file.get_line()
		var error = json.parse(json_string)
		if error == OK:
			save_data = json.data
			load_bus_volume("music", save_data["music"])
			load_bus_volume("sfx", save_data["sfx"])
		else:
			print("ERROR - Could not parse options file")
	else:
		print("No options file detected")
		# LMG Note: idea to create an options file on boot up
		#save_file = FileAccess.open(options_file, FileAccess.WRITE)
		#save_data = {
		#	"music": 30,
		#	"sfx": 100
		#}
		#var json_string = JSON.stringify(save_data)
		#save_file.store_string(json_string)

func load_bus_volume(bus_name: String, volume_value) -> void:
	var volume = snapped(volume_value/100, 0.01)
	var bus = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(bus, volume)
