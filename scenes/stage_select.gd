extends Control


func _ready() -> void:
	Sounds.play_looped(Sounds.ID.MUSIC_ESCAPE_FROM_TARKOV);
	
	$GridContainer/Stage1.pressed.connect(GameState.load_stage.bind("tomato fields"))
	$GridContainer/Stage2.pressed.connect(GameState.load_stage.bind("city"))
	$GridContainer/Stage3.pressed.connect(GameState.load_stage.bind("city2"))
	$GridContainer/Stage4.pressed.connect(GameState.load_stage.bind("backstage"))
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/menu.tscn"));
