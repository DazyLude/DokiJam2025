class_name Player extends RigidBody2D


const CAMERA_GIVE := 1e-5;
const CAMERA_OFFSET_LIMIT := 150.0;
const CAMERA_LLG = CAMERA_OFFSET_LIMIT * CAMERA_OFFSET_LIMIT * CAMERA_GIVE;
const CAMERA_LG = CAMERA_OFFSET_LIMIT * CAMERA_GIVE;

const DEFAULT_CAMERA_OFFSET := Vector2(0.0, -200.0);
const DEFAULT_CAMERA_OFFSET_SCALED := DEFAULT_CAMERA_OFFSET / CAMERA_LLG


const ROT_ACCEL = 20.0; # in rad/s^2
const FLY_ACCEL = 1800.0; # in px/s^2, g (980px/s2) + bonus

## speed at which the player is considered stationary
const SPEED_LOWER_LIMIT = 0.5; # in px/s

## players running average velocity is calculated over VELOCITY_AVG_LIMIT amount of frames
const VELOCITY_AVG_LIMIT := 240;
var velocity_avg_array := PackedVector2Array();
var velocity_avg := Vector2();
var velocity_avg_idx : int = 0;


@onready var camera  = $Camera2D;


func _ready() -> void:
	velocity_avg_array.resize(VELOCITY_AVG_LIMIT);


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"roll_cw"):
		try_rotate(ROT_ACCEL * inertia, delta);
	elif Input.is_action_pressed(&"roll_ccw"):
		try_rotate(-ROT_ACCEL * inertia, delta);
	
	if Input.is_action_pressed(&"fly"):
		try_propel_upward(delta);
	
	# TODO rolling friction
	# TODO air friction


func _process(delta: float) -> void:
	calc_camera_offset(linear_velocity);
	
	if GameState.juice <= 0:
		$Sprite2D.display_emotion(2);


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


func calc_camera_offset(velocity: Vector2) -> void:
	# update average velocity
	if velocity_avg_idx == VELOCITY_AVG_LIMIT:
		velocity_avg_idx = 0;
	
	velocity_avg += (velocity - velocity_avg_array[velocity_avg_idx]) / VELOCITY_AVG_LIMIT;
	velocity_avg_array[velocity_avg_idx] = velocity;
	velocity_avg_idx += 1;
	
	# calculate new camera offset
	var vel_len := velocity_avg.length();
	camera.position = (DEFAULT_CAMERA_OFFSET_SCALED + velocity_avg).rotated(-rotation) * CAMERA_LLG / (1 + vel_len * CAMERA_LG);
