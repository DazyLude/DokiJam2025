extends Control


@onready var start_btn := $Start;


func _ready() -> void:
	Sounds.play_looped(Sounds.ID.MUSIC_ESCAPE_FROM_TARKOV);
	
	start_btn.pressed.connect(start_game);
	$DiaTestButton.pressed.connect(test_dialogue);
	$ComicTestButton.pressed.connect(test_intro);
	
	$TomatoSelect.pressed.connect(
		func():
			GameState.selected_skinsuit = Upgrade.SKINSUIT_TOMATO;
			update_skinsuit();
	);
	$CrowkiSelect.pressed.connect(
		func():
			GameState.selected_skinsuit = Upgrade.SKINSUIT_CROWKI;
			update_skinsuit();
	);
	
	update_skinsuit();


func update_skinsuit() -> void:
	$TextureRect.prepare_sprite(GameState.selected_skinsuit);
	$TextureRect.display_emotion(0);


func _process(delta: float) -> void:
	const rot_speed = 0.05;
	
	var tomatocenter : Vector2 = get_viewport().size / 2;
	var offset : Vector2 = $TextureRect.position - tomatocenter;
	$TextureRect.position = offset.rotated(rot_speed * delta) + tomatocenter;
	$TextureRect.rotation += rot_speed * delta;


func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn");


func test_intro() -> void:
	get_viewport().gui_release_focus();
	
	# setup
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission("intro");
	
	# action
	add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	
	# cleanup
	remove_child(intermission_player);
	intermission_player.queue_free();


func test_dialogue() -> void:
	get_viewport().gui_release_focus();
	
	# setup
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission("tomato field massacre");
	
	# action
	add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	
	# cleanup
	remove_child(intermission_player);
	intermission_player.queue_free();
