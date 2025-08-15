class_name ObstacleManager
extends RefCounted


enum {
	PLACEMENT_FLOOR,
	PLACEMENT_CEILING,
}


enum {
	FLAG_SPAWN_PICKUP_ON_ME,
	FLAG_SPAWN_ANOTHER,
}

# we can reuse most of this classes code for DecorationManager

static var obstacle_metadata : Dictionary[String, Dictionary] = {
	"pitchfork": {
		"scene": "res://scenes/gameplay_elements/obstacles/pitchfork.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["tomato fields"],
		"positions": [
			PositionPreset.fixed(100.0, 0.0),
			PositionPreset.fixed(-100.0, 0.0),
			PositionPreset.fixed_offset(Vector2(45.0, 70.0), -100.0),
		],
	},
	"scarecrow": {
		"scene": "res://scenes/gameplay_elements/obstacles/scareki.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["tomato fields"],
		"positions": [
			PositionPreset.fixed_offset(Vector2(-10.0, 10.0), -250.0),
		],
		"flippable": true,
	},
	"tomato box": {
		"scene": "res://scenes/gameplay_elements/obstacles/tomato_box.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["tomato fields"],
		"positions": [
			PositionPreset.fixed(0.0, -250.0),
		],
	},
	"cone": {
		"scene": "res://scenes/gameplay_elements/obstacles/cone.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city2"],
		"positions": [
			PositionPreset.fixed(0.0, -150.0),
		],
	},
	"dumpster": {
		"scene": "res://scenes/gameplay_elements/obstacles/dumpster.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 50.0,
		"natural habitat": ["city2"],
		"positions": [
			PositionPreset.fixed(0.0, -350.0),
		],
	},
	"garbage": {
		"scene": "res://scenes/gameplay_elements/obstacles/garbage.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city2"],
		"positions": [
			PositionPreset.fixed(0.0, -150.0),
		],
	},
	"lamp": {
		"scene": "res://scenes/gameplay_elements/obstacles/lamp.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city", "city2"],
		"positions": [
			PositionPreset.fixed(0.0, -500.0),
		],
	},
	"news stand": {
		"scene": "res://scenes/gameplay_elements/obstacles/news_stand.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city"],
		"positions": [
			PositionPreset.fixed(0.0, -350.0),
		],
	},
	"sign": {
		"scene": "res://scenes/gameplay_elements/obstacles/sign.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city2"],
		"positions": [
			PositionPreset.fixed(0.0, -275.0),
		],
	},
	"table": {
		"scene": "res://scenes/gameplay_elements/obstacles/table.tscn",
		"scale": Vector2(0.4, 0.4),
		"weight": 100.0,
		"natural habitat": ["city"],
		"positions": [
			PositionPreset.fixed(0.0, -200.0),
		],
	},
	"trash can": {
		"scene": "res://scenes/gameplay_elements/obstacles/trash_can.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city"],
		"positions": [
			PositionPreset.fixed(0.0, -175.0),
		],
	},
	"trash can garbage": {
		"scene": "res://scenes/gameplay_elements/obstacles/trash_can.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["city2"],
		"positions": [
			PositionPreset.fixed(0.0, -175.0),
		],
		"flags": {
			FLAG_SPAWN_ANOTHER: {
				#list of other obstacles to spawn near this one and their offsets
				"garbage": [Vector2(-20.0, -50.0), Vector2(20.0, -50.0)],
			}
		},
	},
	"ceiling light": {
		"scene": "res://scenes/gameplay_elements/obstacles/ceiling_light.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["backstage", "stage"],
		"placement": PLACEMENT_CEILING,
		"positions": [
			PositionPreset.fixed(0.0, 400.0),
		],
	},
	"giant wisp": {
		"scene": "res://scenes/gameplay_elements/obstacles/giant_wisp.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["backstage", "stage"],
		"positions": [
			PositionPreset.fixed(0.0, -300.0),
		],
	},
	"light rack": {
		"scene": "res://scenes/gameplay_elements/obstacles/light_rack.tscn",
		"scale": Vector2(0.4, 0.4),
		"weight": 40.0,
		"natural habitat": ["backstage", "stage"],
		"positions": [
			PositionPreset.fixed(0.0, -500.0),
		],
	},
	"light rack troll": {
		"scene": "res://scenes/gameplay_elements/obstacles/light_rack_troll.tscn",
		"scale": Vector2(0.4, 0.4),
		"weight": 10.0,
		"natural habitat": ["backstage", "stage"],
		"positions": [
			PositionPreset.fixed(0.0, -500.0),
		],
		"flags": {
			FLAG_SPAWN_PICKUP_ON_ME: "coin_x5"
		}
	},
	"mic stand": {
		"scene": "res://scenes/gameplay_elements/obstacles/mic_stand.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["backstage", "stage"],
		"positions": [
			PositionPreset.fixed(0.0, -475.0),
		],
	},
	"stacked boxes": {
		"scene": "res://scenes/gameplay_elements/obstacles/stacked_boxes.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["backstage", "stage"],
		"positions": [
			PositionPreset.fixed(0.0, -420.0),
		],
	},
	"chungus dragoon": {
		"scene": "res://scenes/gameplay_elements/obstacles/chungus_dragoon.tscn",
		"scale": Vector2(0.5, 0.5),
		"weight": 100.0,
		"natural habitat": ["stage"],
		"positions": [
			PositionPreset.fixed(0.0, -375.0),
		],
	},
	"chonk dragoon": {
		"scene": "res://scenes/gameplay_elements/obstacles/chonk_dragoon.tscn",
		"scale": Vector2(0.3, 0.3),
		"weight": 100.0,
		"natural habitat": ["stage"],
		"positions": [
			PositionPreset.fixed(0.0, -250.0),
		],
	},
	"eggoon": {
		"scene": "res://scenes/gameplay_elements/obstacles/eggoon.tscn",
		"scale": Vector2(0.3, 0.3),
		"weight": 100.0,
		"natural habitat": ["stage"],
		"positions": [
			PositionPreset.fixed(0.0, -150.0),
		],
	},
	"eggoon stack": {
		"scene": "res://scenes/gameplay_elements/obstacles/eggoon_stack.tscn",
		"scale": Vector2(0.3, 0.3),
		"weight": 100.0,
		"natural habitat": ["stage"],
		"positions": [
			PositionPreset.fixed(0.0, -320.0),
		],
	},
	"long dragoon": {
		"scene": "res://scenes/gameplay_elements/obstacles/long_dragoon.tscn",
		"scale": Vector2(0.4, 0.4),
		"weight": 100.0,
		"natural habitat": ["stage"],
		"positions": [
			PositionPreset.fixed(0.0, -300.0),
		],
	},
	"mini dragoon": {
		"scene": "res://scenes/gameplay_elements/obstacles/mini_dragoon.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["stage"],
		"positions": [
			PositionPreset.fixed(0.0, -110.0),
		],
	},
}


var rng : RandomNumberGenerator;
var _obstacles : PackedStringArray;
var _weights : PackedFloat32Array;


static func for_stage(stage: String, placement: int = PLACEMENT_FLOOR) -> ObstacleManager:
	return from_array(get_obstacles(stage, placement));


# returns a list of obstacles encountered at stage
static func get_obstacles(stage: String, placement: int = PLACEMENT_FLOOR) -> PackedStringArray:
	var result := PackedStringArray();
	
	for obstacle in obstacle_metadata:
		var data = obstacle_metadata[obstacle];
		var obstacle_placement = data.get("placement", PLACEMENT_FLOOR);
		var obstacle_habitats = data.get("natural habitat", []);
		
		if stage in obstacle_habitats and placement == obstacle_placement:
			result.push_back(obstacle);
	
	return result;


# returns a manager instance for the selected list of obstacles
static func from_array(obstacles: PackedStringArray) -> ObstacleManager:
	var mane := ObstacleManager.new();
	
	for obstacle in obstacles:
		if obstacle in obstacle_metadata:
			var data = obstacle_metadata[obstacle];
			mane._obstacles.push_back(obstacle);
			mane._weights.push_back(data["weight"]);
	
	return mane;


# can access obstacles not native to the current stage
# isn't static to access rng
func get_specific_obstacle(obstacle_name: String) -> Node2D:
	var obstacle_data := obstacle_metadata[obstacle_name];
	var obstacle_path := obstacle_data["scene"] as String;
	var obstacle_scene = load(obstacle_path).instantiate();
	
	if obstacle_scene == null:
		push_error("obstacle is null: %s" % obstacle_name);
		return null;
	
	# select a random position preset
	var positions = obstacle_data.get("positions", [PositionPreset.fixed(0.0, 0.0)]);
	var pos_idx = rng.randi_range(0, positions.size() - 1);
	var preset : PositionPreset = positions[pos_idx];
	
	if obstacle_scene is GenericObstacle:
		# select an angle
		var angle = rng.randf_range(preset.angle_range.x, preset.angle_range.y);
		obstacle_scene.rotation_degrees = angle;
		# select an offset
		var y_offset = rng.randf_range(preset.y_offset_range.x, preset.y_offset_range.y);
		obstacle_scene.offset = Vector2(0.0, y_offset);
		
		# set scale
		obstacle_scene.scale = obstacle_data.get("scale", Vector2(1.0, 1.0));
		if obstacle_data.get("flippable", false) and rng.randf() > 0.5:
			obstacle_scene.flip()
	
	if obstacle_scene is RigidBodyObstacle:
		var y_offset = rng.randf_range(preset.y_offset_range.x, preset.y_offset_range.y);
		obstacle_scene.offset = Vector2(0.0, y_offset);
		
		obstacle_scene.set_custom_scale(obstacle_data.get("scale", Vector2(1.0, 1.0)));
		if obstacle_data.get("flippable", false) and rng.randf() > 0.5:
			obstacle_scene.flip()
	
	return obstacle_scene;


static func get_obstacle_flags(obstacle: String) -> Dictionary:
	return obstacle_metadata.get(obstacle, {}).get("flags", {});


func get_random_obstacle() -> String:
	var obs_idx := rng.rand_weighted(_weights);
	var obstacle_name := _obstacles[obs_idx];
	return obstacle_name;
