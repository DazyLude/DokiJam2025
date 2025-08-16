extends Control


signal dialogue_finished;


enum {
	LEFT,
	RIGHT
}


@onready var character_sprites : Array[SpriteEmotional] = [$CharacterLeft, $CharacterRight, $Character3]; # xdd
@onready var dialogue_text = $TextBox/Text;
@onready var speaker = $TextBox/Speaker;
@onready var audio = [$AudioStreamPlayer, $AudioStreamPlayerDragoon, $AudioStreamPlayerDragoon]; # xddd

var text_animation : Tween;
var playing_animations : bool = false;
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
	character_tweens.resize(character_sprites.size());
	normal_positions.resize(character_sprites.size());
	for i in character_sprites.size():
		normal_positions[i] = character_sprites[i].position;


func setup_ith_sprite(i: int, sprite: Sprite2D) -> void:
	match i:
		0: setup_left_sprite(sprite);
		1: setup_right_sprite(sprite);
		2: setup_centered_sprite(sprite);
	
	normal_positions[i] = sprite.position;


func setup_left_sprite(sprite: Sprite2D) -> void:
	sprite.position = get_left_pos(sprite);


func setup_right_sprite(sprite: Sprite2D) -> void:
	sprite.position = get_right_pos(sprite);


func setup_centered_sprite(sprite: Sprite2D) -> void:
	sprite.position = get_centered_pos(sprite);


func get_centered_pos(sprite: Sprite2D) -> Vector2:
	return (get_viewport_rect().size - sprite.get_rect().size * sprite.scale) * Vector2(0.5, 1.0) - SPEAK_JUMP;


func get_left_pos(sprite: Sprite2D) -> Vector2:
	return (get_viewport_rect().size - sprite.get_rect().size * sprite.scale ) * Vector2(0, 1.0) - SPEAK_JUMP;


func get_right_pos(sprite: Sprite2D) -> Vector2:
	return (get_viewport_rect().size - sprite.get_rect().size * sprite.scale) - SPEAK_JUMP;


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"intermission_next"):
		next();


func play_dialogue(data: Dictionary) -> void:
	setup_characters(data["characters"]);
	dialogue_array = data["dialogue"];
	current_line = -1;
	next();


func setup_characters(characters: Array) -> void:
	for ch in character_sprites:
		ch.hide();
	
	$Explosion.hide();
	
	for i in characters.size():
		var character_id = characters[i];
		
		node_per_character[character_id] = character_sprites[i];
		emote_idxs_per_character[character_id] = {};
		
		var character_data = IntermissionData.character_data[characters[i]];
		name_per_character[character_id] = character_data["name"];
		character_sprites[i].show();
		var sprite_path = character_data["base"];
		character_sprites[i].texture = load(sprite_path) if sprite_path != "" else null;
		character_sprites[i].emotions.clear();
		idx_per_character[character_id] = i;
		voices_per_character[character_id] = character_data.get("speech", null);
		
		for emotion_id in character_data["emotions"]:
			var emotion_path = character_data["emotions"][emotion_id];
			character_sprites[i].emotions.push_back(load(emotion_path) if emotion_path != "" else null);
			emote_idxs_per_character[character_id][emotion_id] = character_sprites[i].emotions.size() - 1;
		
		setup_ith_sprite(i, character_sprites[i])


func next() -> void:
	if playing_animations:
		return;
	
	if text_animation != null and text_animation.is_running():
		skip_text_animation();
		return;
	
	playing_animations = true;
	
	current_line += 1;
	if current_line >= dialogue_array.size():
		dialogue_finished.emit();
		return;
	
	var dialogue_line = dialogue_array[current_line];
	var cur_char = dialogue_line[0];
	var char_idx = idx_per_character[cur_char];
	
	speaker.text = name_per_character[cur_char];
	dialogue_text.visible_characters = 0;
	dialogue_text.text = dialogue_line[1];
	
	var stream : AudioStream;
	var meta = dialogue_line[2] if dialogue_line.size() == 3 else {};
	
	# other things
	if meta.get("flip", false):
		flip(char_idx);
	
	# play animations
	match meta:
		_ when meta.has("swap"):
			await play_explosion_animation_start()
			var new_character = meta["swap"];
			var character_data = IntermissionData.character_data[new_character];
			var sprite_path = character_data["base"];
			character_sprites[char_idx].texture = load(sprite_path) if sprite_path != "" else null;
			setup_ith_sprite(LEFT, character_sprites[char_idx]);
			play_expolosion_animation_end()
		
		_ when meta.has("walk in"):
			var new_character = meta["walk in"]["character"];
			var character_data = IntermissionData.character_data[new_character];
			setup_ith_sprite(char_idx, character_sprites[char_idx]);
			walk_in_animation_setup(meta["walk in"]["side"], char_idx);
			character_sprites[char_idx].texture = load(character_data["base"]);
			await play_walk_in_animation(meta["walk in"]["side"], char_idx);
		
		_ when meta.has("hide"):
			if meta["hide"]:
				await hide_character(char_idx);
			else:
				await unhide_character(char_idx);
		_ when not meta.get("skip", false) and not meta.get("no nudge", false):
			nudge_character(char_idx);
	
	# play audio
	if meta.has("sfx"):
		stream = Sounds.get_stream_by_id(meta["sfx"]);
	else:
		match typeof(voices_per_character[cur_char]):
			TYPE_ARRAY:
				stream = Sounds.get_stream_by_id(voices_per_character[cur_char].pick_random())
			TYPE_INT:
				stream = Sounds.get_stream_by_id(voices_per_character[cur_char])
			_:
				stream = null;
	
	audio[char_idx].stream = stream;
	audio[char_idx].play();
	
	playing_animations = false;
	
	if meta.get("skip", false):
		next();
		return;
	
	play_text_animation();


func get_fresh_character_tween(idx: int) -> Tween:
	var tween := character_tweens[idx];
	if tween != null:
		tween.kill();
	tween = create_tween();
	character_tweens[idx] = tween;
	return tween;


func nudge_character(idx: int) -> void:
	var tween := get_fresh_character_tween(idx);
	
	tween.tween_property(character_sprites[idx], ^"position", normal_positions[idx] + SPEAK_JUMP, 0.1);
	tween.tween_property(character_sprites[idx], ^"position", normal_positions[idx], 0.1);
	
	await tween.finished;


func skip_text_animation() -> void:
	if text_animation != null:
		text_animation.kill();
	
	dialogue_text.visible_ratio = 1.0;


func play_text_animation() -> void:
	if text_animation != null:
		text_animation.kill();
	text_animation = create_tween();
	
	var char_count = dialogue_text.text.length();
	
	text_animation.tween_property(dialogue_text, ^"visible_characters", char_count, 0.02 * char_count);


func play_explosion_animation_start() -> void:
	var tween = create_tween();
	
	tween.set_parallel();
	tween.set_ease(Tween.EASE_OUT);
	tween.set_trans(Tween.TRANS_EXPO);
	
	$Explosion.scale = Vector2(0.1, 0.1)
	$Explosion.rotation = 0;
	$Explosion.material.set_shader_parameter("color_filter", Vector4(1.0, 1.0, 1.0, 1.0));
	$Explosion.show();
	
	tween.tween_property($Explosion, ^"scale", Vector2(0.6, 0.6), 0.1);
	tween.tween_property($Explosion, ^"rotation", 0.2, 0.1);
	
	await tween.finished;


func play_expolosion_animation_end() -> void:
	var tween = create_tween();
	
	tween.set_parallel();
	tween.set_ease(Tween.EASE_OUT);
	tween.set_trans(Tween.TRANS_LINEAR);
	
	tween.tween_property($Explosion, ^"rotation", 0.4, 1.5);
	tween.tween_property($Explosion, ^"scale", Vector2(0.5, 0.5), 1.5);
	tween.tween_property($Explosion.material, ^"shader_parameter/color_filter", Vector4(1.0, 1.0, 1.0, 0.0), 1.5);
	
	await tween.finished;
	$Explosion.hide();


func walk_in_animation_setup(side: int, idx: int) -> void:
	pass;


func play_walk_in_animation(side: int, idx: int) -> void:
	var tween := get_fresh_character_tween(idx);
	var sprite = character_sprites[idx];
	var sprite_final_pos = get_left_pos(sprite) if side == LEFT else get_right_pos(sprite);
	var width = sprite.get_rect().size * sprite.scale * Vector2(1.0, 0.0);
	
	normal_positions[idx] = sprite_final_pos;
	
	var sprite_starting_pos = get_left_pos(sprite) if side == LEFT else get_right_pos(sprite);
	sprite_starting_pos += -width if side == LEFT else width;
	
	sprite.position = sprite_starting_pos;
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(sprite, ^"position", sprite_final_pos, 0.5);
	
	await tween.finished;


func flip(idx: int) -> void:
	character_sprites[idx].flip_h = not character_sprites[idx].flip_h;


func hide_character(idx: int) -> void:
	var tween := get_fresh_character_tween(idx);
	var sprite = character_sprites[idx];
	var height = sprite.get_rect().size * sprite.scale * Vector2(0.0, 1.0);
	
	var sprite_final_pos = get_centered_pos(sprite) + height * Vector2(1.0, 0.20);
	normal_positions[idx] = sprite_final_pos;
	
	var down_pos = sprite.position + height;
	var down_center_pos = sprite_final_pos + height;
	
	# go down
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(sprite, ^"position", down_pos, 0.5);
	tween.tween_property(sprite, ^"position", down_center_pos, 0.1);
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(sprite, ^"position", sprite_final_pos, 0.5);
	
	await tween.finished;


func unhide_character(idx: int) -> void:
	var tween := get_fresh_character_tween(idx);
	var sprite = character_sprites[idx];
	var sprite_final_pos = get_centered_pos(sprite);
	normal_positions[idx] = sprite_final_pos;
	
	# pop up
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
	tween.tween_property(sprite, ^"position", sprite_final_pos, 0.3);
	
	await tween.finished;
