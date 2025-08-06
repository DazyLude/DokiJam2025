extends Node2D
class_name PickupItem


var data : PickupItemData = null;


func _ready() -> void:
	render_new_data(data);
	$Area2D.body_entered.connect(on_contact)


func render_new_data(new_data: PickupItemData) -> void:
	if data != null:
		show();
		data = new_data;
		$Sprite2D.texture = data.texture;
		$Sprite2D.scale = data.area_size / data.texture.get_size();
		($Area2D/CollisionShape2D.shape as RectangleShape2D).size = data.area_size;


func on_contact(_body: Node2D) -> void:
	hide();
	data.effect.call();
	queue_free()
