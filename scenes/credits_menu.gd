extends Control

signal exit_submenu;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CreditsPanel/CreditsContainer/Back.pressed.connect(exit_submenu.emit);
