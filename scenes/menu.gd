extends Control


@onready var start_btn := $Start;


func _ready() -> void:
	start_btn.pressed.connect(start_game)


func _process(delta: float) -> void:
	const rot_speed = 0.05;
	
	var tomatocenter : Vector2 = get_viewport().size / 2;
	var offset : Vector2 = $TextureRect.position - tomatocenter;
	$TextureRect.position = offset.rotated(rot_speed * delta) + tomatocenter;
	$TextureRect.rotation += rot_speed * delta;


func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn");
