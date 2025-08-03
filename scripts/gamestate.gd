extends Node


# this class is an Autoload, a singleton pattern implementation for godot
# it holds data related to the current game session

const JUICE_DEFAULT_VALUE := 100.0;
var juice := JUICE_DEFAULT_VALUE;



func restart() -> void:
	juice = JUICE_DEFAULT_VALUE;
