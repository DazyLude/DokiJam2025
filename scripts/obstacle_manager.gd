class_name ObstacleManager
extends RefCounted

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
	"toemaytoes": {
		"scene": "res://scenes/gameplay_elements/obstacles/tomato_box.tscn",
		"scale": Vector2(0.2, 0.2),
		"weight": 100.0,
		"natural habitat": ["tomato fields"],
		"positions": [
			PositionPreset.fixed(0.0, -250.0),
		],
	}
}

var rng : RandomNumberGenerator;
var _obstacles : PackedStringArray;
var _weights : PackedFloat32Array;


# returns a list of obstacles encountered at stage
static func get_obstacles(stage: String) -> PackedStringArray:
	var result := PackedStringArray();
	
	for obstacle in obstacle_metadata:
		var data = obstacle_metadata[obstacle];
		if stage in data.get("natural habitat", []):
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


func get_random_obstacle() -> Node2D:
	var obs_idx := rng.rand_weighted(_weights);
	var obstacle_name :=_obstacles[obs_idx];
	var obstacle_data := obstacle_metadata[obstacle_name];
	var obstacle_path := obstacle_data["scene"] as String;
	var obstacle_scene := load(obstacle_path).instantiate() as GenericObstacle;
	
	if obstacle_scene == null:
		push_error("obstacle is not a GenericObstacle: %s" % obstacle_name);
		return null;
	
	# select a random position preset
	var positions = obstacle_data.get("positions", [PositionPreset.fixed(0.0, 0.0)]);
	var pos_idx = rng.randi_range(0, positions.size() - 1);
	var preset : PositionPreset = positions[pos_idx];
	
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
	
	return obstacle_scene;
