class_name Player extends RigidBody2D


const ROT_ACCEL = 20.0; # in rad/s^2
const FLY_ACCEL = 1800.0; # in px/s^2, g (980px/s2) + bonus

## speed at which the player is considered stationary
const SPEED_LOWER_LIMIT = 0.01; # in px/s


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"roll_cw"):
		try_rotate(ROT_ACCEL * inertia, delta);
	elif Input.is_action_pressed(&"roll_ccw"):
		try_rotate(-ROT_ACCEL * inertia, delta);
	
	if Input.is_action_pressed(&"fly"):
		try_propel_upward(delta);


# tries to spend stamina
# if stamina is less than delta, reduces applied force by a fraction
func try_rotate(torque: float, delta: float) -> void:
	if GameState.juice > delta:
		apply_torque(torque);
		GameState.juice -= delta;
	else:
		var torque_scaled = torque * GameState.juice / delta
		apply_torque(torque_scaled);
		GameState.juice = 0.0;


# tries to spend stamina
# if stamina is less than delta, reduces applied force by a fraction
func try_propel_upward(delta: float) -> void:
	#  Vector2(0, -1) is an upward looking unit vector. Because Y-Axis looks downwards.
	var upward_unit_vector := Vector2(0, -1).rotated(self.rotation);
	var upward_force := upward_unit_vector * FLY_ACCEL * mass;
	
	if GameState.juice > delta:
		apply_central_force(upward_force);
		GameState.juice -= delta;
	else:
		var upward_force_scaled = upward_force * GameState.juice / delta
		apply_central_force(upward_force_scaled);
		GameState.juice = 0.0;


func is_stationary() -> bool:
	return SPEED_LOWER_LIMIT > self.linear_velocity.length();
