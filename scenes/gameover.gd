extends Control


func _ready() -> void:
	$Restart.pressed.connect(on_restart)
	$Upgrades.pressed.connect(on_enter_shop)


func on_restart() -> void:
	GameState.restart();
	get_tree().change_scene_to_file("res://scenes/game.tscn");


func on_enter_shop() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn");
