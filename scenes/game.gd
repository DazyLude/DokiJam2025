extends Node


# this script should handle background switcheroos and terrain generation based on the players coordinate
# for terrain generation, I think about doing it in chunks using a smooth-ish height(x) function and a samplerate
@onready var ui_layer = $UILayer;
@onready var hud = $UILayer/HUD;
@onready var player = $Player;
var gameover_scene = preload("res://scenes/gameover.tscn");
var is_gameover : bool = false;


func _ready() -> void:
	# since hud displays player properties, such as speed and position, we need to pass a reference
	hud.player = player;


func _process(delta: float) -> void:
	if GameState.juice <= 0.0 and player.is_stationary() and not is_gameover:
		is_gameover = true;
		# gameover screen -> shop screen -> restart
		ui_layer.add_child(gameover_scene.instantiate());
