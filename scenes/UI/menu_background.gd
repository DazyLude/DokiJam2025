extends Control


@onready var base : Sprite2D = $TomatoBase;
var texture = CompressedTexture2D
var tomato_diff := Vector2(150, 150);

var tomato_refs : Dictionary[Vector2i, Sprite2D] = {};
var animation_track_ids : Dictionary[Vector2i, Vector2i] = {};


func _ready() -> void:
	item_rect_changed.connect(setup);
	setup();
	
	$AnimationPlayer.play(&"tomato_fly");


func setup() -> void:
	var animation : Animation = $AnimationPlayer.get_animation(&"tomato_fly");
	
	var x_tomato_count = size.x / tomato_diff.x + 1;
	var y_tomato_count = size.y / tomato_diff.y + 1;
	
	for x in range(-2, x_tomato_count):
		for y in range(-2, y_tomato_count):
			var clone_coords = Vector2i(x, y);
			if not tomato_refs.has(clone_coords):
				var clone = base.duplicate();
				clone.visible = true;
				clone.position = tomato_diff * Vector2(clone_coords);
				
				add_child(clone);
				
				var idx = animation.add_track(Animation.TYPE_VALUE);
				animation.track_set_path(idx, clone.get_name() + ":position");
				animation.track_set_interpolation_loop_wrap(idx, false);
				animation.track_insert_key(idx, 0.0, clone.position);
				animation.track_insert_key(idx, 4.0, clone.position + tomato_diff);
				
				var rot_idx = animation.add_track(Animation.TYPE_VALUE);
				animation.track_set_path(rot_idx, clone.get_name() + ":rotation");
				animation.track_set_interpolation_loop_wrap(rot_idx, false);
				animation.track_insert_key(rot_idx, 0.0, 0.0);
				animation.track_insert_key(rot_idx, 4.0, 2 * PI);
				
				tomato_refs[clone_coords] = clone;
				animation_track_ids[clone_coords] = Vector2i(idx, rot_idx);
