extends RefCounted
class_name StageData


const ITEM_PLACEMENT_RESOLUTION := 100.0; # most items are 100x100 in size


var stage_name : String;
var rng : RandomNumberGenerator;
var fresh_state : int;


# visuals
var terrain_fill : Texture2D;
var terrain_edge : Texture2D;
var checkpoint : Texture2D;
var background : Texture2D;
var background_offset : Vector2;


# sounds
var music : Sounds.ID;

# associated generators / controllers / managers
var generator : TerrainGenerator;
var ceiling_generator : CeilingGenerator = null;
var obstacles : ObstacleManager;
var ceiling_obstacles : ObstacleManager = null;

# intermission & next stage
var intermission_name : String;
var next_stage_name : String;

# gameplay data
var stage_length : float;
var safe_zone_end : float = 3000.0;


var item_placement_properties : Dictionary[String, Dictionary] = {
	"ketchup": {
		"distance": 2500.0, # average distance between items of this type
		"placement": PickupItemData.PLACEMENT_NON_RANDOM, # non random items are placed each "distance" amount of units with a resolution defined by the terrain generator
	},
	"coin": {
		"group": "a", # this item belongs to a group
		"weight": 100.0, # weight of this item within its group
	},
	"wingbull": {
		"group": "b",
		"weight": 30.0,
	},
	"coffee": {
		"group": "b",
		"weight": 60.0,
	},
	"supps": {
		"group": "b",
		"weight": 10.0,
	},
	"groups": {
		"a": { # items from a group are placed like normal items, and the selected among (ඞ) items within a group
			"distance": 2000.0,
			"placement": PickupItemData.PLACEMENT_NORMAL,
		},
		"b": {
			"distance": 4000.0,
			"placement": PickupItemData.PLACEMENT_NORMAL
		}
	}
}


static func stage_exists(name: String) -> bool:
	return stage_variants.has(name);


static func get_stage_data_by_name(name: String, forced_seed: int = 0, forced_state: int = 0) -> StageData:
	return from_dict(stage_variants[name], forced_seed, forced_state);


static func from_dict(params: Dictionary, forced_seed: int = 0, forced_state: int = 0) -> StageData:
	var data := StageData.new();
	data.stage_name = params.get("name", "") as String;
	data.rng = RandomNumberGenerator.new();
	
	if forced_seed != 0:
		data.rng.seed = forced_seed;
	if forced_state != 0:
		data.rng.state = forced_state;
	print("initial seed and state: %s, %s" % [data.rng.seed, data.rng.state]);
	
	# visuals setup
	if params.get("terrain fill", "uid://dftdfph41cnpv") == null:
		data.terrain_fill = null;
	else:
		data.terrain_fill = load(params.get("terrain fill", "uid://dftdfph41cnpv"));
	
	data.terrain_edge = load(params.get("terrain edge", "uid://bad5ey7wkh63x"));
	data.checkpoint = load(params.get("checkpoint", "uid://d28lqabm420p3"));
	data.background = load(params.get("background", "res://assets/stages/farm/tomato_farm.png"));
	data.background_offset = params.get("background offset", Vector2(0.0, -1000.0));
	
	# terrain generator setup
	data.generator = TerrainGenerator.new();
	data.generator.scale = params.get("terrain scale", Vector2(1.0, 1.0));
	data.generator.noise_generator.seed = data.rng.randi();
	
	# obstacle manager setup
	data.obstacles = ObstacleManager.from_array(
		ObstacleManager.get_obstacles(data.stage_name)
	);
	data.obstacles.rng = data.rng;
	
	# ceiling setup
	if params.get("has ceiling", false):
		data.ceiling_generator = CeilingGenerator.new();
		data.ceiling_generator.floor_generator = data.generator;
		data.generator.noise_generator.seed = data.rng.randi();
		
		data.ceiling_obstacles = ObstacleManager.from_array(
			ObstacleManager.get_obstacles(data.stage_name + "_ceiling")
		);
		data.ceiling_obstacles.rng = data.rng;
	
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


func generate_items(items_data: Dictionary, from: float, to: float) -> Dictionary[String, PackedFloat32Array]:
	var result : Dictionary[String, PackedFloat32Array] = {};
	
	var items : Array[GroupData] = [];
	var grouped_items := {};
	
	for item in items_data:
		var item_data = items_data[item];
		match item:
			"groups":
				for group in item_data:
					items.push_back(GroupData.from_dict(item_data[group], group));
			_ when item_data.has("group"):
				grouped_items.get_or_add(item_data["group"], PackedStringArray()).push_back(item);
				grouped_items.get_or_add(item_data["group"] + "_w", PackedFloat32Array())\
					.push_back(item_data.get("weight", 100.0));
			_:
				items.push_back(GroupData.from_dict(item_data, item));
	
	var occupied_coords := PackedFloat32Array();
	
	for group_data in items:
		var distance = group_data.placement_distance;
		var from_i = floori(from / distance);
		var to_i = floori(to / distance);
		var items_count = to_i - from_i;
		for i in items_count:
			var item_placement = distance * (from_i + i + 1);
			
			match group_data.placement_type:
				PickupItemData.PLACEMENT_NON_RANDOM:
					pass;
				PickupItemData.PLACEMENT_NORMAL:
					var variation = rng.randfn(0.0, distance / 4.0);
					variation = clampf(variation, distance / -3.0, distance / 3.0);
					item_placement += variation;
			
			item_placement = roundi(item_placement / ITEM_PLACEMENT_RESOLUTION) * ITEM_PLACEMENT_RESOLUTION;
			
			var try_i : int = 0;
			var variation = 0.0;
			var max_loops = 1000;
			while occupied_coords.has(item_placement + variation) and max_loops > 0:
				max_loops -= 1
				variation = ITEM_PLACEMENT_RESOLUTION * (try_i / 2 + 1) * (try_i % 2 - 0.5) * 2.0;
				try_i += 1
			
			item_placement += variation;
			
			occupied_coords.push_back(item_placement);
			
			var item : String = group_data.item;
			if item in grouped_items:
				var idx = rng.rand_weighted(grouped_items[item + "_w"])
				item = grouped_items[item][idx];
			
			result.get_or_add(item, PackedFloat32Array()).push_back(item_placement);
	
	return result;


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
		"music": Sounds.ID.MUSIC_CITY,
	},
	"city2": {
		"name": "city2",
		"terrain fill": "res://assets/stages/city/conrete_tile.png",
		"terrain edge": "res://assets/stages/city/concrete_edge.png",
		"background": "res://assets/stages/city/city_street.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "tomato field massacre",
		"next stage": "backstage",
		"music": Sounds.ID.MUSIC_METAL,
	},
	"backstage": {
		"name": "backstage",
		"terrain fill": "res://assets/stages/backstage/stagefloor_tile.png",
		"terrain edge": "res://assets/stages/backstage/stagefloor_edge.png",
		"background": "res://assets/stages/backstage/backstage.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "tomato field massacre",
		"next stage": "frontstage",
		"music": Sounds.ID.MUSIC_GOOFY_AAH,
		"has ceiling": true,
	},
	"stage": {
		"name": "stage",
		"terrain fill": "res://assets/stages/backstage/stagefloor_tile.png",
		"terrain edge": "res://assets/stages/backstage/stagefloor_edge.png",
		"background": "res://assets/stages/stage/stage.png",
		"background offset": Vector2(0.0, -1150.0),
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "end",
		"music": Sounds.ID.MUSIC_GOOFY_AAH,
		"has ceiling": true,
	}
}


class GroupData:
	var item: String;
	var placement_type : int;
	var placement_distance : float;
	
	static func from_dict(dict: Dictionary, name: String) -> GroupData:
		var data = GroupData.new();
		data.item = name;
		data.placement_type = dict.get("placement", PickupItemData.PLACEMENT_NON_RANDOM);
		data.placement_distance = dict.get("distance", 2000.0);
		return data;
