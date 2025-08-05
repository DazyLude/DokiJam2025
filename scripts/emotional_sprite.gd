@tool
class_name SpriteEmotional extends Sprite2D


@export var emotions : Array[Texture2D] = [];

var current_emotion : int = -1;
var overlay_sprite := Sprite2D.new();


func _enter_tree() -> void:
	if overlay_sprite.get_parent() == null:
		add_child(overlay_sprite);
	
	display_emotion(0);


func display_emotion(emotion_idx: int) -> void:
	if emotions.is_empty():
		return;
	
	current_emotion = clampi(emotion_idx, 0, emotions.size() - 1);
	overlay_sprite.texture = emotions[current_emotion];


# uses intermission data
# probably should extract character data from there, it'd make more sense
func prepare_sprite(character_idx) -> void:
	var character_data = IntermissionData.character_data[character_idx];
	texture = load(character_data["base"]);
	emotions.clear();
	
	for emotion_id in character_data["emotions"]:
		var emotion_path = character_data["emotions"][emotion_id];
		emotions.push_back(load(emotion_path));
