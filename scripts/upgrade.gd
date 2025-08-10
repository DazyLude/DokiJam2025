class_name Upgrade extends RefCounted


enum {
	TYPE_INCREMENTAL,
	TYPE_ONE_OFF,
}


enum {
	COFFEE,
	SUPPS,
	WINGS,
	KETCHUP_TANK,
	ARMOR,
	VOCAL,
	BOUNCE,
	
	SKINSUIT_TOMATO,
	SKINSUIT_CROWKI,
	SKINSUIT_RETRO,
	SKINSUIT_BOUNTY,
}

# once again, pretty JSONable way to hold data
static var upgrade_metadata : Dictionary[int, Dictionary] = {
	COFFEE: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	ARMOR: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	KETCHUP_TANK: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	VOCAL: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	BOUNCE: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	WINGS: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "city",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	SUPPS: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [1.0, 4.0, 15.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	SKINSUIT_TOMATO: {
		"type": TYPE_ONE_OFF,
		"autounlock": "tomato fields", # String (stage name)
		"base": "res://assets/skinsuits/tomato/tomato_base.png",
		"emotions": [
			"res://assets/skinsuits/tomato/tomato_neutral.png",
			"res://assets/skinsuits/tomato/tomato_hurt.png",
			"res://assets/skinsuits/tomato/tomato_tired.png",
		],
	},
	SKINSUIT_CROWKI: {
		"type": TYPE_ONE_OFF,
		"autounlock": "tomato fields", # String (stage name)
		"base": "res://assets/skinsuits/crowki/crowki_base.png",
		"emotions": [
			"res://assets/skinsuits/crowki/crowki_neutral.png",
			"res://assets/skinsuits/crowki/crowki_hurt.png",
			"res://assets/skinsuits/crowki/crowki_tired.png",
		],
	},
	SKINSUIT_RETRO: {
		"type": TYPE_ONE_OFF,
		"autounlock": "tomato fields", # String (stage name)
		"base": "res://assets/skinsuits/tomato/tomato_base.png",
		"emotions": [
			"res://assets/skinsuits/tomato/tomato_neutral.png",
			"res://assets/skinsuits/tomato/tomato_tired.png",
			"res://assets/skinsuits/tomato/tomato_hurt.png",
		],
	},
	SKINSUIT_BOUNTY: {
		"type": TYPE_ONE_OFF,
		"autounlock": "tomato fields", # String (stage name)
		"base": "res://assets/skinsuits/tomato/tomato_base.png",
		"emotions": [
			"res://assets/skinsuits/tomato/tomato_neutral.png",
			"res://assets/skinsuits/tomato/tomato_tired.png",
			"res://assets/skinsuits/tomato/tomato_hurt.png",
		],
	}
}


# gamestate specific data is held in a dictionary
# key is the upgrade id (from enum above)
# the value is a level the upgrade is at
var passed_stages : Array[String] = [];
var current_upgrades : Dictionary[int, int] = {}

## initializes the values of the current upgrades
func _init() -> void:
	current_upgrades = {
		COFFEE: 0,
		ARMOR: 0,
		KETCHUP_TANK: 0,
		VOCAL: 0,
		BOUNCE: 0,
	};


## checks whether upgrade has been acquired
func check_upgrade(upgrade_id: int) -> bool:
	return current_upgrades.has(upgrade_id) and current_upgrades[upgrade_id] != 0;


## returns a specific value from the upgrade metadata dictionary
func get_upgrade_data(upgrade_id, data_key, default=-1):
	var upgrade_data: Dictionary = upgrade_metadata.get(upgrade_id, 0)
	return upgrade_data.get(data_key, default)


## returns the upgrade's current level
func get_upgrade_level(upgrade_id: int) -> int:
	return current_upgrades.get(upgrade_id, 0);


## returns ids of all upgrades that should be available in the shop
func get_unlocked() -> Array[int]:
	var result : Array[int];
	
	for upgrade in upgrade_metadata:
		var data = upgrade_metadata[upgrade];
		var shop_unlock = data.get("shop_unlock", "")
		if shop_unlock == "" or passed_stages.has(shop_unlock):
			result.push_back(upgrade);
	
	return result; 


## returns the cost of the current level of an upgrade
func get_upgrade_price(upgrade_id: int, upgrade_level: int=get_upgrade_level(upgrade_id)) -> float:
	var cost: Array = get_upgrade_data(upgrade_id, "cost", [-1])
	if check_upgrade_maxed(upgrade_id):
		return -1
	else:
		return cost[upgrade_level]


## increases the level of the provided upgrade by one
func increase_level(upgrade_id: int) -> void:
	current_upgrades[upgrade_id] = current_upgrades.get(upgrade_id, 0) + 1;


## returns if an upgrade is max level
func check_upgrade_maxed(upgrade_id: int) -> bool:
	var max_level = get_upgrade_data(upgrade_id, "max level")
	return get_upgrade_level(upgrade_id) >= max_level


## returns if an upgrade can be purchased
func check_upgrade_affordable(upgrade_id: int) -> bool:
	return get_upgrade_price(upgrade_id) <= GameState.dokicoins


func purchase_upgrade(upgrade_id: int) -> void:
	#LMG Note: Re-add cost once upgrade_data is fixed
	var cost = get_upgrade_price(upgrade_id)
	increase_level(upgrade_id)
	GameState.dokicoins -= cost


## unlocks upgrades that should be unlocked when reaching the argument stage.
## buys 1 level of upgrades marked as "autounlocked" at this stage.
func check_for_unlocks(stage_name: String) -> void:
	if stage_name == "" or passed_stages.has(stage_name):
		return;
	
	passed_stages.push_back(stage_name);
	
	for upgrade in upgrade_metadata:
		var data = upgrade_metadata[upgrade];
		if data.get("autounlock", "") == stage_name:
			increase_level(upgrade);
