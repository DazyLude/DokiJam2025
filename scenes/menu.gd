extends Control


@onready var start_btn := $Default/MainMenu/StartButton;


func _ready() -> void:
	show_main();
	Sounds.play_looped(Sounds.ID.MUSIC_ESCAPE_FROM_TARKOV);
	
	$Default/DiaTestButton.pressed.connect(test_dialogue);
	$Default/ComicTestButton.pressed.connect(test_intro);
	
	$Default/TomatoSelect.pressed.connect(
		func():
			GameState.selected_skinsuit = Upgrade.SKINSUIT_TOMATO;
			update_skinsuit();
	);
	$Default/CrowkiSelect.pressed.connect(
		func():
			GameState.selected_skinsuit = Upgrade.SKINSUIT_CROWKI;
			update_skinsuit();
	);
	$StageSelect2.exit_submenu.connect(show_main);
	$CreditsNode.exit_submenu.connect(show_main);
	update_skinsuit();


func show_main() -> void:
	$Default.show();
	$StageSelect2.hide();
	$CreditsNode.hide();


func update_skinsuit() -> void:
	$Default/TextureRect.prepare_sprite(GameState.selected_skinsuit);
	$Default/TextureRect.display_emotion(0);


func _process(delta: float) -> void:
	const rot_speed = 0.05;
	
	var tomatocenter : Vector2 = get_viewport().size / 2;
	var offset : Vector2 = $Default/TextureRect.position - tomatocenter;
	$Default/TextureRect.position = offset.rotated(rot_speed * delta) + tomatocenter;
	$Default/TextureRect.rotation += rot_speed * delta;


func test_intro() -> void:
	await play_intermission("intro");


func test_dialogue() -> void:
	await play_intermission("tomato field massacre");


func play_intermission(intermission: String) -> void:
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission(intermission);
	
	# action
	add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	
	# cleanup
	intermission_player.queue_free();


func _on_start_pressed() -> void:
	get_viewport().gui_release_focus();
	await play_intermission("intro");
	GameState.load_stage("tomato fields");


func _on_stage_pressed() -> void:
	$Default.hide();
	$StageSelect2.show();


func _on_credits_pressed() -> void:
	$Default.hide();
	$CreditsNode.show();
