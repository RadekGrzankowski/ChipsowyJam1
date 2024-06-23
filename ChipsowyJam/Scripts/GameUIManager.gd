extends Node3D
var format_gold_stats: String = "RED GOLD: %s\nBLUE GOLD: %s"
var format_minions_top: String = "RED MINIONS TOP: %s\nBLUE MINIONS TOP: %s"
var format_minions_mid: String = "RED MINIONS MID: %s\nBLUE MINIONS MID: %s"
var format_minions_bot: String = "RED MINIONS BOT: %s\nBLUE MINIONS BOT: %s"
var format_barracks_stats: String = "RED BARRACKS: %sLVL\nBLUE BARRACKS: %sLVL"

var actual_gold_stats: String
var actual_minions_top: String
var actual_minions_mid: String
var actual_minions_bot: String
var actual_barracks_stats: String

@onready var towers_upgrade_ui: Panel = $HUD/UpgradesUI/TowersPanel
@onready var barracks_upgrade_ui: Panel = $HUD/UpgradesUI/BarracksPanel
@onready var nexus_upgrade_ui: Panel = $HUD/UpgradesUI/NexusPanel
@onready var upgrades_ui: CanvasLayer = $HUD/UpgradesUI

@onready var tower_button: Button = $HUD/UpgradesUI/UpperPanel/HBoxContainer/TowersButton
@onready var barracks_button: Button = $HUD/UpgradesUI/UpperPanel/HBoxContainer/BarracksButton
@onready var nexus_button: Button = $HUD/UpgradesUI/UpperPanel/HBoxContainer/NexusButton
var button_value: int = 0 #0 - tower, 1 - barracks, 2 - nexus

@onready var gold_label: Label = $HUD/Labels/GoldLabel
@onready var barracks_label: Label = $HUD/Labels/BarrackLevelLabel
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
			
	if Input.is_action_just_pressed("upgrades_left"):
		if button_value <= 0:
			button_value = 2
		else:
			button_value -= 1
		change_upgrade_panel()
	if Input.is_action_just_pressed("upgrades_right"):
		if button_value >= 2:
			button_value = 0
		else:
			button_value += 1
		change_upgrade_panel()
	
	actual_gold_stats = format_gold_stats % [Game.red_gold, Game.blue_gold]
	actual_minions_top = format_minions_top % [Game.red_minions_top, Game.blue_minions_top]
	actual_minions_mid = format_minions_mid % [Game.red_minions_mid, Game.blue_minions_mid]
	actual_minions_bot = format_minions_bot % [Game.red_minions_bot, Game.blue_minions_bot]
	
	actual_barracks_stats = format_barracks_stats % [Game.blue_barracks_level, Game.red_barracks_level]
	
	gold_label.text = actual_gold_stats
	top_minions_label.text = actual_minions_top
	mid_minions_label.text = actual_minions_mid
	bot_minions_label.text = actual_minions_bot
	
	barracks_label.text = actual_barracks_stats

func change_upgrade_panel():
	match button_value:
		0: 
			_on_towers_button_pressed()
		1: 
			_on_barracks_button_pressed()
		2: 
			_on_nexus_button_pressed()


func _on_towers_button_pressed():
	closeTabs()
	button_value = 0
	tower_button.button_pressed = true
	towers_upgrade_ui.visible = true

func _on_barracks_button_pressed():
	closeTabs()
	button_value = 1
	barracks_button.button_pressed = true
	barracks_upgrade_ui.visible = true

func _on_nexus_button_pressed():
	closeTabs()
	button_value = 2
	nexus_button.button_pressed = true
	nexus_upgrade_ui.visible = true

func closeTabs():
	tower_button.button_pressed = false
	barracks_button.button_pressed = false
	nexus_button.button_pressed = false
	nexus_upgrade_ui.visible = false
	barracks_upgrade_ui.visible = false
	towers_upgrade_ui.visible = false

func _on_exit_button_pressed():
	upgrades_ui.visible = false

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

func _on_barrack_upgrade_button_pressed(level: int, cost: int):
	if Game.blue_gold >= cost:
		upgrade_barracks(level, cost)
	
func upgrade_barracks(level: int, cost: int):
	Game.blue_gold -= cost
	Game.blue_barracks_level += 1
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

