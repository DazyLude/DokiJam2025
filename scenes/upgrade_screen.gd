extends Control

# Dictionary of node names
static var containers: Dictionary = {
	"speed": "SpeedContainer",
	"armor": "ArmorContainer",
	"stamina": "StaminaContainer",
	"loudness": "LoudnessContainer",
	"bounce": "BounceContainer",
	"supps": "SuppsContainer",
}

# Instantiate the upgrade class to access upgrade data
#var upgrades = Upgrade.new()
# Better idea, just reference the GameState instance
var upgrades = GameState.upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() > 0.33: # play the track with quotes only once in a while to spook players with sudden doki
		Sounds.play_looped(Sounds.ID.MUSIC_UPGRADE_SHOP_THEME);
	else:
		Sounds.play_looped(Sounds.ID.MUSIC_UPGRADE_SHOP_THEME_COOL);
	
	# Update all upgrade cost values
	update_upgrade_cost("speed", upgrades.COFFEE)
	update_upgrade_cost("armor", upgrades.ARMOR)
	update_upgrade_cost("stamina", upgrades.KETCHUP_TANK)
	update_upgrade_cost("loudness", upgrades.VOCAL)
	update_upgrade_cost("bounce", upgrades.WINGS)
	update_upgrade_cost("supps", upgrades.SUPPS)
	update_doki_coins()
	
	# Check Skinsuit status
	if not upgrades.check_upgrade(upgrades.SKINSUIT_CROWKI):
		$SkinsuitContainer/SkinsuitCrowki.disabled = true
	if not upgrades.check_upgrade(upgrades.SKINSUIT_RETRO):
		$SkinsuitContainer/SkinsuitRetro.disabled = true
	if not upgrades.check_upgrade(upgrades.SKINSUIT_BOUNTY):
		$SkinsuitContainer/SkinsuitBounty.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta) -> void:
	pass

## update the cost label of a specific upgrade.
func update_upgrade_cost(container_name: String, upgrade_id: int) -> void:
	var container = get_node(containers[container_name] + "/UpgradeCost")
	if upgrades.check_upgrade_maxed(upgrade_id):
		get_node(containers[container_name] + "/UpgradeButton").disabled = true
		container.text = "MAX"
	else:
		container.text = "x%d" % upgrades.get_upgrade_price(upgrade_id)

func update_doki_coins() -> void:
	#get_node("CoinContainer/CoinCount").text = "x%03d" % GameState.dokicoins
	get_node("CoinContainer/CoinCount").text = "x%d" % GameState.dokicoins

## tries to buy an upgrade
func button_buy_upgrade(container_name: String, upgrade_id: int) -> void:
	#LMG Note: Placeholder test v
	#if upgrades.check_upgrade_affordable(upgrades.COFFEE) or true:
	if upgrades.check_upgrade_affordable(upgrade_id):
		upgrades.purchase_upgrade(upgrade_id)
		update_upgrade_cost(container_name, upgrade_id)
		update_doki_coins()


## resume the game
func _on_continue_pressed() -> void:
	print("Continue Pressed") #Debug, remove later
	GameState.restart();
	get_tree().change_scene_to_file("res://scenes/game.tscn");


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
	button_buy_upgrade("bounce", upgrades.WINGS)


func _on_supps_pressed() -> void:
	button_buy_upgrade("supps", upgrades.SUPPS)


## select tomato skinsuit
func _on_skin_tomato_pressed() -> void:
	print("Select Tomato Skinsuit")
	GameState.selected_skinsuit = upgrades.SKINSUIT_TOMATO

## select crowki skinsuit
func _on_skin_crowki_pressed() -> void:
	print("Select Crowki Skinsuit")
	GameState.selected_skinsuit = upgrades.SKINSUIT_CROWKI

## select retro skinsuit
func _on_skin_retro_pressed() -> void:
	print("Select Retro Skinsuit")
	#GameState.selected_skinsuit = upgrades.SKINSUIT_RETRO

## select bounty skinsuit
func _on_skin_bounty_pressed() -> void:
	print("Select Bounty Skinsuit")
	#GameState.selected_skinsuit = upgrades.SKINSUIT_BOUNTY
