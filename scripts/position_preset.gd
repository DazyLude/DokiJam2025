class_name PositionPreset;


var angle_range := Vector2();
var y_offset_range := Vector2();


func _init(angle: Vector2, y_offset: Vector2) -> void:
	angle_range = angle;
	y_offset_range = y_offset;


static func fixed_angle(angle: float, y_offset: Vector2) -> PositionPreset:
	return PositionPreset.new(Vector2(angle, angle), y_offset);


static func fixed_offset(angle: Vector2, y_offset: float) -> PositionPreset:
	return PositionPreset.new(angle, Vector2(y_offset, y_offset));


static func fixed(angle: float, y_offset: float) -> PositionPreset:
	return PositionPreset.new(Vector2(angle, angle), Vector2(y_offset, y_offset));
