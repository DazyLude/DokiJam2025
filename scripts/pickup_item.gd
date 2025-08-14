class_name PickupItemData extends RefCounted


enum {
	PLACEMENT_NON_RANDOM,
	PLACEMENT_NORMAL,
}


var texture : Texture2D;
var area_size : Vector2;
var effect: Callable;


static func get_by_name(name: String) -> PickupItemData:
	return from_dict(pickup_item_variants[name]);


static func from_dict(params: Dictionary) -> PickupItemData:
	var data := PickupItemData.new();
	
	data.texture = load(params.get("texture", "res://assets/icons/dokicoin.png"));
	data.area_size = params.get("area size", Vector2(100.0, 100.0));
	data.effect = params.get("effect", Callable());
	
	return data;


# this is harder to JSONize, since it contains callables if you want to make a reskin of an existing item
static var pickup_item_variants : Dictionary[String, Dictionary] = {
	"coin": {
		"texture": "res://assets/icons/dokicoin.png",
		"area size": Vector2(100.0, 100.0),
		"effect": func(): GameState.dokicoins += 1.0,
	},
	"coin_x5": {
		"texture": "res://assets/icons/dokicoin.png",
		"area size": Vector2(150.0, 150.0),
		"effect": func(): GameState.dokicoins += 5.0,
	},
	"ketchup": {
		"texture": "res://assets/icons/stamina_ketchup.png",
		"effect": func(): GameState.juice = move_toward(GameState.juice, GameState.juice_cap, GameState.juice_cap * 0.2),
	},
	"wingbull": {
		"texture": "res://assets/icons/wingbull.png",
		"effect": func(): GameState.player.launch_upward()
	},
	"coffee": {
		"texture": "res://assets/icons/coffee_upgrade.png",
		"effect": func(): GameState.player.launch_forward()
	},
	"supps": {
		"texture": "res://assets/icons/dadsupps.png",
		"effect": func(): GameState.player.apply_supps_buff()
	}
}
