extends Node2D
class_name GenericObstacle


var offset : Vector2 :
	set(v):
		$Sprite2D.position = v;
		$StaticBody2D.position = v;


func flip() -> void:
	scale *= Vector2(-1.0, 1.0);
