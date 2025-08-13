extends Control


signal exit_submenu;


func _ready() -> void:
	$GridContainer/Stage1.pressed.connect(GameState.load_stage.bind("tomato fields"))
	$GridContainer/Stage2.pressed.connect(GameState.load_stage.bind("city"))
	$GridContainer/Stage3.pressed.connect(GameState.load_stage.bind("city2"))
	$GridContainer/Stage4.pressed.connect(GameState.load_stage.bind("backstage"))
	$Back.pressed.connect(exit_submenu.emit);
