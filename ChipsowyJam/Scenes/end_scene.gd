extends Node2D
@onready var winner_label: Label = $WinnerLabel
@onready var stats_label: Label = $StatsLabel/Amounts
var format_winner_string: String = "%s TEAM WINS!"
var format_stats_string: String = "%s\n%s\n\n%s\n%s"

# Called when the node enters the scene tree for the first time.
func _ready():
	var actual_winner_string: String = format_winner_string % [Game.winner]
	var actual_stats_string: String = format_stats_string % [Game.red_minions_killed, Game.blue_minions_killed, Game.red_towers_destroyed, Game.blue_towers_destroyed]
	winner_label.text = actual_winner_string
	stats_label.text = actual_stats_string


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
