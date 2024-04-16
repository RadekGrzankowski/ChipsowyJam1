extends Resource
@export var name: String
@export var image: ImageTexture
@export var cost: int

func _init(p_name = "", p_image = null, p_cost = 0):
	name = p_name
	image = p_image
	cost = p_cost
