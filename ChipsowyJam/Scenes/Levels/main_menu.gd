extends Node2D

@onready var blue_gold_box: SpinBox = $MainMenu/DebugPanel/BlueGoldInputBox
@onready var red_gold_box: SpinBox = $MainMenu/DebugPanel/RedGoldInputBox
@onready var blue_barrack_box: SpinBox = $MainMenu/DebugPanel/BlueBarrackInputBox
@onready var red_barrack_box: SpinBox = $MainMenu/DebugPanel/RedBarrackInputBox
@onready var wave_time_box: SpinBox = $MainMenu/DebugPanel/WaveTimeInputBox
@onready var start_time_box: SpinBox = $MainMenu/DebugPanel/StartTimeInputBox

func _on_play_button_pressed():
	Game.red_gold = red_gold_box.value
	Game.blue_gold = blue_gold_box.value
	Game.red_barracks_level = red_barrack_box.value
	Game.blue_barracks_level = blue_barrack_box.value
	Game.start_delay_time = start_time_box.value
	Game.wave_time = wave_time_box.value
	Game.reset_values()
	get_tree().change_scene_to_file("res://Scenes/Levels/wip_scene.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
