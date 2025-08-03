extends Node


# this script should handle background switcheroos and terrain generation based on the players coordinate
# for terrain generation, I think about doing it in chunks using a smooth-ish height(x) function and a samplerate


# yes, I've attached HUD to the skybox and set it's z index to 1.
# yes, this is stupid
@onready var hud = $UILayer/HUD;
@onready var player = $Player;


func _ready() -> void:
	hud.player = player;
