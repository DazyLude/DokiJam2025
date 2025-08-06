extends Control

# Dictionary of node names
static var containers: Dictionary = {
	"speed": "SpeedContainer",
	"armor": "ArmorContainer",
	"stamina": "StaminaContainer",
	"loudness": "LoudnessContainer",
	"bounce": "BounceContainer",
}

# Instantiate the upgrade class to access upgrade data
#var upgrades = Upgrade.new()
# Better idea, just reference the GameState instance
var upgrades = GameState.upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update all upgrade cost values
	update_upgrade_cost("speed", upgrades.COFFEE)
	update_upgrade_cost("armor", upgrades.ARMOR)
	update_upgrade_cost("stamina", upgrades.KETCHUP_TANK)
	update_upgrade_cost("loudness", upgrades.VOCAL)
	update_upgrade_cost("bounce", upgrades.BOUNCE)

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta) -> void:
	pass

## update the cost label of a specific upgrade.
func update_upgrade_cost(container_name: String, upgrade_id: int) -> void:
	var container = get_node(containers[container_name] + "/UpgradeCost")
	container.text = "x%d" % upgrades.get_upgrade_price(upgrade_id)

## tries to buy an upgrade
func button_buy_upgrade(container_name: String, upgrade_id: int) -> void:
	#if upgrades.check_upgrade_affordable(upgrades.COFFEE):
	#LMG Note: Placeholder test v
	if upgrades.check_upgrade_affordable(upgrade_id) or true:
		upgrades.purchase_upgrade(upgrade_id)
		update_upgrade_cost(containers[container_name], upgrade_id)


## resume the game
func _on_continue_pressed() -> void:
	print("Continue Pressed") #Debug, remove later
	GameState.restart();
	get_tree().change_scene_to_file("res://scenes/game.tscn");
	#get_tree().change_scene_to_packed(GameState.current_stage);
	#pass # Replace with function body.


## upgrade character speed
func _on_speed_pressed() -> void:
	button_buy_upgrade("speed", upgrades.COFFEE)

## upgrade character armor
func _on_armor_pressed() -> void:
	button_buy_upgrade("armor", upgrades.ARMOR)

## upgrade character stamina
func _on_stamina_pressed() -> void:
	button_buy_upgrade("stamina", upgrades.KETCHUP_TANK)

## upgrade character loudness
func _on_loudness_pressed() -> void:
	button_buy_upgrade("loudness", upgrades.VOCAL)

## upgrade character bounce
func _on_bounce_pressed() -> void:
	button_buy_upgrade("bounce", upgrades.BOUNCE)
