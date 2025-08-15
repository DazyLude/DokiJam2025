extends Control


signal dialogue_finished;


@onready var character_sprites : Array[SpriteEmotional] = [$CharacterLeft, $CharacterRight];
@onready var dialogue_text = $TextBox/Text;
@onready var speaker = $TextBox/Speaker;
@onready var audio_player = $AudioStreamPlayer;

var text_animation : Tween;
var character_tweens : Array[Tween] = [];
var normal_positions : Array[Vector2] = [];

var node_per_character := {};
var idx_per_character := {};
var emote_idxs_per_character := {};
var voices_per_character := {};
var name_per_character := {};

var dialogue_array := [];
var current_line := -1;

const SPEAK_JUMP = Vector2(0, -50);



func _ready() -> void:
	$CharacterLeft.position = (get_viewport_rect().size - $CharacterLeft.get_rect().size * $CharacterLeft.scale ) * Vector2(0, 1.0) - SPEAK_JUMP;
	$CharacterRight.position = (get_viewport_rect().size - $CharacterLeft.get_rect().size * $CharacterRight.scale) - SPEAK_JUMP;
	
	character_tweens.resize(character_sprites.size());
	normal_positions.resize(character_sprites.size());
	for i in character_sprites.size():
		normal_positions[i] = character_sprites[i].position;
	


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"intermission_next"):
		next();


func play_dialogue(data: Dictionary) -> void:
	setup_characters(data["characters"]);
	dialogue_array = data["dialogue"];
	current_line = -1;
	next();


func setup_characters(characters: Array) -> void:
	for i in 2:
		var character_id = characters[i];
		
		node_per_character[character_id] = character_sprites[i];
		emote_idxs_per_character[character_id] = {};
		
		var character_data = IntermissionData.character_data[characters[i]];
		name_per_character[character_id] = character_data["name"];
		character_sprites[i].texture = load(character_data["base"]);
		character_sprites[i].emotions.clear();
		idx_per_character[character_id] = i;
		voices_per_character[character_id] = character_data.get("speech", null);
		
		for emotion_id in character_data["emotions"]:
			var emotion_path = character_data["emotions"][emotion_id];
			character_sprites[i].emotions.push_back(load(emotion_path) if emotion_path != "" else null);
			emote_idxs_per_character[character_id][emotion_id] = character_sprites[i].emotions.size() - 1;


func next() -> void:
	if text_animation != null and text_animation.is_running():
		skip_text_animation();
		return;
	
	current_line += 1;
	if current_line >= dialogue_array.size():
		dialogue_finished.emit();
		return;
	
	var dialogue_line = dialogue_array[current_line];
	var cur_char = dialogue_line[0];
	var cur_emote_idx = emote_idxs_per_character[cur_char][dialogue_line[1]];
	
	node_per_character[cur_char].display_emotion(cur_emote_idx);
	speaker.text = name_per_character[cur_char];
	dialogue_text.text = dialogue_line[2];
	
	var stream : AudioStream;
	match typeof(voices_per_character[cur_char]):
		TYPE_ARRAY:
			stream = Sounds.get_stream_by_id(voices_per_character[cur_char].pick_random())
		TYPE_INT:
			stream = Sounds.get_stream_by_id(voices_per_character[cur_char])
		_:
			stream = null;
	
	audio_player.stream = stream;
	audio_player.play();
	
	nudge_character(idx_per_character[cur_char]);
	play_text_animation();


func nudge_character(idx: int) -> void:
	var tween := character_tweens[idx];
	if tween != null:
		tween.kill();
	tween = create_tween();
	
	tween.tween_property(character_sprites[idx], ^"position", normal_positions[idx] + SPEAK_JUMP, 0.1);
	tween.tween_property(character_sprites[idx], ^"position", normal_positions[idx], 0.1);
	
	character_tweens[idx] = tween;


func skip_text_animation() -> void:
	if text_animation != null:
		text_animation.kill();
	
	dialogue_text.visible_ratio = 1.0;


func play_text_animation() -> void:
	if text_animation != null:
		text_animation.kill();
	text_animation = create_tween();
	
	var char_count = dialogue_text.text.length();
	
	text_animation.tween_property(dialogue_text, ^"visible_characters", char_count, 0.05 * char_count);
