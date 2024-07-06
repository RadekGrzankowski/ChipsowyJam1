extends Node3D
var format_gold_stats: String = "PLAYER 1 GOLD: %s\nPLAYER 2(AI) GOLD: %s"
var format_minions_top: String = "P1 MINIONS TOP: %s\nP2 MINIONS TOP: %s"
var format_minions_mid: String = "P1 MINIONS MID: %s\nP2 MINIONS MID: %s"
var format_minions_bot: String = "P1 MINIONS BOT: %s\nP2 MINIONS BOT: %s"

var actual_gold_stats: String
var actual_minions_top: String
var actual_minions_mid: String
var actual_minions_bot: String

@export var upgrade_info_panel: Panel
@onready var upgrades_ui: CanvasLayer = $HUD/UpgradesUI

@onready var gold_label: Label = $HUD/Labels/GoldLabel
@onready var top_minions_label: Label = $HUD/Labels/TopMinions
@onready var mid_minions_label: Label = $HUD/Labels/MidMinions
@onready var bot_minions_label: Label = $HUD/Labels/BotMinions

@onready var shop_ui_anim: AnimationPlayer = $HUD/CanvasLayer/UI/AnimationPlayer
@onready var shop_ui: Control = $HUD/CanvasLayer/UI

@export var tower_upgrades_array: Array[Resource]
@export var barrack_upgrades_array: Array[Resource]
@export var nexus_upgrades_array: Array[Resource]

func _process(delta):
	if Input.is_action_just_pressed("open_upgrades"):
		if upgrades_ui.visible == false:
			upgrades_ui.visible = true
		else:
			upgrades_ui.visible = false
			
	actual_gold_stats = format_gold_stats % [Game.player1_gold, Game.player2_gold]
	actual_minions_top = format_minions_top % [Game.player1_minions_top, Game.player2_minions_top]
	actual_minions_mid = format_minions_mid % [Game.player1_minions_mid, Game.player2_minions_mid]
	actual_minions_bot = format_minions_bot % [Game.player1_minions_bot, Game.player2_minions_bot]
	
	gold_label.text = actual_gold_stats
	top_minions_label.text = actual_minions_top
	mid_minions_label.text = actual_minions_mid
	bot_minions_label.text = actual_minions_bot

func _on_exit_button_pressed():
	upgrades_ui.visible = false

func _upgrade_tower(lane: String, buff_type_of: String, node_type_of: String, value: int, level_of_upgrade: int):
	Game.player1_gold -= 100
	var upgrade_string = ""
	var node_string = ""
	
	upgrade_string = "additional_player1_"+lane+"_tower_"+buff_type_of
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

func upgrade_barracks(level: int, cost: int):
	Game.player1_gold -= cost
	Game.player1_barracks_level += 1
	var node_string = ""
	node_string = "HUD/UpgradesUI/NexusPanel/Upgrades/HBoxContainer/BarrackLevels/BarrackUpgrade"
	if level < 4:
		var curr_node = node_string + str(level)
		level += 1
		var next_node = node_string + str(level)
		get_node(next_node).disabled = false
		get_node(curr_node).disabled = true
	else:
		var curr_node = node_string + str(level)
		get_node(curr_node).disabled = true

func _on_upgrade_button_mouse_entered(type: String, lane: String, tier: int):
	upgrade_info_panel.visible = true
	## The upgrade info box should appear near the mouse
	match type:
		"tower":
			upgrade_info_panel.get_node("Title").text = type.capitalize() + " " + lane.capitalize() + " Lane \nUpgrade the building to Tier " + str(tier)
			match lane:
				"top":
					upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/TowerUpgrades/TopTower").position - Vector2(280, 125)
				"mid":
					upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/TowerUpgrades/MidTower").position - Vector2(280, 125)
				"bot":
					upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/TowerUpgrades/BotTower").position -  Vector2(280, 125)
		"barrack":
			upgrade_info_panel.get_node("Title").text = type.capitalize() + " " + lane.capitalize() + " Lane \nUpgrade the building to Tier " + str(tier)
			match lane:
				"top":
					upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/BarrackUpgrades/TopBarrack").position - Vector2(-60, 125)
				"mid":
					upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/BarrackUpgrades/MidBarrack").position - Vector2(-60, 125)
				"bot":
					upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/BarrackUpgrades/BotBarrack").position - Vector2(-60, 125)
		"nexus":
			upgrade_info_panel.get_node("Title").text = type.capitalize() + "\nUpgrade the building to Tier " + str(tier)
			upgrade_info_panel.position = get_node("HUD/UpgradesUI/BackgroundPanel/HBoxContainer/NexusUpgrades/Nexus").position - Vector2(-400, 0)

func _on_upgrade_button_mouse_exited():
	upgrade_info_panel.visible = false
	
	
func _on_upgrade_button_pressed(type: String, lane: String, tier: int):
	var node_string = ""
	node_string = "HUD/UpgradesUI/BackgroundPanel/HBoxContainer/"+str(type).capitalize()+"Upgrades/"+str(lane).capitalize()+str(type).capitalize()
	var button = get_node(node_string)
	print(button)
	#print(type, " ", lane, " ", tier)
