extends Control


signal exit_submenu;

var seed_string : String = "";


func _ready() -> void:
	#$StageContainer/Stage1.pressed.connect(load_stage.bind("tomato fields"))
	#$StageContainer/Stage2.pressed.connect(load_stage.bind("city"))
	#$StageContainer/Stage3.pressed.connect(load_stage.bind("city2"))
	#$StageContainer/Stage4.pressed.connect(load_stage.bind("backstage"))
	#$StageContainer/Stage5.pressed.connect(load_stage.bind("stage"))
	$StageContainer/Stage1.pressed.connect(load_stage.bind(0))
	$StageContainer/Stage2.pressed.connect(load_stage.bind(1))
	$StageContainer/Stage3.pressed.connect(load_stage.bind(2))
	$StageContainer/Stage4.pressed.connect(load_stage.bind(3))
	$StageContainer/Stage5.pressed.connect(load_stage.bind(4))
	
	$LineEdit.text_changed.connect(func(s): seed_string = s);
	$LineEdit.hide();
	$PlayIntermissionInstead.hide();
	$Back.pressed.connect(exit_submenu.emit);


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"show_debug_info"):
		$LineEdit.visible = not $LineEdit.visible;
		$PlayIntermissionInstead.visible = $LineEdit.visible;


#func load_stage(which: String) -> void:
func load_stage(stage_index: int) -> void:
	var stages = ["tomato fields", "city", "city2", "backstage", "stage"];
	var intermissions = ["vn1-2", "vn2-3", "vn3-4", "vn4-5", "outro"];
	var selected_stage = stages[stage_index];
	
	if $PlayIntermissionInstead.button_pressed:
		get_viewport().gui_release_focus();
		await play_intermission(intermissions[stage_index]);
		return;
	
	for index in range(stage_index):
		GameState.upgrades.check_for_unlocks(stages[index])
	
	if seed_string.is_valid_int():
		GameState.load_stage(selected_stage, seed_string.to_int())
	else:
		GameState.load_stage(selected_stage)


func play_intermission(intermission: String) -> void:
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission(intermission);
	
	# action
	add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	
	# cleanup
	intermission_player.queue_free();
