extends Node2D
class_name PickupItem


var just_spawned = true;
var data : PickupItemData = null;
@onready var area : Area2D = $Area2D;


func _ready() -> void:
	render_new_data(data);
	area.body_entered.connect(on_contact);
	
	just_spawned = true;
	# without this and the same thing in the _physics_process upward movement doesn't trigger for some godforsaken reason
	area.set_collision_mask_value(1, true); 


func _physics_process(delta: float) -> void:
	if area.get_collision_mask_value(1): # this is xdd
		if not area.get_overlapping_bodies().is_empty():
			position -= Vector2(0.0, 50.0);
			print("collision detected")
		else:
			area.set_collision_mask_value(1, false);
	
	if just_spawned:
		just_spawned = false;
		# without this and the same thing in the _ready upward movement doesn't trigger for some godforsaken reason
		area.set_collision_mask_value(1, true);


func render_new_data(new_data: PickupItemData) -> void:
	if data != null:
		show();
		data = new_data;
		$Sprite2D.texture = data.texture;
		$Sprite2D.scale = data.area_size / data.texture.get_size();
		($Area2D/CollisionShape2D.shape as RectangleShape2D).size = data.area_size;


func on_contact(_body: Node2D) -> void:
	if visible and not area.get_collision_mask_value(1):
		hide();
		data.effect.call();
