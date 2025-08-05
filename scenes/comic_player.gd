extends Control


signal comic_finished;


const PANEL_MAX = 4;
var current_panel : int = -1;
@onready var panel = [$TextureRect, $TextureRect2, $TextureRect3, $TextureRect4];


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"intermission_next"):
		next();


func play_comic(data: Dictionary) -> void:
	current_panel = -1;
	for i in PANEL_MAX:
		panel[i].texture = load(data["images"][i]);
		panel[i].hide();
	
	next();


func next() -> void:
	current_panel += 1;
	if current_panel >= PANEL_MAX:
		comic_finished.emit();
		return;
	
	panel[current_panel].show();
