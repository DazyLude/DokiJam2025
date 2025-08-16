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
var background_scale : Vector2;
var skybox : Texture2D;
var has_clouds : bool;


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
var is_the_last : bool = false;

# gameplay data
var stage_length : float;
var safe_zone_end : float = 3000.0;


var item_placement_properties : Dictionary[String, Dictionary] = {
	"ketchup": {
		"distance": 2300.0, # average distance between items of this type
		"placement": PickupItemData.PLACEMENT_NON_RANDOM, # non random items are placed each "distance" amount of units with a resolution defined by the terrain generator
	},
	"coin": {
		"group": "a", # this item belongs to a group
		"weight": 100.0, # weight of this item within its group
	},
	"wingbull": {
		"group": "b",
		"weight": 20.0,
	},
	"coffee": {
		"group": "b",
		"weight": 75.0,
	},
	"supps": {
		"group": "b",
		"weight": 5.0,
	},
	"groups": {
		"a": { # items from a group are placed like normal items, and the selected among (ඞ) items within a group
			"distance": 3000.0,
			"placement": PickupItemData.PLACEMENT_NORMAL,
		},
		"b": {
			"distance": 6350.0,
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
	data.background_scale = params.get("background scale", Vector2(1.0, 1.0));
	data.skybox = load(params.get("skybox", "res://assets/stages/farm/skybox_dark.png"));
	data.has_clouds = params.get("has clouds");
	
	# terrain generator setup
	data.generator = TerrainGenerator.new();
	data.generator.scale = params.get("terrain scale", Vector2(1.0, 1.0));
	data.generator.noise_generator.seed = data.rng.randi();
	
	# obstacle manager setup
	data.obstacles = ObstacleManager.for_stage(data.stage_name);
	data.obstacles.rng = data.rng;
	
	# ceiling setup
	if params.get("has ceiling", false):
		data.ceiling_generator = CeilingGenerator.new();
		data.ceiling_generator.floor_generator = data.generator;
		data.generator.noise_generator.seed = data.rng.randi();
		
		data.ceiling_obstacles = ObstacleManager.for_stage(data.stage_name, ObstacleManager.PLACEMENT_CEILING);
		data.ceiling_obstacles.rng = data.rng;
	
	# items setup
	if params.has("items"):
		data.item_placement_properties.merge(params["items"], true);
	
	if params.has("groups"):
		data.item_placement_properties["groups"].merge(params["groups"], true);
	
	# other parameters
	data.stage_length = params.get("stage length", 3e4);
	data.next_stage_name = params.get("next stage", "tomato fields");
	data.intermission_name = params.get("intermission name", "");
	
	if params.get("is the last", false):
		data.is_the_last = true;
	
	# sounds setup
	data.music = params.get("music", Sounds.ID.MUSIC_ESCAPE_FROM_TARKOV);
	
	data.fresh_state = data.rng.state;
	return data;


func restore_state() -> void:
	rng.state = fresh_state;


func generate_items(
		items_data: Dictionary,
		from: float, to: float,
		additions: Dictionary = {}
	) -> Dictionary[String, PackedFloat32Array]:
		var result : Dictionary[String, PackedFloat32Array] = {};
		
		var items : Array[GroupData] = [];
		var grouped_items := {};
		var groups : Array[String] = [];
		
		for item in items_data:
			var item_data = items_data[item];
			match item:
				"groups":
					for group in item_data:
						items.push_back(GroupData.from_dict(item_data[group], group));
						groups.push_back(group);
				_ when item_data.has("group"):
					grouped_items.get_or_add(item_data["group"], PackedStringArray()).push_back(item);
					grouped_items.get_or_add(item_data["group"] + "_w", PackedFloat32Array())\
						.push_back(item_data.get("weight", 100.0));
				_:
					items.push_back(GroupData.from_dict(item_data, item));
		
		var occupied_coords := PackedFloat32Array();
		
		for group in groups:
			if not grouped_items.has(group):
				var group_idx = items.find_custom(func(g): return g.item == group);
				items.remove_at(group_idx);
		
		for addition in additions:
			var item = addition;
			var positions = additions[addition];
			
			for position in positions:
				occupied_coords.push_back(position);
				position = roundi(position / ITEM_PLACEMENT_RESOLUTION) * ITEM_PLACEMENT_RESOLUTION;
				result.get_or_add(item, PackedFloat32Array()).push_back(position);
		
		for group_data in items:
			var distance = group_data.placement_distance;
			var from_i = floori(from / distance);
			var to_i = floori(to / distance);
			var items_count = to_i - from_i;
			for i in items_count:
				var item_placement = distance * (from_i + i + 1);
				
				match group_data.placement_type:
					PickupItemData.PLACEMENT_NORMAL:
						var p_variation = rng.randfn(0.0, distance / 4.0);
						p_variation = clampf(p_variation, distance / -3.0, distance / 3.0);
						item_placement += p_variation;
					_, PickupItemData.PLACEMENT_NON_RANDOM:
						pass;
				
				item_placement = roundi(item_placement / ITEM_PLACEMENT_RESOLUTION) * ITEM_PLACEMENT_RESOLUTION;
				
				var try_i : int = 0;
				var variation := 0.0;
				var max_loops := 1000;
				
				while occupied_coords.has(item_placement + variation) and try_i < max_loops:
					variation = ITEM_PLACEMENT_RESOLUTION * (try_i / 2 + 1) * (try_i % 2 - 0.5) * 2.0;
					try_i += 1
				
				item_placement += variation;
				
				if item_placement >= stage_length:
					continue;
				
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
		"background": "res://assets/stages/farm/tomato_farm_nosky.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3e4, # should be a float
		"intermission name": "vn1-2",
		"next stage": "city",
		"music": Sounds.ID.MUSIC_MELANCHOLY_TOMATO,
		"has clouds": true,
	},
	"city": {
		"name": "city",
		"terrain fill": "res://assets/stages/city/conrete_tile.png",
		"terrain edge": "res://assets/stages/city/concrete_edge.png",
		"background": "res://assets/stages/city/shopping_street_nosky.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 3.5e4, # should be a float
		"intermission name": "vn2-3",
		"next stage": "city2",
		"music": Sounds.ID.MUSIC_CITY,
		"has clouds": true,
		"items": { # items are merged, and old data is overwritten by the new one in case of collisions
			"coin_x5": {
				"group": "a", # this item belongs to a group
				"weight": 10.0, # weight of this item within its group
			},
			"ketchup": {
				"distance": 2100.0,
			},
		},
		# if you feel the need to add a group, it can be done:
		#"groups": {
			#"another": {
				#"distance": 3000.0,
				#"placement": PickupItemData.PLACEMENT_NORMAL,
			#}
		#}
	},
	"city2": {
		"name": "city2",
		"terrain fill": "res://assets/stages/city/conrete_tile.png",
		"terrain edge": "res://assets/stages/city/concrete_edge.png",
		"background": "res://assets/stages/city/city_street_nosky.png",
		"skybox": "res://assets/stages/city/city_street_skybox.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 4.25e4, # should be a float
		"intermission name": "vn3-4",
		"next stage": "backstage",
		"music": Sounds.ID.MUSIC_METAL,
		"has clouds": true,
		"items": { # items are merged, and old data is overwritten by the new one in case of collisions
			"ketchup": {
				"distance": 2800.0,
			},
			"coin_x5": {
				"group": "a", # this item belongs to a group
				"weight": 20.0, # weight of this item within its group
			},
		},
	},
	"backstage": {
		"name": "backstage",
		"terrain fill": "res://assets/stages/backstage/stagefloor_tile.png",
		"terrain edge": "res://assets/stages/backstage/stagefloor_edge.png",
		"background": "res://assets/stages/backstage/backstage.png",
		"skybox": "res://assets/stages/backstage/backstage_skybox.png",
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 5e4, # should be a float
		"next stage": "stage",
		"music": Sounds.ID.MUSIC_BACKSTAGE,
		"intermission name": "vn4-5",
		"has ceiling": true,
		"has clouds": false,
		"items": { # items are merged, and old data is overwritten by the new one in case of collisions
			"coin_x5": {
				"group": "a", # this item belongs to a group
				"weight": 30.0, # weight of this item within its group
			},
			"ketchup": {
				"distance": 3300.0,
			},
		},
	},
	"stage": {
		"name": "stage",
		"terrain fill": "res://assets/stages/backstage/stagefloor_tile.png",
		"terrain edge": "res://assets/stages/backstage/stagefloor_edge.png",
		"background": "res://assets/stages/stage/stage.png",
		"skybox": "res://assets/stages/stage/stage_skybox.png",
		"background offset": Vector2(0.0, -950.0),
		"background scale": Vector2(0.8, 0.8),
		"terrain scale": Vector2(1e-3, 1e2), # should be a Vector2
		"stage length": 4e4, # should be a float
		"intermission name": "outro",
		"music": Sounds.ID.MUSIC_STAGE,
		"is the last": true,
		"has ceiling": true,
		"has clouds": false,
		"items": { # items are merged, and old data is overwritten by the new one in case of collisions
			"coin_x5": {
				"group": "a", # this item belongs to a group
				"weight": 40.0, # weight of this item within its group
			},
			"ketchup": {
				"distance": 3250.0,
			},
		},
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
