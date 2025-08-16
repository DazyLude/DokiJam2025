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


# level generation related variables
var scripted_collectibles : Dictionary[String, PackedFloat32Array] = {};


#var upgrade_scene = preload("res://scenes/upgrade_screen.tscn");
var gameover_scene = preload("res://scenes/gameover.tscn");
var gameover_scene_instance : Node = null;
var is_gameover : bool = false;

var player_tween : Tween;


func _ready() -> void:
	# since hud displays player properties, such as speed and position, we need to pass a reference
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
		move_player_to(GameState.current_stage.stage_length);
		
		if GameState.current_stage.intermission_name != "":
			await play_intermission(GameState.current_stage.intermission_name);
		
		if GameState.current_stage.is_the_last:
			get_tree().change_scene_to_file("res://scenes/menu.tscn");
			return;
		
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
	scripted_collectibles.clear();
	
	Sounds.play_looped(stage.music);
	
	setup_terrain_visuals(stage);
	
	generate_terrain();
	if stage.ceiling_generator != null:
		generate_ceiling();
	
	spawn_checkpoint();
	spawn_ground_obstacles();
	if stage.ceiling_generator != null:
		spawn_ceiling_obstacles();
	
	spawn_collectibles();
	place_player();


func place_node_at(node: Node2D, x: float, generator: TerrainGenerator, y_offset: float = 0.0) -> void:
	node.position = Vector2(x, generator.get_height(x) + y_offset);


func place_collectible_at(x: float, collectible_data: PickupItemData) -> PickupItem:
	var collectible := preload("res://scenes/gameplay_elements/pickup_item.tscn").instantiate();
	place_node_at(collectible, x, GameState.current_stage.generator, COLLECTIBLE_HOVER_OFFSET);
	collectible.data = collectible_data;
	collectibles.add_child(collectible);
	return collectible;


func spawn_ground_obstacles() -> void:
	var sign = GameState.current_stage.obstacles.get_specific_obstacle("sign");
	place_node_at(sign, LEFT_APPENDIX, GameState.current_stage.generator);
	$DecorationsBack.add_child(sign);
	
	spawn_obstacles_generic(
		GameState.current_stage.generator,
		GameState.current_stage.obstacles
	);


func spawn_ceiling_obstacles() -> void:
	spawn_obstacles_generic(
		GameState.current_stage.ceiling_generator,
		GameState.current_stage.ceiling_obstacles
	);


func spawn_obstacles_generic(generator: TerrainGenerator, manager: ObstacleManager) -> void:
	var obstacle_start = GameState.current_stage.safe_zone_end;
	var obstacle_end = GameState.current_stage.stage_length;
	
	for x in generator.get_obstacle_coords(obstacle_start, obstacle_end):
		var obstacle := manager.get_random_obstacle();
		var obstacle_scene = manager.get_specific_obstacle(obstacle);
		
		var obstacle_flags = ObstacleManager.get_obstacle_flags(obstacle);
		place_node_at(obstacle_scene, x, generator);
		$DecorationsBack.add_child(obstacle_scene);
		
		process_obstacle_flags(obstacle_flags, x, generator, manager);


func process_obstacle_flags(flags: Dictionary, x: float, generator: TerrainGenerator, manager: ObstacleManager) -> void:
	for flag in flags:
		var flag_data = flags[flag];
		
		match flag:
			ObstacleManager.FLAG_SPAWN_ANOTHER:
				# flag data is a dictionary obstacle name (string): offset (vector2)
				for obstacle in flag_data:
					var offsets = flag_data[obstacle];
					for offset in offsets:
						var obstacle_scene = manager.get_specific_obstacle(obstacle);
						place_node_at(obstacle_scene, x + offset.x, generator, offset.y);
						$DecorationsBack.add_child(obstacle_scene);
			
			ObstacleManager.FLAG_SPAWN_PICKUP_ON_ME:
				# flag data is a string with a pickup name
				scripted_collectibles.get_or_add(flag_data, PackedFloat32Array()).push_back(x)


func spawn_collectibles() -> void:
	var stage := GameState.current_stage;
	
	var item_coords := stage.generate_items(
		stage.item_placement_properties,
		stage.safe_zone_end,
		stage.stage_length,
		scripted_collectibles
	);
	
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
	place_node_at(
		checkpoint,
		stage.stage_length,
		stage.generator,
		-checkpoint.texture.get_height() / 2.0 + 50.0
	);
	
	back_decor.add_child(checkpoint);


func setup_terrain_visuals(stage: StageData) -> void:
	ss2d_shape.shape_material.fill_textures[0] = stage.terrain_fill;
	ss2d_shape.shape_material.get_all_edge_materials()[0].textures[0] = stage.terrain_edge;
	
	ceiling_shape.shape_material.fill_textures[0] = stage.terrain_fill;
	ceiling_shape.shape_material.get_all_edge_materials()[0].textures[0] = stage.terrain_edge;
	
	$ParallaxBackground/BackdropParallax/BackdropSprite.texture = stage.background;
	$ParallaxBackground/BackdropParallax/BackdropSprite.position = stage.background_offset;
	$ParallaxBackground/CloudParallax.visible = stage.has_clouds;
	$ParallaxBackground/SkyboxParallax/SkyboxSprite.texture = stage.skybox;


# this method should generate initital terrain
func generate_terrain() -> void:
	generate_terrain_generic(GameState.current_stage.generator, ss2d_shape);


func generate_ceiling() -> void:
	generate_terrain_generic(GameState.current_stage.ceiling_generator, ceiling_shape, true);


func generate_terrain_generic(
		generator: TerrainGenerator,
		shape: SS2D_Shape,
		is_ceiling: bool = false
	) -> void:
		var appendix_sample_count := -roundi(LEFT_APPENDIX / generator.SAMPLE_DELTA);
		
		var right_appendix := 1000.0;
		appendix_sample_count += roundi(right_appendix / generator.SAMPLE_DELTA);
		
		var sample_count = roundi(GameState.current_stage.stage_length / generator.SAMPLE_DELTA);
		generator.prepare_coordinates(sample_count + appendix_sample_count, LEFT_APPENDIX);
		var points := generator.sample();
		
		shape.clear_points();
		shape.add_points(points);
		
		# two additional points needed to enclose the shape
		var closing_offset = Vector2(0.0, -1000.0 if is_ceiling else 1000.0);
		var bottom_right = points[points.size() - 1] + closing_offset;
		var bottom_left = points[0] + closing_offset;
		var bottom_y = min(bottom_right.y, bottom_left.y, -1000.0) if is_ceiling else max(bottom_right.y, bottom_left.y, 1000.0);
		
		bottom_right.y = bottom_y;
		bottom_left.y = bottom_y;
		
		shape.add_point(bottom_right);
		shape.add_point(bottom_left);
		shape.close_shape(points.size() - 1);
		
		shape.get_point_array().begin_update();


func play_intermission(intermission: String) -> void:
	var intermission_player = load("res://scenes/intermission_player.tscn").instantiate();
	intermission_player.set_intermission(intermission);
	
	# action
	$UILayer/HUD.hide()
	$UILayer.add_child(intermission_player);
	intermission_player.play();
	await intermission_player.finished;
	$UILayer/HUD.show()
	
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
