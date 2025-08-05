class_name Player extends RigidBody2D


const CAMERA_GIVE := 1e-5;
const CAMERA_OFFSET_LIMIT := 150.0;
const CAMERA_LLG = CAMERA_OFFSET_LIMIT * CAMERA_OFFSET_LIMIT * CAMERA_GIVE;
const CAMERA_LG = CAMERA_OFFSET_LIMIT * CAMERA_GIVE;

const DEFAULT_CAMERA_OFFSET := Vector2(0.0, -200.0);
const DEFAULT_CAMERA_OFFSET_SCALED := DEFAULT_CAMERA_OFFSET / CAMERA_LLG


const ROT_ACCEL = 20.0; # in rad/s^2
const FLY_ACCEL = 1800.0; # in px/s^2, g (980px/s2) + bonus
const JUMP_FLY_ACCEL_SCALE = 0.3; # in s
const JUMP_COST = 2.0;
const JUMP_BUFFER_TIME = 0.1;

## speed at which the player is considered stationary
const SPEED_LOWER_LIMIT = 0.5; # in px/s

## players running average velocity is calculated over VELOCITY_AVG_LIMIT amount of frames
const VELOCITY_AVG_LIMIT := 240;
var velocity_avg_array := PackedVector2Array();
var velocity_avg := Vector2();
var velocity_avg_idx : int = 0;

var hardness : float = 10.0; # reduces rolling friction
var aeroshape : float = 10.0; # reduces air friction

var jump_buffer : float = 0.0;

var hng_for : float = 0.0; # in seconds


@onready var camera  = $Camera2D;


func _ready() -> void:
	velocity_avg_array.resize(VELOCITY_AVG_LIMIT);
	$Sprite2D.prepare_sprite(GameState.selected_skinsuit);
	


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"roll_cw"):
		try_rotate(ROT_ACCEL * inertia, delta);
	elif Input.is_action_pressed(&"roll_ccw"):
		try_rotate(-ROT_ACCEL * inertia, delta);
	
	if Input.is_action_pressed(&"fly"):
		try_propel_upward(delta);
	
	# jump logic
	if get_contact_count() > 0 and (Input.is_action_just_pressed(&"jump") or jump_buffer > 0.0):
		try_jump();
		jump_buffer = 0.0;
	
	if get_contact_count() == 0 and Input.is_action_just_pressed(&"jump"):
		jump_buffer = JUMP_BUFFER_TIME;
	
	if jump_buffer > 0.0:
		jump_buffer -= delta;
	
	# rolling friction
	if get_contact_count() > 0:
		apply_torque(-angular_velocity * inertia / hardness);
	
	# air friction
	apply_central_force(-linear_velocity * mass / aeroshape)


func _process(delta: float) -> void:
	calc_camera_offset(linear_velocity);
	
	if hng_for > 0:
		if GameState.juice > JUMP_COST:
			$Sprite2D.display_emotion(2);
		else:
			$Sprite2D.display_emotion(1);
		hng_for -= delta;
	elif GameState.juice <= 0:
		$Sprite2D.display_emotion(2);
	else:
		$Sprite2D.display_emotion(0);


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


func try_jump() -> void:
	var upward_unit_vector := Vector2(0, -1).rotated(self.rotation);
	var upward_impulse := upward_unit_vector * FLY_ACCEL * mass * JUMP_FLY_ACCEL_SCALE;
	
	hng_for = 0.2;
	$Sprite2D.display_emotion(1);
	
	if GameState.juice > JUMP_COST:
		apply_central_impulse(upward_impulse);
		GameState.juice -= JUMP_COST;


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
