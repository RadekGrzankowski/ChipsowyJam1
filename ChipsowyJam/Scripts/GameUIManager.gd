extends Node3D
var format_gold_stats: String = "RED GOLD: %s\nBLUE GOLD: %s"
var format_minions_top: String = "RED MINIONS TOP: %s\nBLUE MINIONS TOP: %s"
var format_minions_mid: String = "RED MINIONS MID: %s\nBLUE MINIONS MID: %s"
var format_minions_bot: String = "RED MINIONS BOT: %s\nBLUE MINIONS BOT: %s"

var actual_gold_stats: String
var actual_minions_top: String
var actual_minions_mid: String
var actual_minions_bot: String

@onready var towers_upgrade_ui: Panel = $HUD/UpgradesUI/TowersPanel
@onready var barracks_upgrade_ui: Panel = $HUD/UpgradesUI/BarracksPanel
@onready var nexus_upgrade_ui: Panel = $HUD/UpgradesUI/NexusPanel
@onready var upgrades_ui: CanvasLayer = $HUD/UpgradesUI

@onready var gold_label: Label = $HUD/Labels/GoldLabel
@onready var top_minions_label: Label = $HUD/Labels/TopMinions
@onready var mid_minions_label: Label = $HUD/Labels/MidMinions
@onready var bot_minions_label: Label = $HUD/Labels/BotMinions

@onready var shop_ui_anim: AnimationPlayer = $HUD/CanvasLayer/UI/AnimationPlayer
@onready var shop_ui: Control = $HUD/CanvasLayer/UI

func _process(delta):
	
	if Input.is_action_just_pressed("open_upgrades"):
		if upgrades_ui.visible == false:
			upgrades_ui.visible = true
		else:
			upgrades_ui.visible = false
	
	actual_gold_stats = format_gold_stats % [Game.red_gold, Game.blue_gold]
	actual_minions_top = format_minions_top % [Game.red_minions_top, Game.blue_minions_top]
	actual_minions_mid = format_minions_mid % [Game.red_minions_mid, Game.blue_minions_mid]
	actual_minions_bot = format_minions_bot % [Game.red_minions_bot, Game.blue_minions_bot]
	
	gold_label.text = actual_gold_stats
	top_minions_label.text = actual_minions_top
	mid_minions_label.text = actual_minions_mid
	bot_minions_label.text = actual_minions_bot
	

func _on_attack_5_pressed():
	Game.additional_blue_minions_dmg += 5
	Game.blue_gold -= 80


func _on_attack_10_pressed():
	Game.additional_blue_minions_dmg += 10
	Game.blue_gold -= 110


func _on_armor_5_pressed():
	Game.additional_blue_minions_armor += 1
	Game.blue_gold -= 50

func _on_armor_10_pressed():
	Game.additional_blue_minions_armor += 3
	Game.blue_gold -= 80

func _upgrade_tower(lane: String, buff_type_of: String, node_type_of: String, value: int, level_of_upgrade: int):
	Game.blue_gold -= 100
	var upgrade_string = ""
	var node_string = ""
	
	upgrade_string = "additional_blue_"+lane+"_tower_"+buff_type_of
	node_string = "HUD/UpgradeControls/"+str(lane).capitalize()+"TowerUpgrades/"+node_type_of+"Upgrades/"+node_type_of+"Upgrade"
	if level_of_upgrade < 4:
		var curr_node = node_string + str(level_of_upgrade)
		level_of_upgrade += 1
		var next_node = node_string + str(level_of_upgrade)
		get_node(next_node).disabled = false
		get_node(curr_node).disabled = true
	else:
		var curr_node = node_string + str(level_of_upgrade)
		get_node(curr_node).disabled = true
		
	Game.set_deferred(upgrade_string, value)

func _on_attack_upgrade_1_pressed(lane: String):
	_upgrade_tower(lane, "damage", "Attack", 10, 1)

func _on_attack_upgrade_2_pressed(lane: String):
	_upgrade_tower(lane, "damage", "Attack", 5, 2)

func _on_attack_upgrade_3_pressed(lane: String):
	_upgrade_tower(lane, "damage", "Attack", 5, 3)

func _on_attack_upgrade_4_pressed(lane: String):
	_upgrade_tower(lane, "damage", "Attack", 5, 4)


func _on_armor_upgrade_1_pressed(lane: String):
	_upgrade_tower(lane, "armor", "Armor", 3, 1)

func _on_armor_upgrade_2_pressed(lane: String):
	_upgrade_tower(lane, "armor", "Armor", 3, 2)

func _on_armor_upgrade_3_pressed(lane: String):
	_upgrade_tower(lane, "armor", "Armor", 3, 3)

func _on_armor_upgrade_4_pressed(lane: String):
	_upgrade_tower(lane, "armor", "Armor", 3, 4)


func _on_towers_button_pressed():
	closeTabs()
	towers_upgrade_ui.visible = true

func _on_barracks_button_pressed():
	closeTabs()
	barracks_upgrade_ui.visible = true

func _on_nexus_button_pressed():
	closeTabs()
	nexus_upgrade_ui.visible = true

func closeTabs():
	nexus_upgrade_ui.visible = false
	barracks_upgrade_ui.visible = false
	towers_upgrade_ui.visible = false

func _on_exit_button_pressed():
	upgrades_ui.visible = false
