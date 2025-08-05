extends RefCounted
class_name StageData

# visuals
var terrain_fill : Texture2D;
var terrain_edge : Texture2D;
var checkpoint : Texture2D;


# sounds
# TODO

# associated generators / controllers
var generator : TerrainGenerator;

# intermission
# TODO

# gameplay data
var stage_length : float;
var intermission : PackedScene;


static func get_stage_data_by_name(name: String) -> StageData:
	return from_dict(stage_variants[name]);


static func from_dict(params: Dictionary) -> StageData:
	var data := StageData.new();
	
	# visuals setup
	data.terrain_fill = load(params.get("terrain fill", "uid://dftdfph41cnpv"));
	data.terrain_edge = load(params.get("terrain edge", "uid://bad5ey7wkh63x"));
	data.checkpoint = load(params.get("checkpoint", "uid://d28lqabm420p3"));
	
	# terrain generator setup
	data.generator = TerrainGenerator.new();
	data.generator.scale = params.get("terrain scale", Vector2(1.0, 1.0));
	
	# other parameters
	data.stage_length = params.get("stage length", 3e4);
	data.intermission = load(params.get("intermission", "res://assets/stages/farm/checkpoint_juicestand.png"));
	
	return data;


# it is possible to setup stages in JSON format this way
static var stage_variants: Dictionary[String, Dictionary] = {
	"tomato fields": {
		"terrain fill": "uid://dftdfph41cnpv", # can be a relative path to the texture, but a string nevertheless
		"terrain edge": "uid://bad5ey7wkh63x", # same as "terrain fill"
		"checkpoint": "res://assets/stages/farm/checkpoint_juicestand.png", # same as "terrain fill"
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission": "uid://ct1qkka6lngc5", # can be a relative path to the scene, but a string nevertheless
	}
}
