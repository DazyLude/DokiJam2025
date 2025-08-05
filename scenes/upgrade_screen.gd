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
var upgrades = Upgrade.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Update all upgrade cost values
	update_upgrade_cost("speed", upgrades.COFFEE)
	update_upgrade_cost("armor", upgrades.ARMOR)
	update_upgrade_cost("stamina", upgrades.KETCHUP_TANK)
	update_upgrade_cost("loudness", upgrades.VOCAL)
	update_upgrade_cost("bounce", upgrades.BOUNCE)

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta):
	pass

# Updates the cost label of a specific upgrade.
func update_upgrade_cost(container_name: String, upgrade_id: int) -> void:
	var container = get_node(containers[container_name] + "/UpgradeCost")
	container.text = "x" + str(upgrades.get_upgrade_price(upgrade_id))
