extends Node


const GENERATOR_SAMPLE_DELTA : float = 100.0;

# this script should handle background switcheroos and terrain generation based on the players coordinate
# for terrain generation, I think about doing it in chunks using a smooth-ish height(x) function and a samplerate
@onready var ui_layer = $UILayer;
@onready var hud = $UILayer/HUD;
@onready var player = $Player;
var gameover_scene = preload("res://scenes/gameover.tscn");
var is_gameover : bool = false;


func _ready() -> void:
	# since hud displays player properties, such as speed and position, we need to pass a reference
	hud.player = player;
	generate_terrain(TerrainGenerator.new(), 1000, Vector2(8e-3, 1e3));


func _process(delta: float) -> void:
	if GameState.juice <= 0.0 and player.is_stationary() and not is_gameover:
		is_gameover = true;
		# gameover screen -> shop screen -> restart
		ui_layer.add_child(gameover_scene.instantiate());


func generate_terrain(
		generator : TerrainGenerator,
		sample_count: int,
		scale_coords: Vector2,
	) -> void:
		generator.scale = scale_coords;
		var left_appendix := -100.0;
		generator.prepare_coordinates(sample_count, left_appendix);
		var points := generator.sample();
		var ss2d_shape : SS2D_Shape = $Terrain/SS2D_Shape;
		
		ss2d_shape.clear_points();
		ss2d_shape.add_points(points);
		
		# point at 0 should be placed immediately below the player
		var first_point = points[roundi(-left_appendix / GENERATOR_SAMPLE_DELTA)];
		ss2d_shape.position = player.position + Vector2(0, 100) - first_point;
		
		# two additional points needed to draw the terrain
		var bottom_left = Vector2(points[0].x, 1000.0);
		var bottom_right = Vector2(points[points.size() - 1].x, 1000.0);
		ss2d_shape.add_point(bottom_right);
		ss2d_shape.add_point(bottom_left);
		ss2d_shape.close_shape(points.size() - 1);
		
		ss2d_shape.get_point_array().begin_update();


class TerrainGenerator:
	var generator_params: PackedVector2Array;
	var coordinates: PackedFloat32Array;
	var scale : Vector2;
	
	
	func prepare_coordinates(sample_count: int, offset: float) -> void:
		coordinates.resize(sample_count);
		for i in sample_count:
			coordinates[i] = offset + GENERATOR_SAMPLE_DELTA * i;
	
	
	# simple discrete fourier transform thing + exp*cos
	func generator_function(x: float) -> float:
		var x_scaled = x * scale.x;
		var result : float = exp(-x_scaled) * cos(x_scaled);
		for param_vec in generator_params:
			result += param_vec.x * sin(param_vec.y * x_scaled)
		
		return -result * scale.y;
	
	
	func sample() -> PackedVector2Array:
		var result = PackedVector2Array();
		var size : int = coordinates.size();
		
		result.resize(size);
		for i in size:
			var x = coordinates[i];
			result[i] = Vector2(x, generator_function(x));
		
		return result;
