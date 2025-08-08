class_name Player extends RigidBody2D


const CAMERA_GIVE := 1e-5;
const CAMERA_OFFSET_LIMIT := 150.0;
const CAMERA_LLG = CAMERA_OFFSET_LIMIT * CAMERA_OFFSET_LIMIT * CAMERA_GIVE;
const CAMERA_LG = CAMERA_OFFSET_LIMIT * CAMERA_GIVE;

const DEFAULT_CAMERA_OFFSET := Vector2(0.0, -200.0);
const DEFAULT_CAMERA_OFFSET_SCALED := DEFAULT_CAMERA_OFFSET / CAMERA_LLG

## speed at which the player is considered stationary
const SPEED_LOWER_LIMIT := 0.5; # in px/s
const SAFE_SPEED_LIMIT := 400.0;

## players running average velocity is calculated over VELOCITY_AVG_LIMIT amount of frames
const VELOCITY_AVG_LIMIT := 120;
var velocity_avg_array := PackedVector2Array();
var velocity_avg := Vector2();
var velocity_avg_idx : int = 0;

# debug info
var last_frame_delta : float = 0.0;
var last_frame_delta_physics : float = 0.0;


#region stats
# torque applied, usually multiplied by inertia
var player_torque := 30.0; # in rad/s^2
# fly strength applied, usually multiplied by mass
var player_fly_strength := 1800.0; # in px/s^2, g (980px/s2) + bonus
# when jumping, the impulse is defined as an impulse acquired by applying fly strength for this amount of seconds
var jump_fly_scale := 0.35; # in s
# stamina cost of jumps
var jump_cost := 2.0;
# rolling friction is reversely proportional to hardness
var hardness := 10.0;
# air friction is reversely proportional to hardness
var aeroshape := 10.0;
#endregion

# when "airborne" (this can happen a lot more often than expected in a physics simulation like ours)
# pressing "jump" action will activate buffer and jump will be executed when the player touches the ground
const JUMP_BUFFER_TIME = 0.1; 
var jump_buffer : float = 0.0; # in seconds

# body needs to not have contacts with ground for this amount of seconds to be considered flying
const FLIGHT_TIME_REQUIREMENT = 0.2;
var no_contact_time : float = 0.0;
var is_flying : bool :
	get:
		return no_contact_time >= FLIGHT_TIME_REQUIREMENT;

# affects player's emotion
var hng_for : float = 0.0; # in seconds


@onready var camera  = $Camera2D;


func _ready() -> void:
	velocity_avg_array.resize(VELOCITY_AVG_LIMIT);
	$Sprite2D.prepare_sprite(GameState.selected_skinsuit);
	
	if GameState.player != null and GameState.player != self:
		print("unlinking old Player instance from game state");
	GameState.player = self;


func apply_player_stats(stats: PlayerStats) -> void:
	player_torque = stats.player_torque;
	player_fly_strength = stats.player_fly_strength;
	jump_fly_scale = stats.jump_fly_scale;
	jump_cost = stats.jump_cost;
	hardness = stats.hardness;
	aeroshape = stats.aeroshape;
	physics_material_override.bounce = stats.bounce;
	physics_material_override.friction = stats.friction;
	mass = stats.mass;
	inertia = stats.mass * 1500.0;
	linear_damp = stats.linear_damp;
	angular_damp = stats.angular_damp;


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"roll_cw"):
		try_rotate(player_torque * inertia, delta);
	elif Input.is_action_pressed(&"roll_ccw"):
		try_rotate(-player_torque * inertia, delta);
	
	if Input.is_action_pressed(&"fly"):
		try_propel_upward(delta);
	
	var contact_count = get_contact_count();
	if contact_count == 0:
		no_contact_time += delta;
	else:
		if is_flying and linear_velocity.length() > SAFE_SPEED_LIMIT:
			take_impact_damage()
		
		no_contact_time = 0.0;
	
	# jump logic
	if contact_count > 0 and (Input.is_action_just_pressed(&"jump") or jump_buffer > 0.0):
		try_jump();
		jump_buffer = 0.0;
	
	if contact_count == 0 and Input.is_action_just_pressed(&"jump"):
		jump_buffer = JUMP_BUFFER_TIME;
	
	if jump_buffer > 0.0:
		jump_buffer -= delta;
	
	# rolling friction
	if contact_count > 0:
		apply_torque(-angular_velocity * inertia / hardness);
	
	# air friction
	apply_central_force(-linear_velocity * mass / aeroshape);
	
	last_frame_delta_physics = delta;


func _process(delta: float) -> void:
	if Input.is_action_pressed(&'nudge_camera_down'):
		calc_camera_offset(linear_velocity + Vector2(0.0, 400.0));
	else:
		calc_camera_offset(linear_velocity);
	
	if hng_for > 0:
		if GameState.juice > jump_cost:
			$Sprite2D.display_emotion(1);
		else:
			$Sprite2D.display_emotion(2);
		hng_for -= delta;
	elif GameState.juice <= 0:
		$Sprite2D.display_emotion(2);
	else:
		$Sprite2D.display_emotion(0);
	
	last_frame_delta = delta;


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
	var upward_force := upward_unit_vector * player_fly_strength * mass;
	
	if GameState.juice > delta:
		apply_central_force(upward_force);
		GameState.juice -= delta;
	else:
		var upward_force_scaled = upward_force * GameState.juice / delta
		apply_central_force(upward_force_scaled);
		GameState.juice = 0.0;


func try_jump() -> void:
	var upward_unit_vector := Vector2(0, -1).rotated(self.rotation);
	var upward_impulse := upward_unit_vector * player_fly_strength * mass * jump_fly_scale;
	
	hng_for = 0.2;
	
	if GameState.juice > jump_cost:
		apply_central_impulse(upward_impulse);
		GameState.juice -= jump_cost;


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
