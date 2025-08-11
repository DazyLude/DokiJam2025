extends Camera2D


const CAMERA_GIVE := 1e-5;
const CAMERA_OFFSET_LIMIT := 150.0;
const CAMERA_LLG = CAMERA_OFFSET_LIMIT * CAMERA_OFFSET_LIMIT * CAMERA_GIVE;
const CAMERA_LG = CAMERA_OFFSET_LIMIT * CAMERA_GIVE;

const DEFAULT_CAMERA_OFFSET := Vector2(0.0, -200.0);
const DEFAULT_CAMERA_OFFSET_SCALED := DEFAULT_CAMERA_OFFSET / CAMERA_LLG;



func update_offset(player: Player, player_rotation: float) -> void:
	var velocity_avg = player.speedometer.velocity_avg;
	# calculate new camera offset
	var camera_offset := (DEFAULT_CAMERA_OFFSET_SCALED + velocity_avg).rotated(-player_rotation);
	
	var x := velocity_avg.length();
	var camera_offset_mult := CAMERA_LLG / (1 + x * CAMERA_LG);
	
	position = camera_offset * camera_offset_mult;
