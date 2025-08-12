extends Control


func _ready() -> void:
	pass

## restart from the begining of the current stage
func _on_try_again_pressed() -> void:
	GameState.restart();
	get_tree().change_scene_to_file("res://scenes/game.tscn");

## go to the upgrades shop, then restart
func _on_upgrades_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_screen.tscn");

## generate a new stage layout, then restart
func _on_reset_pressed() -> void:
	GameState.load_stage(GameState.current_stage.stage_name)
