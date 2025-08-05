extends Control
class_name IntermissionPlayer

signal finished;
signal next;


var current_intermission : Dictionary;


@onready var background = $Background;
@onready var dialogue_player = $DialogueBase;
@onready var comic_player = $ComicBase;


func _ready() -> void:
	next.connect(dialogue_player.next);
	dialogue_player.dialogue_finished.connect(finished.emit);


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"intermission_next"):
		next.emit();


func set_intermission(intermission: String):
	current_intermission = IntermissionData.intermission_data[intermission];


func play() -> void:
	if current_intermission.is_empty():
		return;
	
	if current_intermission.has("background"):
		$Background.texture = load(current_intermission["background"])
	
	match current_intermission.get("type", -1):
		IntermissionData.TYPE_DIALOGUE:
			$DialogueBase.show();
			$ComicBase.hide();
			dialogue_player.play_dialogue(current_intermission);
		IntermissionData.TYPE_YONKOMA:
			$ComicBase.show();
			$DialogueBase.hide();
			#comic_player.play_yonkoma(current_intermission);
		_:
			push_error("wrong intermission type: %s" % current_intermission);
