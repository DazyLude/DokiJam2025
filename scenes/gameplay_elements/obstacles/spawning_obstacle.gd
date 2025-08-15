extends GenericObstacle
class_name SpawningObstacle

@onready var area : Area2D = $Area2D;

var can_spawn = true
var manager = GameState.current_stage.obstacles

func _ready() -> void:
	area.body_entered.connect(on_contact);
	area.set_collision_mask_value(2, true); 

func on_contact(_body: Node2D) -> void:
	if can_spawn:
		can_spawn = false
		spawn_obstacles()

func spawn_obstacles() -> void:
	# LMG Note: Change into a timer, throw each one with 20ms in-between
	# LMG Note: Spawn above trash can
	var garbage: Node
	for index in range(5):
		garbage = manager.get_specific_obstacle("garbage")
		garbage.linear_velocity = Vector2(randi_range(-10, 10), 10)
		add_child(garbage)
