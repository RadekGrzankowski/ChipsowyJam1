extends Node3D
var format_gold_stats: String = "RED GOLD: %s\nBLUE GOLD: %s"
var format_minions_top: String = "RED MINIONS TOP: %s\nBLUE MINIONS TOP: %s"
var format_minions_mid: String = "RED MINIONS MID: %s\nBLUE MINIONS MID: %s"
var format_minions_bot: String = "RED MINIONS BOT: %s\nBLUE MINIONS BOT: %s"

var actual_gold_stats: String
var actual_minions_top: String
var actual_minions_mid: String
var actual_minions_bot: String

@onready var gold_label: Label = $HUD/GoldLabel
@onready var top_minions_label: Label = $HUD/TopMinions
@onready var mid_minions_label: Label = $HUD/MidMinions
@onready var bot_minions_label: Label = $HUD/BotMinions
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
