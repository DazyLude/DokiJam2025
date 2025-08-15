class_name Trail
extends Line2D


const MAX_POINTS: int = 100
@onready var curve := Curve2D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Not used


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Add a point at the parent position
	curve.add_point(get_parent().position)
	# Remove any points past the max
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	# Assign the points to the line
	points = curve.get_baked_points()

## stop the trail from generating and delete
func stop_trail() -> void:
	# Stop processing the trail
	set_process(false)
	# Create a new tween
	var tween := get_tree().create_tween()
	# Set tween properties to fade out
	tween.tween_property(self, "modulate:a", 0.0, 3.0)
	# Wait for the Tween to finish, then delete the instance
	await tween.finished
	queue_free()

## create a new trail instance
static func create_trail() -> Trail:
	var scene = preload("res://scenes/player/player_trail.tscn")
	return scene.instantiate()
