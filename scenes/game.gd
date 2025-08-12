extends Node


const COLLECTIBLE_HOVER_OFFSET := -100.0;
const LEFT_APPENDIX := -1000.0;

# this script should handle background switcheroos and terrain generation based on the players coordinate
# for terrain generation, I think about doing it in chunks using a smooth-ish height(x) function and a samplerate
@onready var ui_layer = $UILayer;
@onready var hud = $UILayer/HUD;
@onready var player : Player = $Player;
@onready var ss2d_shape : SS2D_Shape = $Terrain/SS2D_Shape;
@onready var back_decor := $DecorationsBack;
@onready var front_decor := $DecorationsFront;
@onready var collectibles := $Collectibles;


#var upgrade_scene = preload("res://scenes/upgrade_screen.tscn");
var gameover_scene = preload("res://scenes/gameover.tscn");
var is_gameover : bool = false;


func _ready() -> void:
	# since hud displays player properties, such as speed and position, we need to pass a reference
	Sounds.play_looped(GameState.current_stage.music);
	hud.player = player;
	load_stage();
	player.apply_player_stats(PlayerStats.get_latest());


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		var pause_screen := preload("res://scenes/pause_menu.tscn").instantiate();
		$UILayer.add_child(pause_screen);
		get_viewport().set_input_as_handled();


func _process(delta: float) -> void:
	if is_gameover:
		return;
	
	if GameState.juice <= 0.0 and player.is_stationary():
		is_gameover = true;
		ui_layer.add_child(gameover_scene.instantiate());
	
	if player.position.x >= GameState.current_stage.stage_length:
		is_gameover = true;
		# TODO stop the player, drop them to the ground and make them enjoy tomato juice
		# TODO stage cleared screen -> intermission scene -> new stage
		await play_intermission(GameState.current_stage.intermission_name);
		GameState.load_stage(GameState.current_stage.next_stage_name);


func load_stage() -> void:
	var stage = GameState.current_stage;
	
	setup_terrain_visuals(stage);
	generate_terrain();
	spawn_checkpoint();
	spawn_obstacles();
	spawn_collectibles();
	place_player();


func place_node_at(node: Node2D, x: float, y_offset: float = 0.0) -> void:
	node.position = Vector2(
		x,
		GameState.current_stage.generator.get_height(x) + y_offset
	);


func place_collectible_at(x: float, collectible_data: PickupItemData) -> PickupItem:
	var collectible := preload("res://scenes/gameplay_elements/pickup_item.tscn").instantiate();
	place_node_at(collectible, x, COLLECTIBLE_HOVER_OFFSET);
	collectible.data = collectible_data;
	collectibles.add_child(collectible);
	return collectible;


func spawn_obstacles() -> void:
	var sign = GameState.current_stage.obstacles.get_specific_obstacle("sign");
	place_node_at(sign, LEFT_APPENDIX);
	$DecorationsBack.add_child(sign);
	
	var obstacle_start = GameState.current_stage.safe_zone_end;
	var obstacle_end = GameState.current_stage.stage_length;
	
	for x in GameState.current_stage.generator.get_obstacle_coords(obstacle_start, obstacle_end):
		var obstacle = GameState.current_stage.obstacles.get_random_obstacle();
		place_node_at(obstacle, x);
		$DecorationsBack.add_child(obstacle);


func spawn_collectibles() -> void:
	var stage := GameState.current_stage;
	
	for i in range(1, 10):
		var x = stage.stage_length * i / 11.0;
		place_collectible_at(x, PickupItemData.get_by_name("ketchup"));
	
	for i in range(1, 6):
		var x = stage.stage_length * i / 7.0;
		place_collectible_at(x, PickupItemData.get_by_name("coin"));


func place_player() -> void:
	var generator = GameState.current_stage.generator;
	
	player.position = Vector2(0.0, generator.get_height(0) - 200.0);
	# LMG Note: This causes a crash v
	#$Parallax2D/Backdrop.motion_offset = $Parallax2D/Backdrop/Sprite2D.texture.get_size() * Vector2(-0.5, -0.25);


# checkpoint is just a visual that is placed at the end of a level
# game checks for level completion based on distance traveled
func spawn_checkpoint() -> void:
	var stage := GameState.current_stage;
	
	var checkpoint := Sprite2D.new();
	checkpoint.texture = stage.checkpoint;
	checkpoint.position = Vector2(
		stage.stage_length,
		stage.generator.get_height(stage.stage_length)
	);
	checkpoint.offset = Vector2(0.0, -checkpoint.texture.get_height() / 2.0)
	# TODO rotation
	
	back_decor.add_child(checkpoint);


func setup_terrain_visuals(stage: StageData) -> void:
	ss2d_shape.shape_material.fill_textures[0] = stage.terrain_fill;
	ss2d_shape.shape_material.get_all_edge_materials()[0].textures[0] = stage.terrain_edge;
	$ParallaxBackground/BackdropParallax/BackdropSprite.texture = stage.background;


# this method should generate initital terrain
func generate_terrain() -> void:
	var stage := GameState.current_stage;
	var generator = GameState.current_stage.generator;
	
	var appendix_sample_count := -roundi(LEFT_APPENDIX / TerrainGenerator.SAMPLE_DELTA);
	
	var right_appendix := 1000.0;
	appendix_sample_count += roundi(right_appendix / TerrainGenerator.SAMPLE_DELTA);
	
	var sample_count = roundi(stage.stage_length / TerrainGenerator.SAMPLE_DELTA);
	generator.prepare_coordinates(sample_count + appendix_sample_count, LEFT_APPENDIX);
	var points := generator.sample();
	
	ss2d_shape.clear_points();
	ss2d_shape.add_points(points);
	
	# two additional points needed to enclose the shape
	var bottom_right = Vector2(points[points.size() - 1].x, 1000.0);
	var bottom_left = Vector2(points[0].x, 1000.0);
	ss2d_shape.add_point(bottom_right);
	ss2d_shape.add_point(bottom_left);
	ss2d_shape.close_shape(points.size() - 1);
	
	ss2d_shape.get_point_array().begin_update();


func play_intermission(intermission: String) -> void:
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission(intermission);
	
	# action
	$UILayer.add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	
	# cleanup
	intermission_player.queue_free();
