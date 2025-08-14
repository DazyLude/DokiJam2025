extends ProgressBar


@onready var start_pos : Vector2 = $StartMarker.position;
@onready var end_pos : Vector2 = $EndMarker.position;


var player : Player = null;


func _ready() -> void:
	value_changed.connect(move_tomato);
	$StartMarker.hide();
	$EndMarker.hide();


func _process(delta: float) -> void:
	if player != null and GameState.current_stage != null:
		value = player.position.x / GameState.current_stage.stage_length * 100.0;
	
	visible = not (player.get_parent() as Game).is_gameover;


func move_tomato(to: float) -> void:
	$Tomato.position = start_pos.lerp(end_pos, value / max_value)
