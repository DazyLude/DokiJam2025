extends TextureButton


var master_bus_idx = AudioServer.get_bus_index(&"Master");


func _ready() -> void:
	pressed.connect(switch_sound);
	update_textures();


func switch_sound() -> void:
	AudioServer.set_bus_mute(master_bus_idx, not AudioServer.is_bus_mute(master_bus_idx));
	update_textures();


func update_textures() -> void:
	var specifier = "off" if AudioServer.is_bus_mute(master_bus_idx) else "on";
	
	texture_normal = load("res://assets/buttons/sound_%s.png" % specifier);
	texture_pressed = load("res://assets/buttons/sound_%s_clicked.png" % specifier);
	texture_hover = load("res://assets/buttons/sound_%s_hover.png" % specifier);
