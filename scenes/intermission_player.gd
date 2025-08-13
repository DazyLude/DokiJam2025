extends Control
class_name IntermissionPlayer


signal finished;


var current_intermission : Dictionary;


@onready var background = $Background;
@onready var dialogue_player = $DialogueBase;
@onready var comic_player = $ComicBase;


func set_intermission(intermission: String):
	current_intermission = IntermissionData.intermission_data[intermission];


func play() -> void:
	if current_intermission.is_empty():
		return;
	
	if current_intermission.has("background"):
		$Background.texture = load(current_intermission["background"])
	
	if current_intermission.has("bgm"):
		Sounds.play_looped(current_intermission["bgm"])
	
	match current_intermission.get("type", -1):
		IntermissionData.TYPE_DIALOGUE:
			$DialogueBase.show();
			$ComicBase.hide();
			dialogue_player.dialogue_finished.connect(finished.emit);
			dialogue_player.play_dialogue(current_intermission);
		IntermissionData.TYPE_YONKOMA:
			$ComicBase.show();
			$DialogueBase.hide();
			comic_player.comic_finished.connect(finished.emit);
			comic_player.play_comic(current_intermission);
		_:
			push_error("wrong intermission type: %s" % current_intermission);
