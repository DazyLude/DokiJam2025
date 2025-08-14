extends Node
class_name Game


const COLLECTIBLE_HOVER_OFFSET := -100.0;
const LEFT_APPENDIX := -1000.0;
const LOWER_BOUND := 5000.0;

# this script should handle background switcheroos and terrain generation based on the players coordinate
# for terrain generation, I think about doing it in chunks using a smooth-ish height(x) function and a samplerate
@onready var ui_layer = $UILayer;
@onready var hud = $UILayer/HUD;
@onready var player : Player = $Player;
@onready var ss2d_shape : SS2D_Shape = $Terrain/SS2D_Shape;
@onready var ceiling_shape : SS2D_Shape = $Terrain/SS2D_Shape2;

@onready var back_decor := $DecorationsBack;
@onready var front_decor := $DecorationsFront;
@onready var collectibles := $Collectibles;


#var upgrade_scene = preload("res://scenes/upgrade_screen.tscn");
var gameover_scene = preload("res://scenes/gameover.tscn");
var gameover_scene_instance : Node = null;
var is_gameover : bool = false;

var player_tween : Tween;


func _ready() -> void:
	# since hud displays player properties, such as speed and position, we need to pass a reference
	Sounds.play_looped(GameState.current_stage.music);
	hud.player = player;
	
	var start = Time.get_ticks_msec();
	load_stage();
	var end = Time.get_ticks_msec();
	print("loaded stage in %s msec" % (end - start));
	
	player.apply_player_stats(PlayerStats.get_latest());
	$UILayer/PauseButton.pressed.connect(pause);


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		pause();


func _process(delta: float) -> void:
	if is_gameover:
		return;
	
	$UILayer/PauseButton.show();
	
	if GameState.juice <= 0.0 and player.is_stationary():
		if gameover_scene_instance == null:
			gameover_scene_instance = gameover_scene.instantiate()
			ui_layer.add_child(gameover_scene_instance);
		else:
			gameover_scene_instance.show();
	
	if GameState.juice > 0.0 and gameover_scene_instance != null:
		gameover_scene_instance.hide();
	
	if player.position.y >= LOWER_BOUND and player.process_mode != ProcessMode.PROCESS_MODE_DISABLED:
		move_player_to(0.0);
	
	if player.position.x >= GameState.current_stage.stage_length:
		is_gameover = true;
		player.stop();
		# TODO stop the player, drop them to the ground and make them enjoy tomato juice
		# TODO stage cleared screen -> intermission scene -> new stage
		await play_intermission(GameState.current_stage.intermission_name);
		
		GameState.upgrades.check_for_unlocks(GameState.current_stage.next_stage_name);
		var shop_scene = preload("res://scenes/upgrade_screen.tscn").instantiate();
		shop_scene.on_continue_override = GameState.load_stage;
		$UILayer.add_child(shop_scene);


func pause() -> void:
	$UILayer/PauseButton.hide();
	var pause_screen := preload("res://scenes/pause_menu.tscn").instantiate();
	$UILayer.add_child(pause_screen);
	get_viewport().set_input_as_handled();


func load_stage() -> void:
	var stage = GameState.current_stage;
	
	setup_terrain_visuals(stage);
	
	generate_terrain();
	if stage.ceiling_generator != null:
		generate_ceiling();
	
	spawn_checkpoint();
	spawn_obstacles();
	if stage.ceiling_generator != null:
		spawn_ceiling_obstacles();
	
	spawn_collectibles();
	place_player();


func place_node_at(node: Node2D, x: float, y_offset: float = 0.0) -> void:
	node.position = Vector2(
		x,
		GameState.current_stage.generator.get_height(x) + y_offset
	);


func place_node_at_ceiling(node: Node2D, x: float, y_offset: float = 0.0) -> void:
	node.position = Vector2(
		x,
		GameState.current_stage.ceiling_generator.get_height(x) + y_offset
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


func spawn_ceiling_obstacles() -> void:
	var obstacle_start = GameState.current_stage.safe_zone_end;
	var obstacle_end = GameState.current_stage.stage_length;
	
	for x in GameState.current_stage.ceiling_generator.get_obstacle_coords(obstacle_start, obstacle_end):
		var obstacle = GameState.current_stage.ceiling_obstacles.get_random_obstacle();
		place_node_at_ceiling(obstacle, x);
		$DecorationsBack.add_child(obstacle);


func spawn_collectibles() -> void:
	var stage := GameState.current_stage;
	
	var item_coords := stage.generate_items(stage.item_placement_properties, stage.safe_zone_end, stage.stage_length);
	
	for item in item_coords:
		for coord in item_coords[item]:
			place_collectible_at(coord, PickupItemData.get_by_name(item));


func place_player() -> void:
	var generator = GameState.current_stage.generator;
	player.position = Vector2(0.0, generator.get_height(0) - 200.0);


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
	
	ceiling_shape.shape_material.fill_textures[0] = stage.terrain_fill;
	ceiling_shape.shape_material.get_all_edge_materials()[0].textures[0] = stage.terrain_edge;
	
	$ParallaxBackground/BackdropParallax/BackdropSprite.texture = stage.background;
	$ParallaxBackground/BackdropParallax/BackdropSprite.position = stage.background_offset;
	
	$ParallaxBackground/SkyboxParallax/SkyboxSprite.texture = stage.skybox;


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


func generate_ceiling() -> void:
	var stage := GameState.current_stage;
	var generator = GameState.current_stage.ceiling_generator;
	
	var appendix_sample_count := -roundi(LEFT_APPENDIX / TerrainGenerator.SAMPLE_DELTA);
	
	var right_appendix := 1000.0;
	appendix_sample_count += roundi(right_appendix / TerrainGenerator.SAMPLE_DELTA);
	
	var sample_count = roundi(stage.stage_length / TerrainGenerator.SAMPLE_DELTA);
	generator.prepare_coordinates(sample_count + appendix_sample_count, LEFT_APPENDIX);
	var points := generator.sample();
	
	ceiling_shape.clear_points();
	ceiling_shape.add_points(points);
	
	# two additional points needed to enclose the shape
	var bottom_right = Vector2(points[points.size() - 1].x, points[points.size() - 1].y - 1000.0);
	var bottom_left = Vector2(points[0].x, points[0].y - 1000.0);
	ceiling_shape.add_point(bottom_right);
	ceiling_shape.add_point(bottom_left);
	ceiling_shape.close_shape(points.size() - 1);
	
	ceiling_shape.get_point_array().begin_update();


func play_intermission(intermission: String) -> void:
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission(intermission);
	
	# action
	$UILayer.add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	
	# cleanup
	intermission_player.queue_free();


func move_player_to(where: float) -> void:
	# disable player processing to move them withougt worrying about forces
	player.process_mode = Node.PROCESS_MODE_DISABLED;
	# set the stop flag, so that they don't fly away when released
	player.stop();
	player.set_emotion(2);
	player.z_index = 1;
	
	var destination = Vector2(where, GameState.current_stage.generator.get_height(where) - 200.0)
	
	if player_tween != null:
		player_tween.kill();
	
	player_tween = create_tween();
	
	var the_hand : Sprite2D = preload("res://scenes/gameplay_elements/the_gods_hand.tscn").instantiate();
	the_hand.position = player.position + Vector2(0.0, -900.0);
	$DecorationsFront.add_child(the_hand);
	
	player_tween.tween_property(the_hand, ^"position", player.position, 2.0);
	
	player_tween.tween_property(the_hand, ^"position", destination, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
	player_tween.parallel().tween_property(player, ^"position", destination, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
	
	player_tween.tween_property(the_hand, ^"position", destination + Vector2(0.0, -900.0), 2.0);
	
	await player_tween.finished;
	
	player.z_index = 0;
	
	the_hand.queue_free();
	player.process_mode = Node.PROCESS_MODE_INHERIT;
