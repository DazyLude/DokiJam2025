extends Control


const SPEED_TEMPLATE := "running average speed: %10.3f";
const ANGULAR_SPEED_TEMPLATE := "angular speed: %10.3f";
const COORDS_TEMPLATE := "position: (%10.3f, %10.3f)";
const ROTATION_TEMPLATE := "upward vector: (%10.3f, %10.3f)";
const STAMINA_SPEED_TEMPLATE := "tomato juice: %10.3f";
const CONTACT_COUNTER_TEMPLATE := "contacts: %d";
const FPS_TEMPLATE := "last frame delta: %1.2f (~%d FPS)"
const PHYSICS_FPS_TEMPLATE := "last physics delta: %1.2f (~%d FPS)"
const STATE_TEMPLATE := "fresh state: %s"


var player : Player;

var noise_gen_cache : Noise;


func _process(delta: float) -> void:
	if player != null:
		$DataContainer/Speed.text = SPEED_TEMPLATE % player.speedometer.velocity_avg.length();
		$DataContainer/AngularSpeed.text = ANGULAR_SPEED_TEMPLATE % player.angular_velocity;
		$DataContainer/Coordinates.text = COORDS_TEMPLATE % [player.position.x, player.position.y];
		var upward = Vector2(0, -1).rotated(player.rotation);
		$DataContainer/Rotation.text = ROTATION_TEMPLATE % [upward.x, upward.y];
		$DataContainer/ContactCounter.text = CONTACT_COUNTER_TEMPLATE % player.get_contact_count();
		$DataContainer/FPSCounter.text = FPS_TEMPLATE % [player.last_frame_delta, 1.0 / player.last_frame_delta];
		$DataContainer/PhysicsFPSCounter.text = PHYSICS_FPS_TEMPLATE % [player.last_frame_delta_physics, 1.0 / player.last_frame_delta_physics];
	
	if GameState != null:
		$DataContainer/Stamina.text = STAMINA_SPEED_TEMPLATE % GameState.juice;
		$DataContainer/FreshState.text = STATE_TEMPLATE % GameState.current_stage.fresh_state;
		
		$CoinCounter/Label.text = "%d" % GameState.dokicoins;
		$KetchupMeter.value = GameState.juice / GameState.juice_cap * 100;
	
	if noise_gen_cache != GameState.current_stage.generator.noise_generator:
		noise_gen_cache = GameState.current_stage.generator.noise_generator;
		$DataContainer/Noise.texture = ImageTexture.create_from_image(noise_gen_cache.get_image(1000, 1000));


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'show_debug_info'):
		$DataContainer.visible = not $DataContainer.visible;
