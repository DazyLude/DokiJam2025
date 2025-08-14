extends Control

signal exit_submenu;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CreditsPanel/CreditsContainer/Back.pressed.connect(exit_submenu.emit);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
