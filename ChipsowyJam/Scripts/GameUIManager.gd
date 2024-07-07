extends Node3D
var format_gold_stats: String = "PLAYER 1 GOLD: %s\nPLAYER 2(AI) GOLD: %s"
var format_minions_top: String = "P1 MINIONS TOP: %s\nP2 MINIONS TOP: %s"
var format_minions_mid: String = "P1 MINIONS MID: %s\nP2 MINIONS MID: %s"
var format_minions_bot: String = "P1 MINIONS BOT: %s\nP2 MINIONS BOT: %s"

var format_upgrade_cost: String = "UPGRADE COST: [b][color=#dbac34]%sG[/color][/b]"
var format_bonus_health: String = "\n\nHEALTH: %sHP -> [b][color=#53c349]%sHP[/color][/b] ([color=#53c349]+%sHP[/color])"
var format_bonus_damage: String = "\n\nDAMAGE: %sAD -> [b][color=#fc8f78]%sAD[/color][/b] ([color=#fc8f78]+%sAD[/color])"
var format_bonus_armor: String = "\n\nARMOR: %sARM -> [b][color=#37b0ec]%sARM[/color][/b] ([color=#37b0ec]+%sARM[/color])"
var format_bonus_speed: String = "\n\nSPEED: %ss -> [b][color=WHITE]%ss[/color][/b] ([color=WHITE]-%ss[/color])"
var format_bonus_range: String = "\n\nRANGE: %s -> [b][color=WHITE]%s[/color][/b] ([color=WHITE]+%s[/color])"
var format_bonus_aoe: String = "\n\nAOE: %s -> [b][color=WHITE]%s[/color][/b] ([color=WHITE]+%s[/color])"
var format_bonus_gold: String = "\n\nGOLD INCOME: %sG/1s -> [b][color=GOLD]%sG[/color]/1s[/b]"

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
	
func update_upgrade_panel(type: String, lane: String, tier: int):
	var building = get_tree().get_nodes_in_group(lane.capitalize()+type.capitalize())[0]
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
		var _value = building.building_damage
		var _bonus_value = array[array_index].bonus_damage
		upgrade_info_panel.get_node("Description").text += format_bonus_damage % [_value, _value + _bonus_value, _bonus_value]
	if array[array_index].bonus_armor > 0:
		var _value = building.building_armor
		var _bonus_value = array[array_index].bonus_armor
		upgrade_info_panel.get_node("Description").text += format_bonus_armor % [_value, _value + _bonus_value, _bonus_value]
	if array[array_index].bonus_range > 0:
		var _value = building.building_range
		var _bonus_value = array[array_index].bonus_range
		upgrade_info_panel.get_node("Description").text += format_bonus_range % [_value, _value + _bonus_value, _bonus_value]
	if array[array_index].bonus_speed > 0:
		var _value = building.building_speed
		var _bonus_value = array[array_index].bonus_speed
		upgrade_info_panel.get_node("Description").text += format_bonus_speed % [_value, _value - _bonus_value, _bonus_value]
	if array[array_index].bonus_aoe > 0:
		var _value = building.aoe_dmg_percentage
		var _bonus_value = array[array_index].bonus_aoe
		upgrade_info_panel.get_node("Description").text += format_bonus_aoe % [_value, _value + _bonus_value, _bonus_value]
	if array[array_index].passive_gold > 0:
		var _value = building.passive_gold_amount
		var _value_time = building.passive_gold_time
		var _building_gps = 0
		if _value > 0:
			_building_gps = _value/_value_time
		var _bonus_value = array[array_index].passive_gold
		var _bonus_time = array[array_index].passive_gold_per_seconds
		var _bonus_gps = _bonus_value/_bonus_time
		upgrade_info_panel.get_node("Description").text += format_bonus_gold % [snapped(_building_gps, 0.01) , snapped(_bonus_gps, 0.01)]
		upgrade_info_panel.get_node("Description").text += "\n\nIncreased chance of dropping better cards in the Shop!"

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
	var node_string = "HUD/UpgradesUI/BackgroundPanel/HBoxContainer/"+type.capitalize()+"Upgrades/"+lane.capitalize()+type.capitalize()
	if get_node(node_string).disabled == true:
		return
	upgrade_info_panel.position = $HUD/UpgradesUI/BackgroundPanel.get_global_mouse_position()
	update_upgrade_panel(type, lane, tier)
	
func _on_upgrade_button_mouse_exited():
	left_the_button = true
	upgrade_info_panel.visible = false
	upgrade_info_panel.get_node("Title").text = ""
	upgrade_info_panel.get_node("Description").text = ""
	
	
func _on_upgrade_button_pressed(type: String, lane: String, tier: int):
	var array_index = tier - 1 
	var array: Array = get(type+"_upgrades_array")
	#If player does not have enough money for upgrade
	if array[array_index].upgrade_cost > Game.player1_gold:
		print("Not enought money!")
		return
	Game.player1_gold -= array[array_index].upgrade_cost
	var node_string = ""
	node_string = "HUD/UpgradesUI/BackgroundPanel/HBoxContainer/"+type.capitalize()+"Upgrades/"+lane.capitalize()+type.capitalize()
	var building = get_tree().get_nodes_in_group(lane.capitalize()+type.capitalize())[0] #0 - p1 team, 1 - p2 team
	var button = get_node(node_string)
	building.building_tier = tier
	building.health_value += array[array_index].bonus_health
	building.building_health += array[array_index].bonus_health
	building.building_damage += array[array_index].bonus_damage
	building.building_armor +=  array[array_index].bonus_armor
	#INFO building.building_health - maximum health of building
	#INFO building._health_value - current health value of building
	building.update_stats()
	if type == "nexus":
		get_tree().get_first_node_in_group("CardsUI").on_new_nexus_level()
	if array_index < array.size() - 1:
		button.text = lane.to_upper() + " " + type.to_upper() + " UPGRADE TIER "+ str(tier + 1) +"\nCOST - " + str(array[tier].upgrade_cost) + "G"
		button.disconnect("pressed", _on_upgrade_button_pressed)
		button.pressed.connect(_on_upgrade_button_pressed.bind(type, lane, tier + 1))
		button.disconnect("mouse_entered", _on_upgrade_button_mouse_entered)
		button.mouse_entered.connect(_on_upgrade_button_mouse_entered.bind(type, lane, tier + 1))
		update_upgrade_panel(type, lane, tier + 1)
	else:
		button.text = lane.to_upper() + " " + type.to_upper() + " IS FULLY UPGRADED!"
		upgrade_info_panel.visible = false
		upgrade_info_panel.get_node("Title").text = ""
		upgrade_info_panel.get_node("Description").text = ""
		button.disabled = true
