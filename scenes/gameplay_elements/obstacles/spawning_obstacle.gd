extends GenericObstacle
class_name SpawningObstacle

@onready var area : Area2D = $Sprite2D/Area2D;

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
	for i in 5:
		get_tree().create_timer(0.2 * i).timeout.connect(_create_garbage)


func _create_garbage() -> void:
	var garbage: RigidBodyObstacle = manager.get_specific_obstacle("garbage");
	garbage.set_collision_layer_value(1, false);
	garbage.position = position + Vector2(randi_range(-20, 20), -120.0)
	
	# changing linear speed directly leads to undefined behaviour
	# if you apply impulse of {desired velocity} * {rigid body's mass} it by definition will give it the speed you want
	garbage.apply_impulse(Vector2(randi_range(-150, 150), -450) * garbage.mass);
	get_parent().add_child(garbage)
