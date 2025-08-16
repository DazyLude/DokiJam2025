extends Control


var on_continue_override : Callable;

# Dictionary of node names
static var containers: Dictionary = {
	"speed": "SpeedContainer",
	"armor": "ArmorContainer",
	"stamina": "StaminaContainer",
	"loudness": "LoudnessContainer",
	"bounce": "BounceContainer",
	"supps": "SuppsContainer",
}

static var backgrounds: Dictionary[String, Dictionary] = {
	"tomato fields": {
		"path": "res://assets/stages/farm/tomato_farm_clouds.png",
		"offset_x": 0,
		"offset_y": -90
	},
	"city": {
		"path": "res://assets/stages/city/shopping_street.png",
		"offset_x": 660,
		"offset_y": 90
	},
	"city2": {
		"path": "res://assets/stages/city/city_street.png",
		"offset_x": 100,
		"offset_y": 90
	},
	"backstage": {
		"path": "res://assets/stages/backstage/backstage.png",
		"offset_x": -550,
		"offset_y": 90
	},
	"stage": {
		"path": "res://assets/stages/stage/stage.png",
		"offset_x": -50,
		"offset_y": 90
	}
}

# Reference the GameState upgrade data
var upgrades = GameState.upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.volume_linear = lerp(0.6, 2.0, GameState.upgrades.get_upgrade_level(Upgrade.VOCAL) / 8.0);
	var background_data = backgrounds[GameState.current_stage.stage_name]
	# Change background texture
	$ShopBackground.texture = load(background_data["path"])
	$ShopBackground.offset.x = background_data["offset_x"]
	$ShopBackground.offset.y = background_data["offset_y"]
	
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
	var available_upgrades = upgrades.get_unlocked()
	var container = get_node(containers[container_name] + "/UpgradeCost")
	if upgrades.check_upgrade_maxed(upgrade_id):
		get_node(containers[container_name] + "/UpgradeButton").disabled = true
		container.text = "MAX"
	else:
		if upgrade_id in available_upgrades:
			container.text = "x%d" % upgrades.get_upgrade_price(upgrade_id)
		else:
			get_node(containers[container_name] + "/UpgradeButton").disabled = true
			#get_node(containers[container_name] + "/CoinIcon").visible = false
			container.text = "N/A"

func update_doki_coins() -> void:
	get_node("CoinContainer/CoinCount").text = "x%d" % GameState.dokicoins

## tries to buy an upgrade
func button_buy_upgrade(container_name: String, upgrade_id: int) -> void:
	#Make sure the player has enough coins
	if upgrades.check_upgrade_affordable(upgrade_id):
		upgrades.purchase_upgrade(upgrade_id)
		update_upgrade_cost(container_name, upgrade_id)
		update_doki_coins()


## resume the game
func _on_continue_pressed() -> void:
	if on_continue_override.is_null():
		GameState.restart();
		get_tree().change_scene_to_file("res://scenes/game.tscn");
	else:
		on_continue_override.call();


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
	$AudioStreamPlayer.volume_linear = lerp(0.6, 2.0, GameState.upgrades.get_upgrade_level(Upgrade.VOCAL) / 8.0);
	$AudioStreamPlayer.stream = Sounds.get_stream_by_id(Sounds.ID.SFX_1KMIC);
	$AudioStreamPlayer.play();

## upgrade character bounce
func _on_bounce_pressed() -> void:
	button_buy_upgrade("bounce", upgrades.WINGS)


func _on_supps_pressed() -> void:
	button_buy_upgrade("supps", upgrades.SUPPS)


## select tomato skinsuit
func _on_skin_tomato_pressed() -> void:
	#print("Select Tomato Skinsuit")
	GameState.selected_skinsuit = upgrades.SKINSUIT_TOMATO

## select crowki skinsuit
func _on_skin_crowki_pressed() -> void:
	#print("Select Crowki Skinsuit")
	GameState.selected_skinsuit = upgrades.SKINSUIT_CROWKI

## select retro skinsuit
func _on_skin_retro_pressed() -> void:
	#print("Select Retro Skinsuit")
	GameState.selected_skinsuit = upgrades.SKINSUIT_RETRO

## select bounty skinsuit
func _on_skin_bounty_pressed() -> void:
	#print("Select Bounty Skinsuit")
	GameState.selected_skinsuit = upgrades.SKINSUIT_BOUNTY
