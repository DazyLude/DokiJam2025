extends RefCounted
class_name StageData


var stage_name : String;
var rng : RandomNumberGenerator;
var fresh_state : int;


# visuals
var terrain_fill : Texture2D;
var terrain_edge : Texture2D;
var checkpoint : Texture2D;
var background : Texture2D;


# sounds
var music : Sounds.ID;

# associated generators / controllers / managers
var generator : TerrainGenerator;
var obstacles : ObstacleManager;

# intermission & next stage
var intermission_name : String;
var next_stage_name : String;

# gameplay data
var stage_length : float;


static func get_stage_data_by_name(name: String) -> StageData:
	return from_dict(stage_variants[name]);


static func from_dict(params: Dictionary) -> StageData:
	var data := StageData.new();
	data.stage_name = params.get("name", "") as String;
	data.rng = RandomNumberGenerator.new();
	
	# visuals setup
	data.terrain_fill = load(params.get("terrain fill", "uid://dftdfph41cnpv"));
	data.terrain_edge = load(params.get("terrain edge", "uid://bad5ey7wkh63x"));
	data.checkpoint = load(params.get("checkpoint", "uid://d28lqabm420p3"));
	data.background = load(params.get("background", "res://assets/stages/farm/tomato_farm.png"));
	
	# terrain generator setup
	data.generator = TerrainGenerator.new();
	data.generator.scale = params.get("terrain scale", Vector2(1.0, 1.0));
	data.generator.noise_generator.seed = data.rng.randi();
	
	# obstacle manager setup
	data.obstacles = ObstacleManager.from_array(
		ObstacleManager.get_obstacles(data.stage_name)
	);
	data.obstacles.rng = data.rng;
	
	# other parameters
	data.stage_length = params.get("stage length", 3e4);
	data.next_stage_name = params.get("next stage", "tomato fields");
	data.intermission_name = params.get("intermission name", "tomato fields massacre");
	
	# sounds setup
	data.music = params.get("music", Sounds.ID.MUSIC_ESCAPE_FROM_TARKOV);
	
	data.fresh_state = data.rng.state;
	return data;


func restore_state() -> void:
	rng.state = fresh_state;


# it is possible to setup stages in JSON format this way
static var stage_variants: Dictionary[String, Dictionary] = {
	"tomato fields": {
		"name": "tomato fields",
		"terrain fill": "uid://dftdfph41cnpv", # can be a relative path to the texture, but a string nevertheless
		"terrain edge": "uid://bad5ey7wkh63x", # same as "terrain fill"
		"checkpoint": "res://assets/stages/farm/checkpoint_juicestand.png", # same as "terrain fill"
		"background": "res://assets/stages/farm/tomato_farm_clouds.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "tomato field massacre",
		"next stage": "city",
		"music": Sounds.ID.MUSIC_MELANCHOLY_TOMATO,
	},
	"city": {
		"name": "city",
		"terrain fill": "res://assets/stages/city/conrete_tile.png",
		"terrain edge": "res://assets/stages/city/concrete_edge.png",
		"background": "res://assets/stages/city/shopping_street.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "tomato field massacre",
		"next stage": "city2",
		"music": Sounds.ID.MUSIC_MELANCHOLY_TOMATO,
	},
	"city in ruins": {
		"name": "city2",
		"terrain fill": "res://assets/stages/city/conrete_tile.png",
		"terrain edge": "res://assets/stages/city/concrete_edge.png",
		"background": "res://assets/stages/city/city_street.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "tomato field massacre",
		"next stage": "tomato fields",
		"music": Sounds.ID.MUSIC_MELANCHOLY_TOMATO,
	},
}
