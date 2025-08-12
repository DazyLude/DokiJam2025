@tool
extends Node2D


const DEFAULT_X_OFFSET : float = 750.0;
const DEFAULT_SCALE := Vector2(0.1, 0.1);
const DEFAULT_TEXTURE : Texture2D = preload("res://assets/skinsuits/wing.png");

const FLAP_TIME := 0.2;
const FLAP_AMPLITUDE := -0.2;


# this is not political I swear
var left_wings : Array[Sprite2D];
var right_wings : Array[Sprite2D];

var wings_on_display : int = 0;

var wing_tweens : Array[Tween];


func flap() -> void:
	for w in wing_tweens:
		if w != null:
			w.kill();
	
	wing_tweens.resize(wings_on_display);
	
	for i in wings_on_display:
		var wings_tween = create_tween();
		
		var pair = get_ith_pair(i);
		var angle = get_pairs_default_angle(i);
		
		wings_tween.tween_method(set_pairs_angle.bind(pair), angle, angle - FLAP_AMPLITUDE, FLAP_TIME)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_CUBIC);
		wings_tween.tween_method(set_pairs_angle.bind(pair), angle - FLAP_AMPLITUDE, angle, FLAP_TIME)\
			.set_trans(Tween.TRANS_LINEAR);
		
		wing_tweens[i] = wings_tween;


func update_wings_count(count: int) -> void:
	if wings_on_display == count:
		return;
	
	if wings_on_display < count:
		remove_all(); # sets wings_on_display to 0
	
	for i in count - wings_on_display:
		get_ith_pair(i);
	
	wings_on_display = count;


func get_ith_pair(i: int) -> Array[Sprite2D]:
	if i >= left_wings.size():
		return get_new_pair(i);
	else:
		var left = left_wings[i];
		var right = right_wings[i];
		left.show();
		right.show();
		
		var pair : Array[Sprite2D] = [left, right];
		
		return pair;


func get_new_pair(ith: int) -> Array[Sprite2D]:
	var left_wing = Sprite2D.new();
	left_wing.texture = DEFAULT_TEXTURE;
	left_wing.offset = Vector2(-DEFAULT_X_OFFSET, 0.0);
	left_wing.scale = DEFAULT_SCALE;
	add_child(left_wing);
	
	var right_wing = Sprite2D.new();
	right_wing.flip_h = true;
	right_wing.texture = DEFAULT_TEXTURE;
	right_wing.offset = Vector2(DEFAULT_X_OFFSET, 0.0);
	right_wing.scale = DEFAULT_SCALE;
	add_child(right_wing);
	
	left_wings.push_back(left_wing);
	right_wings.push_back(right_wing);
	
	var pair : Array[Sprite2D] = [left_wing, right_wing];
	var angle = get_pairs_default_angle(ith);
	set_pairs_angle(angle, pair);
	return pair;


func remove_all() -> void:
	wings_on_display = 0;
	
	for wing in left_wings:
		wing.hide();
	
	for wing in left_wings:
		wing.hide();


func get_pairs_default_angle(pair_n: int):
	var alternating_minus := pair_n % 2 * 2 - 1;
	return 0.2 * pair_n * alternating_minus


func set_pairs_angle(wings_angle: float, wings: Array) -> void:
	wings[0].rotation = -wings_angle;
	wings[1].rotation = wings_angle;
