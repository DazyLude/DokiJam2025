class_name Player extends RigidBody2D


const ROT_ACCEL = 100.0; # in rad/s^2
const FLY_ACCEL = 6.0; # in px/s^2

const TERMINAL_VELOCITY := 700; # in px/s
const MAX_ROT_SPEED := 3.0 * PI; # in rad/s


func _physics_process(delta: float) -> void:
	var torque : float = 0.0;
	if Input.is_action_pressed(&"roll_cw"):
		torque = ROT_ACCEL * inertia;
	elif Input.is_action_pressed(&"roll_ccw"):
		torque = -ROT_ACCEL * inertia;
	
	apply_torque(torque)
	
	#if angular_velocity > MAX_ROT_SPEED:
		#apply_torque_impulse((angular_velocity - MAX_ROT_SPEED) * inertia)
