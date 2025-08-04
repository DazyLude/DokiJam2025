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
	if emotions.is_empty() or current_emotion == emotion_idx:
		return;
	
	current_emotion = clampi(emotion_idx, 0, emotions.size() - 1);
	overlay_sprite.texture = emotions[current_emotion];
