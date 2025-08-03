extends Control


const SPEED_TEMPLATE := "speed: %10.3f";
const ANGULAR_SPEED_TEMPLATE := "angular speed: %10.3f";
const COORDS_TEMPLATE := "position: (%10.3f, %10.3f)";
const ROTATION_TEMPLATE := "upward vector: (%10.3f, %10.3f)";
const STAMINA_SPEED_TEMPLATE := "tomato juice: %10.3f";


var player : Player;


func _process(delta: float) -> void:
	if player != null:
		$DataContainer/Speed.text = SPEED_TEMPLATE % player.linear_velocity.length();
		$DataContainer/AngularSpeed.text = ANGULAR_SPEED_TEMPLATE % player.angular_velocity;
		$DataContainer/Coordinates.text = COORDS_TEMPLATE % [player.position.x, player.position.y];
		var upward = Vector2(0, -1).rotated(player.rotation);
		$DataContainer/Rotation.text = ROTATION_TEMPLATE % [upward.x, upward.y]
	
	if GameState != null:
		$DataContainer/Stamina.text = STAMINA_SPEED_TEMPLATE % GameState.juice;
