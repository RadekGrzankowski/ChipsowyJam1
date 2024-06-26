extends Node2D

@onready var player1_gold_box: SpinBox = $MainMenu/DebugPanel/P1GoldInputBox
@onready var player2_gold_box: SpinBox = $MainMenu/DebugPanel/P2GoldInputBox
@onready var player1_barrack_box: SpinBox = $MainMenu/DebugPanel/P1BarrackInputBox
@onready var player2_barrack_box: SpinBox = $MainMenu/DebugPanel/P2BarrackInputBox
@onready var wave_time_box: SpinBox = $MainMenu/DebugPanel/WaveTimeInputBox
@onready var start_time_box: SpinBox = $MainMenu/DebugPanel/StartTimeInputBox
@export var player1_team_color: OptionButton
@export var player2_team_color: OptionButton

@export var player1_dark_mat: BaseMaterial3D
@export var player1_light_mat: BaseMaterial3D
@export var player2_dark_mat: BaseMaterial3D
@export var player2_light_mat: BaseMaterial3D

func _on_play_button_pressed():
	
	Game.player1_gold = player1_gold_box.value
	Game.player2_gold = player2_gold_box.value
	Game.player1_barracks_level = player1_barrack_box.value
	Game.player2_barracks_level = player2_barrack_box.value
	Game.start_delay_time = start_time_box.value
	Game.wave_time = wave_time_box.value
	var color: Color
	match player1_team_color.get_selected_id():
		0: 
			color = Game.green_color
			player1_dark_mat.albedo_color = Game.dark_green_color
			player1_light_mat.albedo_color = Game.light_green_color
		1: 
			color = Game.blue_color
			player1_dark_mat.albedo_color = Game.dark_blue_color
			player1_light_mat.albedo_color = Game.light_blue_color
		2: 
			color = Game.red_color
			player1_dark_mat.albedo_color = Game.dark_red_color
			player1_light_mat.albedo_color = Game.light_red_color
		3: 
			color = Game.yellow_color
			player1_dark_mat.albedo_color = Game.dark_yellow_color
			player1_light_mat.albedo_color = Game.light_yellow_color
	Game.player1_color = color
	match player2_team_color.get_selected_id():
		0: 
			color = Game.green_color
			player2_dark_mat.albedo_color = Game.dark_green_color
			player2_light_mat.albedo_color  = Game.light_green_color
		1: 
			color = Game.blue_color
			player2_dark_mat.albedo_color = Game.dark_blue_color
			player2_light_mat.albedo_color  = Game.light_blue_color
		2: 
			color = Game.red_color
			player2_dark_mat.albedo_color = Game.dark_red_color
			player2_light_mat.albedo_color  = Game.light_red_color
		3: 
			color = Game.yellow_color
			player2_dark_mat.albedo_color = Game.dark_yellow_color
			player2_light_mat.albedo_color  = Game.light_yellow_color
	Game.player2_color = color
	Game.reset_values()
	get_tree().change_scene_to_file("res://Scenes/Levels/wip_scene.tscn")

func _on_exit_button_pressed():
	get_tree().quit()


func _on_player1_team_color_item_selected(index):
	if player2_team_color.selected == index:
		var ids: Array = [0,1,2,3]
		ids.erase(index)
		player2_team_color.selected = ids.pick_random()

func _on_player2_team_color_item_selected(index):
	if player1_team_color.selected == index:
		var ids: Array = [0,1,2,3]
		ids.erase(index)
		player1_team_color.selected = ids.pick_random()
