extends Node2D

@onready var blue_gold_box: SpinBox = $MainMenu/DebugPanel/BlueGoldInputBox
@onready var red_gold_box: SpinBox = $MainMenu/DebugPanel/RedGoldInputBox
@onready var blue_barrack_box: SpinBox = $MainMenu/DebugPanel/BlueBarrackInputBox
@onready var red_barrack_box: SpinBox = $MainMenu/DebugPanel/RedBarrackInputBox
@onready var wave_time_box: SpinBox = $MainMenu/DebugPanel/WaveTimeInputBox
@onready var start_time_box: SpinBox = $MainMenu/DebugPanel/StartTimeInputBox
@export var blue_team_color: OptionButton
@export var red_team_color: OptionButton

func _on_play_button_pressed():
	Game.red_gold = red_gold_box.value
	Game.blue_gold = blue_gold_box.value
	Game.red_barracks_level = red_barrack_box.value
	Game.blue_barracks_level = blue_barrack_box.value
	Game.start_delay_time = start_time_box.value
	Game.wave_time = wave_time_box.value
	var color: Color
	match red_team_color.get_selected_id():
		0: color = Game.green_color
		1: color = Game._blue_color
		2: color = Game._red_color
		3: color = Game.yellow_color
	Game.red_color = color
	match blue_team_color.get_selected_id():
		0: color = Game.green_color
		1: color = Game._blue_color
		2: color = Game._red_color
		3: color = Game.yellow_color
	Game.blue_color = color
	Game.reset_values()
	get_tree().change_scene_to_file("res://Scenes/Levels/wip_scene.tscn")

func _on_exit_button_pressed():
	get_tree().quit()


func _on_blue_team_color_item_selected(index):
	if red_team_color.selected == index:
		var ids: Array = [0,1,2,3]
		ids.erase(index)
		red_team_color.selected = ids.pick_random()


func _on_red_team_color_item_selected(index):
	if blue_team_color.selected == index:
		var ids: Array = [0,1,2,3]
		ids.erase(index)
		blue_team_color.selected = ids.pick_random()
