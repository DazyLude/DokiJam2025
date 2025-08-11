class_name TerrainGenerator extends RefCounted


const SAMPLE_DELTA := 100.0;
const CHAIR_HEIGHT := 10.0;
const CHAIR_HEIGHT_CBRT := pow(CHAIR_HEIGHT, 1.0/3.0);
const CHAIR_SMOOTH_END := 0.6;


const OBSTACLE_DENSITY = 0.05;
const OBSTACLE_SAMPLE_RATE = 50.0;
const OBSTACLE_NOISE_Y = 1000.0;


var generator_params: PackedVector2Array;
var coordinates: PackedFloat32Array;
var scale : Vector2;
var noise_generator : FastNoiseLite;


func _init() -> void:
	noise_generator = FastNoiseLite.new();
	noise_generator.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC;


func prepare_coordinates(sample_count: int, offset: float) -> void:
	coordinates.resize(sample_count);
	for i in sample_count:
		coordinates[i] = offset + SAMPLE_DELTA * i;


func get_height(x: float) -> float:
	var sample_idx = floorf(x / SAMPLE_DELTA);
	var progress = fmod(x, SAMPLE_DELTA) / SAMPLE_DELTA;
	var left := generator_function(sample_idx * SAMPLE_DELTA);
	var right := generator_function((sample_idx + 1.0) * SAMPLE_DELTA);
	
	return lerpf(left, right, progress);


func generator_function(x: float) -> float:
	var x_scaled = x * scale.x;
	var result : float = 0;
	var incremental_variation : float = 0
	
	# Previous iteration:
	if x_scaled < CHAIR_HEIGHT_CBRT * CHAIR_SMOOTH_END:
		result += CHAIR_HEIGHT - pow(x_scaled, 3.0);
	elif x_scaled < CHAIR_HEIGHT_CBRT:
		var smoothing = (1.0 - x_scaled / CHAIR_HEIGHT_CBRT) / (1.0 - CHAIR_SMOOTH_END);
		result += (CHAIR_HEIGHT - pow(x_scaled, 3.0)) * smoothing;
		
		incremental_variation = 1e-4 * x * (sin(x_scaled) + 1)
		result += (incremental_variation + noise_generator.get_noise_1d(x) + 1) * (1 - smoothing);
	else:
		# Previous iteration:
		#result += noise_generator.get_noise_1d(x) + 1;
		incremental_variation = 1e-4 * x * (sin(x_scaled) + 1)
		result += incremental_variation + noise_generator.get_noise_1d(x) + 1;
	
	return -result * scale.y;


func sample() -> PackedVector2Array:
	var result = PackedVector2Array();
	var size : int = coordinates.size();
	
	result.resize(size);
	for i in size:
		var x = coordinates[i];
		result[i] = Vector2(x, generator_function(x));
	
	return result;


func get_obstacle_coords(from: float, to: float) -> PackedFloat32Array:
	var count = floori(abs(to - from) / OBSTACLE_SAMPLE_RATE);
	
	var result = PackedFloat32Array();
	var samples = PackedFloat32Array();
	var sample_coords = PackedFloat32Array();
	var samples_sorted = PackedFloat32Array();
	
	samples.resize(count);
	sample_coords.resize(count);
	samples_sorted.resize(count);
	
	for i in count:
		var coord = from + OBSTACLE_SAMPLE_RATE * i;
		var sample = noise_generator.get_noise_2d(coord, OBSTACLE_NOISE_Y);
		samples[i] = sample;
		samples_sorted[i] = sample;
		sample_coords[i] = coord;
	
	samples_sorted.sort()
	var threshold_value = samples_sorted[floori(count * (1.0 - OBSTACLE_DENSITY))];
	
	for i in count:
		if samples[i] > threshold_value:
			result.push_back(sample_coords[i]);
	
	return result;
