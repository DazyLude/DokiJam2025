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
	
	SKINSUIT_TOMATO,
	SKINSUIT_CROWKI,
}

# once again, pretty JSONable way to hold data
static var upgrade_metadata : Dictionary[int, Dictionary] = {
	COFFEE: {
		"type": TYPE_INCREMENTAL,
		# int
		"max level": 4,
		# array with float values
		"cost": [10.0, 20.0, 30.0, 40.0],
		# String (name of a stage, "" or skip for never)
		"autounlock": "",
		# String (name of a stage, "" or skip for always)
		"shop_unlock": "",
	},
	SKINSUIT_TOMATO: {
		"type": TYPE_ONE_OFF,
		"autounlock": "tomato fields", # String (stage name)
	}
}


# gamestate specific data is held in a dictionary
# key is the upgrade id (from enum above)
# the value is a level the upgrade is at
var passed_stages : Array[String] = [];
var current_upgrades : Dictionary[int, int] = {};


## checks whether upgrade has been acquired
func check_upgrade(upgrade_id: int) -> bool:
	return current_upgrades.has(upgrade_id) and current_upgrades[upgrade_id] != 0;


## returns the upgrade's current level
func get_upgrade_level(upgrade_id: int) -> int:
	return current_upgrades.get(upgrade_id, -1);


## returns ids of all upgrades that should be available in the shop
func get_unlocked() -> Array[int]:
	var result : Array[int];
	
	for upgrade in upgrade_metadata:
		var data = upgrade_metadata[upgrade];
		var shop_unlock = data.get("shop_unlock", "")
		if shop_unlock == "" or passed_stages.has(shop_unlock):
			result.push_back(upgrade);
	
	return result; 


## increases the level of the provided upgrade by one
func increase_level(upgrade_id: int) -> void:
	current_upgrades[upgrade_id] = current_upgrades.get(upgrade_id, 0) + 1;


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
