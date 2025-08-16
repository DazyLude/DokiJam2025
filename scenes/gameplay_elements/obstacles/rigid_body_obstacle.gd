extends RigidBody2D
class_name RigidBodyObstacle


var offset : Vector2 :
	set(v):
		position = v;


func set_custom_scale(new_scale: Vector2) -> void:
	$Sprite2D.scale = new_scale
	$CollisionPolygon2D.scale = new_scale


func flip() -> void:
	$Sprite2D.scale *= Vector2(-1.0, 1.0);
	$CollisionPolygon2D.scale *= Vector2(-1.0, 1.0);


func _physics_process(delta: float) -> void:
	if not get_collision_layer_value(1):
		# check if can manifest
		if get_colliding_bodies().is_empty():
			set_collision_layer_value(1, true);
