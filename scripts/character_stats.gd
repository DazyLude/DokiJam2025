extends RefCounted
class_name PlayerStats


# more detailed stat explanation in the Player class
var player_torque := 0.0;
var player_fly_strength := 0.0;
var jump_fly_scale := 0.0;
var jump_cost := 0.0;
var hardness := 0.0;
var aeroshape := 0.0;

# physics body properties
var friction := 0.0;
var bounce := 0.0;
var mass := 0.0;
var inertia := 0.0;
var linear_damp := 0.0;
var angular_damp := 0.0;


func reset_to_dict(dict: Dictionary) -> void:
	for property in dict:
		if property in self:
			self.set(property, dict[property]);


func add_dict(dict: Dictionary) -> void:
	for property in dict:
		var bonus_value = dict[property];
		match property:
			"friction":
				friction += bonus_value - bonus_value * friction; # multiplicative stacking
				friction = clampf(friction, 0.0, 1.0);
			"bounce":
				bounce += bonus_value - bonus_value * bounce; # multiplicative stacking
				bounce = clampf(bounce, 0.0, 1.0);
			"jump_cost":
				jump_cost += bonus_value - bonus_value * jump_cost; # multiplicative stacking
				jump_cost = maxf(jump_cost, 0.5);
			_ when property in self:
				self.set(property, self.get(property) + bonus_value);


static func get_latest() -> PlayerStats:
	var stats = PlayerStats.new();
	stats.reset_to_dict(stat_dicts["default"]);
	
	for upgrade in upgrade_stats:
		var upgrade_level = GameState.upgrades.get_upgrade_level(upgrade);
		if upgrade_level == 0:
			continue;
		
		match typeof(upgrade_stats[upgrade]):
			TYPE_ARRAY:
				var upgrade_array : Array = upgrade_stats[upgrade];
				stats.add_dict(upgrade_array[min(upgrade_level - 1, upgrade_array.size() - 1)]);
			TYPE_CALLABLE:
				stats.add_dict(upgrade_stats[upgrade].call(upgrade_level));
			_:
				pass;
	
	return stats;


static var upgrade_stats : Dictionary[int, Variant] = {
	Upgrade.COFFEE : coffee_buff,
	Upgrade.SUPPS : supps_buff,
	Upgrade.WINGS : wings_buff,
	Upgrade.KETCHUP_TANK : null, # managed separately
	Upgrade.ARMOR : armor_buff,
	Upgrade.VOCAL : vocal_buff,
	Upgrade.BOUNCE : null,
}


static func coffee_buff(lvl: int) -> Dictionary:
	return {
		"player_torque": 2.5 * lvl,
		"friction": 0.035 * lvl,
		"mass": 0.15 * lvl,
	}


static func supps_buff(lvl: int) -> Dictionary:
	return {
		"friction": 0.035 * lvl,
		"jump_fly_scale": 0.005 * lvl,
		"mass": -0.15 * lvl, 
	};


static func wings_buff(lvl: int) -> Dictionary:
	return {
		"aeroshape": 1.75 * lvl,
		"jump_cost" : -0.1 * lvl,
	}


static func armor_buff(lvl: int) -> Dictionary:
	return {
		"hardness": 1.0 * lvl,
		"aeroshape": 0.5 * lvl,
		"bounce": 0.01 * lvl,
	}


static func vocal_buff(lvl: int) -> Dictionary:
	return {
		"bounce": 0.025 * lvl,
	} 


const stat_dicts : Dictionary[String, Dictionary] = {
	"default": {
		"player_torque" : 30.0,
		"player_fly_strength" : 1800.0,
		"jump_fly_scale" : 0.35,
		"jump_cost" : 2.0,
		"hardness" : 5.0,
		"aeroshape" : 5.0,
		"friction" : 0.75,
		"bounce" : 0.1,
		"mass" : 10.0,
		"linear_damp" : 0.0,
		"angular_damp" : 0.0,
	},
}
