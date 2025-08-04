extends Node


# this class is an Autoload, a singleton pattern implementation for godot
# it holds data related to the current game session


# stamina
const JUICE_DEFAULT_VALUE : float = 10.0; # in seconds of juice usage time
var juice := JUICE_DEFAULT_VALUE;


# currency
var dokicoins : float = 0.0;


# stage management
var current_stage := StageData.get_stage_data_by_name("tomato fields");


func restart() -> void:
	juice = JUICE_DEFAULT_VALUE;
