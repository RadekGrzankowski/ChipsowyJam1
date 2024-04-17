extends Resource
@export var name: String
@export var image: Texture2D
@export var cost: int
@export var race: String
@export var description: String

func _init(p_name = "", p_image = null, p_cost = 0, p_race = "", p_description = ""):
	name = p_name
	image = p_image
	cost = p_cost
	race = p_race
	description = p_description
