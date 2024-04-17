extends Control

@export var name_label: Label
@export var image: TextureRect
@export var description_label: Label
@export var cost_label: Label
@export var race_label: Label

var cost: int
var race: String

var card_resource: Resource
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _update_card(resource: Resource):
	var imported_resource = resource
	if imported_resource:
		card_resource = imported_resource
		name_label.text = card_resource.name
		image.texture = card_resource.image
		description_label.text = card_resource.description
		cost_label.text = str(card_resource.cost)
		race_label.text = card_resource.race

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
