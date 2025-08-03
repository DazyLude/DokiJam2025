extends Control


func _ready() -> void:
	get_tree().paused = true;
	
	$Restart.pressed.connect(on_restart)
	$Upgrades.pressed.connect(on_enter_shop)


func on_restart() -> void:
	get_tree().paused = false;
	
	GameState.restart();
	get_tree().change_scene_to_file("res://scenes/game.tscn");


func on_enter_shop() -> void:
	$Upgrades.text = "404 shop not found"
