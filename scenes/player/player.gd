class_name Player extends RigidBody2D


## speed at which the player is considered stationary
const SPEED_LOWER_LIMIT := 0.5; # in px/s
#const SAFE_SPEED_LIMIT := 750.0; #LMG Note: original value
const SAFE_SPEED_LIMIT := 650.0;

# debug info
var last_frame_delta : float = 0.0;
var last_frame_delta_physics : float = 0.0;

#region stats
# torque applied, usually multiplied by inertia
var player_torque := 25.0; # in rad/s^2
# fly strength applied, usually multiplied by mass
var player_fly_strength := 1400.0; # in px/s^2, g (980px/s2) + bonus
# when jumping, the impulse is defined as an impulse acquired by applying fly strength for this amount of seconds
var jump_fly_scale := 0.33; # in s
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
var flap_amount = 0
var is_grounded = false

# body needs to not have contacts with ground for this amount of seconds to be considered flying
const FLIGHT_TIME_REQUIREMENT = 0.2;
var no_contact_time : float = 0.0;
var is_flying : bool :
	get:
		return no_contact_time >= FLIGHT_TIME_REQUIREMENT;

# affects player's emotion
var hng_for : float = 0.0; # in seconds
var oof_for : float = 0.0;

#buff counter
var buff_active = false
var buff_counter = 0

#trail control
var current_trail: Trail

# internal flags
var _should_stop : bool = false;


var speedometer := Speedometer.new();

# camera node changes viewport coordinates to be in the center
# camera tracks average player speed for camera offset
@onready var camera = $Camera2D;
@onready var sound_controller = $ScreamsPlayer;
@onready var normal_sfx_player = $SFXPlayer;
@onready var wings = $Wings;


func _ready() -> void:
	$BuffAnimation.pause()
	
	$Sprite2D.prepare_sprite(GameState.selected_skinsuit);
	if Upgrade.upgrade_metadata[GameState.selected_skinsuit].has("rider"):
		var rider = Upgrade.upgrade_metadata[GameState.selected_skinsuit]["rider"];
		$StaticSprite.prepare_sprite(rider);
	
	wings.update_wings_count(GameState.upgrades.get_upgrade_level(Upgrade.WINGS));
	
	if GameState.player != null and GameState.player != self:
		print("unlinking old Player instance from game state");
	GameState.player = self;
	make_player_trail()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _should_stop:
		state.linear_velocity = Vector2();
		state.angular_velocity = 0.0;
		_should_stop = false;


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"roll_cw"):
		try_rotate(player_torque * inertia, delta);
	elif Input.is_action_pressed(&"roll_ccw"):
		try_rotate(-player_torque * inertia, delta);
	
	if Input.is_action_pressed(&"fly"):
		try_propel_upward(delta);
	
	var contact_count = get_contact_count();
	
	# manage fall damage
	if is_flying and abs(speedometer.get_last_frame_speed().y) > SAFE_SPEED_LIMIT and contact_count > 0:
		take_impact_damage();
	
	# manage contact timer
	if contact_count == 0:
		no_contact_time += delta;
		if is_flying:
			is_grounded = false
	else:
		no_contact_time = 0.0;
		flap_amount = 0;
		is_grounded = true
	
	# jump logic and flight controls
	if is_grounded:
		if Input.is_action_just_pressed(&"jump") or jump_buffer > 0.0:
			try_jump();
			jump_buffer = 0.0;
			is_grounded = false
	else:
		if Input.is_action_just_pressed(&"jump"):
			try_flap();
			jump_buffer = JUMP_BUFFER_TIME;
		# mid-air strafing
		if Input.is_action_pressed(&"fly_left"):
			try_strafe(-1, delta)
		elif Input.is_action_pressed(&"fly_right"):
			try_strafe(1, delta)
	
	if jump_buffer > 0.0:
		jump_buffer -= delta;
	
	# rolling friction
	if contact_count > 0:
		apply_torque(-angular_velocity * inertia / hardness);
	
	# air friction
	apply_central_force(-linear_velocity * mass / aeroshape);
	
	last_frame_delta_physics = delta;
	sound_controller.update_player_state(self);
	speedometer.update_speed(self.linear_velocity);
	
	# buff reset
	if buff_active:
		if buff_counter > 0 and GameState.juice > 0.0:
			buff_counter -= delta
		else:
			buff_active = false
			$BuffAnimation.visible = false
			$BuffAnimation.pause()
			apply_player_stats(PlayerStats.get_latest())


func _process(delta: float) -> void:
	camera.update_offset(self, rotation);
	$StaticSprite.rotation = -rotation;
	$BuffAnimation.rotation = -rotation;
	
	if oof_for > 0:
		set_emotion(1);
	elif hng_for > 0:
		if GameState.juice > jump_cost:
			set_emotion(2);
	elif GameState.juice <= 0:
		set_emotion(2);
		if current_trail:
			current_trail.stop_trail()
			current_trail = null
			print("stop trail")
	else:
		set_emotion(0);
		if not current_trail:
			make_player_trail()
			print("new trail")
	
	oof_for = move_toward(oof_for, 0.0, delta);
	hng_for = move_toward(hng_for, 0.0, delta);
	
	last_frame_delta = delta;


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


func make_player_trail() -> void:
	if current_trail:
		current_trail.stop_trail()
	current_trail = Trail.create_trail()
	add_child(current_trail)


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

func try_strafe(direction: float, delta: float) -> void:
	var movement_direction = sign(linear_velocity.x)
	var strafe_vector := Vector2(direction, 0)
	var strafe_force := strafe_vector * player_fly_strength * mass * jump_fly_scale;
	# Cannot strafe past the speed cap
	if abs(linear_velocity.x) > 50 and sign(direction) == movement_direction:
		return
	if GameState.juice > delta:
		GameState.juice -= delta;
	else:
		strafe_force /= 2
		GameState.juice = 0.0;
	apply_force(strafe_force)


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

## launches the player upward when in contact with a wingbull item
func launch_upward() -> void:
	var upward_unit_vector := Vector2(0, -1);
	var upward_impulse := upward_unit_vector * player_fly_strength * mass * jump_fly_scale;
	hng_for = 0.2;
	apply_central_impulse(upward_impulse * 2);

## launches the player forward when in contact with a coffee item
func launch_forward() -> void:
	var direction = sign(linear_velocity.x)
	if direction == 0:
		direction = 1
	var forward_unit_vector := Vector2(direction, 0);
	var forward_impulse := forward_unit_vector * player_fly_strength * mass * jump_fly_scale;
	apply_central_impulse(forward_impulse);
	apply_torque(player_torque * direction)


## buffs the player when in contact with a supps item
func apply_supps_buff() -> void:
	# Activate the buff counter
	buff_active = true
	buff_counter = 5.0 #seconds
	# Activate buff visuals
	$BuffAnimation.visible = true
	$BuffAnimation.play()
	# Increase player stats
	player_fly_strength *= 1.5
	physics_material_override.friction = 1.0
	hardness *= 5
	# Refill juice meter
	GameState.juice = GameState.juice_cap


func try_jump() -> void:
	#var upward_unit_vector := Vector2(0, -1).rotated(self.rotation);
	var upward_unit_vector := Vector2(0, -1);
	var upward_impulse := upward_unit_vector * player_fly_strength * mass * jump_fly_scale;
	
	hng_for = 0.2;
	
	if GameState.juice > jump_cost:
		#apply_central_impulse(upward_impulse);
		GameState.juice -= jump_cost;
	else:
		upward_impulse *= GameState.juice / jump_cost
		GameState.juice = 0
	
	play_sfx(Sounds.ID.SFX_JUMP);
	apply_central_impulse(upward_impulse);


func try_flap() -> void:
	var flap_stat = GameState.upgrades.get_upgrade_level(Upgrade.WINGS)
	if flap_stat < 1 or flap_amount >= flap_stat:
		return;
	
	var upward_unit_vector := Vector2(0, -1);
	var upward_impulse := upward_unit_vector * player_fly_strength * mass * jump_fly_scale;
	
	hng_for = 0.2;
	
	if GameState.juice > jump_cost:
		#apply_central_impulse(upward_impulse);
		GameState.juice -= jump_cost;
		#flap_amount += 1;
		#wings.flap();
	else:
		upward_impulse *= GameState.juice / jump_cost
		GameState.juice = 0
	
	flap_amount += 1;
	play_sfx(Sounds.ID.SFX_FLAP);
	apply_central_impulse(upward_impulse);
	wings.flap();


func is_stationary() -> bool:
	return SPEED_LOWER_LIMIT > self.linear_velocity.length();


func take_impact_damage() -> void:
	# version 1
	#var speed_diff = abs(speedometer.get_last_frame_speed().y) - SAFE_SPEED_LIMIT;
	#var damage = 0.1 * sqrt(speed_diff);
	# version 2
	#var damage = (0.1 - (0.01 * (hardness - 5))) * sqrt(speed_diff)
	# version 3
	var speed_diff = abs(speedometer.get_last_frame_speed().y) - (SAFE_SPEED_LIMIT + (hardness * 20));
	var damage = sqrt(speed_diff)/(5.0 + hardness)
	
	if damage > 0.0:
		oof_for = 0.4;
		GameState.juice = move_toward(GameState.juice, 0.0, damage);
		sound_controller.record_taken_damage(damage);


func stop() -> void:
	_should_stop = true;


func set_emotion(emote: int) -> void:
	$Sprite2D.display_emotion(emote);
	$StaticSprite.display_emotion(emote);


func play_sfx(id: Sounds.ID) -> void:
	$SFXPlayer.get_stream_playback().play_stream(
		Sounds.get_stream_by_id(id)
	);


class Speedometer:
	## players running average velocity is calculated over VELOCITY_AVG_LIMIT amount of frames
	const VELOCITY_AVG_LIMIT := 120;
	var velocity_array := PackedVector2Array();
	var velocity_idx : int = 0;
	var velocity_avg := Vector2();
	
	
	func _init() -> void:
		velocity_array.resize(VELOCITY_AVG_LIMIT);
	
	
	func update_speed(player_velocity) -> void:
		# update average velocity
		if velocity_idx == VELOCITY_AVG_LIMIT:
			velocity_idx = 0;
		
		velocity_avg += (player_velocity - velocity_array[velocity_idx]) / VELOCITY_AVG_LIMIT;
		velocity_array[velocity_idx] = player_velocity;
		velocity_idx += 1;
	
	
	func get_last_frame_speed() -> Vector2:
		if velocity_idx == 0:
			return velocity_array[VELOCITY_AVG_LIMIT - 1];
		else:
			return velocity_array[velocity_idx - 1];
