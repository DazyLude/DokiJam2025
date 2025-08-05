extends Control


signal dialogue_finished;


@onready var character_sprites : Array[SpriteEmotional] = [$CharacterLeft, $CharacterRight];
@onready var dialogue_text = $TextBox/Text;
@onready var speaker = $TextBox/Speaker;

var node_per_character := {};
var emote_idxs_per_character := {};
var name_per_character := {};

var dialogue_array := [];
var current_line := -1;


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
		
		for emotion_id in character_data["emotions"]:
			var emotion_path = character_data["emotions"][emotion_id];
			character_sprites[i].emotions.push_back(load(emotion_path));
			emote_idxs_per_character[character_id][emotion_id] = character_sprites[i].emotions.size() - 1;


func next() -> void:
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
	
