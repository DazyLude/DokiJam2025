extends AudioStreamPlayer2D

const SPEED_LIMIT := Player.SAFE_SPEED_LIMIT;


var flying_too_fast : bool = false;
var taken_damage : bool = false;


func record_taken_damage(damage_value: float) -> void:
	if damage_value > 0.0:
		taken_damage = true;


func update_player_state(player: Player) -> void:
	var velocity = player.linear_velocity;
	
	# update state variables
	if player.is_flying and (abs(velocity.y) > SPEED_LIMIT or abs(velocity.x) > SPEED_LIMIT ** 2):
		flying_too_fast = true;
	
	# play forced sounds if needed
	play_forced();
	
	# play non forced sounds
	if not playing:
		play_non_forced();
	
	reset_state();


func reset_state() -> void:
	taken_damage = false;
	flying_too_fast = false;


func play_non_forced() -> void:
	if flying_too_fast:
		play_sound(Sounds.ID.SFX_AGGH);


func play_forced() -> void:
	if taken_damage:
		play_sound(Sounds.ID.SFX_AAGH, true);


func play_sound(id: Sounds.ID, force: bool = false) -> void:
	if not playing or force:
		stream = Sounds.get_stream_by_id(id);
		play();
