extends CanvasLayer

@onready var ui = $UI
var ui_open: bool = false

signal refresh_cards

@export var card_scene: PackedScene
@export var orc_cards_array: Array

@onready var shop_nodes : Array = get_tree().get_nodes_in_group("shop_zone")
@onready var deck_nodes : Array = get_tree().get_nodes_in_group("zone")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("fill_the_shop")
	
func fill_the_shop():
	var index = 0
	for node in shop_nodes:
		var card: Control = card_scene.instantiate()
		var resource = orc_cards_array.pick_random()
		card.card_resource = resource
		node.card = card
		var position = node.global_position + node.pivot_offset
		card.position = position
		card.set_rest_point(position)
		card.name = "Card" + str(index) + " " + resource.name 
		node.add_child(card)
		index += 1

func _process(delta):
	pass

func _on_shop_button_pressed():
	if ui_open == false:
		ui.position.y += 175
		ui_open = true
	elif ui_open == true:
		ui.position.y -= 175
		ui_open = false


func _on_refresh_cards():
	for node in deck_nodes:
		if node.card != null:
			print(node, " ", node.card, " ", node.card.current_rest_node)
		else:
			print("Null")
	print("\n")
