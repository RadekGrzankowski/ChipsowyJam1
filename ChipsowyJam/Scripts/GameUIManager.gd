extends Node3D
var format_gold_stats: String = "PLAYER 1 GOLD: %s\nPLAYER 2(AI) GOLD: %s"
var format_minions_top: String = "P1 MINIONS TOP: %s\nP2 MINIONS TOP: %s"
var format_minions_mid: String = "P1 MINIONS MID: %s\nP2 MINIONS MID: %s"
var format_minions_bot: String = "P1 MINIONS BOT: %s\nP2 MINIONS BOT: %s"

var format_upgrade_cost: String = "UPGRADE COST: [b][color=#dbac34]%sG[/color][/b]"
var format_bonus_health: String = "\nHEALTH: %sHP -> [b][color=#53c349]%sHP[/color][/b] ([color=#53c349]+%sHP[/color])"
var format_bonus_damage: String = "\nDAMAGE: %sAD -> [b][color=#fc8f78]%sAD[/color][/b] ([color=#fc8f78]+%sAD[/color])"
var format_bonus_armor: String = "\nARMOR: %sARM -> [b][color=#37b0ec]%sARM[/color][/b] ([color=#37b0ec]+%sARM[/color])"
var format_bonus_speed: String = "\nSPEED: %ss -> [b][color=WHITE]%ss[/color][/b] ([color=WHITE]+%ss[/color])"
var format_bonus_range: String = "\nRANGE: %s -> [b][color=WHITE]%s[/color][/b] ([color=WHITE]+%s[/color])"
var format_bonus_aoe: String = "\nAOE: %s% -> [b][color=WHITE]%s%[/color][/b] ([color=WHITE]+%s%[/color])"
var format_bonus_gold: String = "\nGOLD: %s/%ss -> [b][color=GOLD]%s[/color]/%ss[/b] ([color=GOLD]+%s/%ss[/color])"

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

@onready var top_tower_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/TowerUpgrades/TopTower
@onready var mid_tower_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/TowerUpgrades/MidTower
@onready var bot_tower_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/TowerUpgrades/BotTower
@onready var top_barrack_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/BarrackUpgrades/TopBarrack
@onready var mid_barrack_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/BarrackUpgrades/MidBarrack
@onready var bot_barrack_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/BarrackUpgrades/BotBarrack
@onready var nexus_button : Button = $HUD/UpgradesUI/BackgroundPanel/HBoxContainer/NexusUpgrades/Nexus

var left_the_button: bool = false
var allow_delay: bool = true

func _ready():
	top_tower_button.text = "TOP TOWER UPGRADE TIER 1\nCOST - " + str(tower_upgrades_array[0].upgrade_cost) + "G"
	mid_tower_button.text = "MID TOWER UPGRADE TIER 1\nCOST - " + str(tower_upgrades_array[0].upgrade_cost)+ "G"
	bot_tower_button.text = "BOT TOWER UPGRADE TIER 1\nCOST - " + str(tower_upgrades_array[0].upgrade_cost)+ "G"
	top_barrack_button.text = "TOP BARRACK UPGRADE TIER 1\nCOST - " + str(barrack_upgrades_array[0].upgrade_cost)+ "G"
	mid_barrack_button.text = "MID BARRACK UPGRADE TIER 1\nCOST - " + str(barrack_upgrades_array[0].upgrade_cost)+ "G"
	bot_barrack_button.text = "BOT BARRACK UPGRADE TIER 1\nCOST - " + str(barrack_upgrades_array[0].upgrade_cost)+ "G"
	nexus_button.text = "NEXUS UPGRADE TIER 1\nCOST - " + str(nexus_upgrades_array[0].upgrade_cost)+ "G"

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

func _on_upgrade_button_mouse_entered(type: String, lane: String, tier: int):
	if !allow_delay:
		return
	allow_delay = false
	left_the_button = false
	#Delay before displaying panel
	await get_tree().create_timer(0.3).timeout
	allow_delay = true
	if left_the_button == true:
		return
	var building = get_tree().get_nodes_in_group(lane.capitalize()+type.capitalize())[0]
	var node_string = "HUD/UpgradesUI/BackgroundPanel/HBoxContainer/"+type.capitalize()+"Upgrades/"+lane.capitalize()+type.capitalize()
	upgrade_info_panel.position = $HUD/UpgradesUI/BackgroundPanel.get_global_mouse_position()
	#INFO gets custom upgrade info panel text based on buttons variables
	var _lane : String = "" if lane == "" else lane.capitalize() + " Lane"
	upgrade_info_panel.get_node("Title").text = type.capitalize() + " " + _lane+"\nUpgrade the building to Tier " + str(tier)
	upgrade_info_panel.visible = true
	#INFO gets custom upgrade info description text
	var array_index = tier - 1 
	var array = get(type+"_upgrades_array")
	upgrade_info_panel.get_node("Description").text = format_upgrade_cost % [array[array_index].upgrade_cost]
	var _hp = building.building_health
	var _bonus_hp = array[array_index].bonus_health
	upgrade_info_panel.get_node("Description").text += format_bonus_health % [_hp, _hp + _bonus_hp, _bonus_hp]
	if array[array_index].bonus_damage > 0:
		var _dmg = building.building_damage
		var _bonus_dmg = array[array_index].bonus_damage
		upgrade_info_panel.get_node("Description").text += format_bonus_damage % [_dmg, _dmg + _bonus_dmg, _bonus_dmg]
	

func _on_upgrade_button_mouse_exited():
	left_the_button = true
	upgrade_info_panel.visible = false
	upgrade_info_panel.get_node("Title").text = ""
	upgrade_info_panel.get_node("Description").text = ""
	
	
func _on_upgrade_button_pressed(type: String, lane: String, tier: int):
	var node_string = ""
	node_string = "HUD/UpgradesUI/BackgroundPanel/HBoxContainer/"+type.capitalize()+"Upgrades/"+lane.capitalize()+type.capitalize()
	var building = get_tree().get_nodes_in_group(lane.capitalize()+type.capitalize())[0] #0 - p1 team, 1 - p2 team
	var button = get_node(node_string)
	print(button)
	print(building)
	#print(type, " ", lane, " ", tier)
