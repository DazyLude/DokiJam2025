extends Control


signal exit_submenu;

var seed_string : String = "";


func _ready() -> void:
	$GridContainer/Stage1.pressed.connect(load_stage.bind("tomato fields"))
	$GridContainer/Stage2.pressed.connect(load_stage.bind("city"))
	$GridContainer/Stage3.pressed.connect(load_stage.bind("city2"))
	$GridContainer/Stage4.pressed.connect(load_stage.bind("backstage"))
	$GridContainer/Stage5.pressed.connect(load_stage.bind("stage"))
	
	$LineEdit.text_changed.connect(func(s): seed_string = s);
	$LineEdit.hide();
	$Back.pressed.connect(exit_submenu.emit);


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"show_debug_info"):
		$LineEdit.visible = not $LineEdit.visible;


func load_stage(which: String) -> void:
	if seed_string.is_valid_int():
		GameState.load_stage(which, seed_string.to_int());
	else:
		GameState.load_stage(which);
