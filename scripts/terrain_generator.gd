class_name TerrainGenerator extends RefCounted


const SAMPLE_DELTA := 100.0;
const CHAIR_HEIGHT := 10.0;
const CHAIR_HEIGHT_CBRT := pow(CHAIR_HEIGHT, 1.0/3.0);


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


func generator_function(x: float) -> float:
	var x_scaled = x * scale.x;
	var result : float = 0;
	
	if x_scaled < CHAIR_HEIGHT_CBRT:
		result += CHAIR_HEIGHT - pow(x_scaled, 3.0);
	else:
		result += noise_generator.get_noise_1d(x) + 1;
	
	return -result * scale.y;


func sample() -> PackedVector2Array:
	var result = PackedVector2Array();
	var size : int = coordinates.size();
	
	result.resize(size);
	for i in size:
		var x = coordinates[i];
		result[i] = Vector2(x, generator_function(x));
	
	return result;
