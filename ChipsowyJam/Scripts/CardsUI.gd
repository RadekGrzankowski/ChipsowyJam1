extends CanvasLayer

@onready var ui = $CardsUI
@onready var top_button: Button = $CardsUI/LanesPanel/LaneButtons/TopButton
@onready var middle_button: Button = $CardsUI/LanesPanel/LaneButtons/MiddleButton
@onready var bottom_button: Button = $CardsUI/LanesPanel/LaneButtons/BottomButton
var lane_value: int = 0 #0 - top, 1 - middle, 2 - bottom
var ui_open: bool = false

signal refresh_cards

@export var card_scene: PackedScene
@export var orc_cards_array: Array
@export var human_cards_array: Array
@export var undead_cards_array: Array
@export var elf_cards_array: Array
var all_cards_array: Array

@onready var shop_nodes : Array = get_tree().get_nodes_in_group("shop_zone")
@onready var deck_nodes : Array = get_tree().get_nodes_in_group("zone")

var top_lane_cards: Array
var middle_lane_cards: Array
var bottom_lane_cards: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	top_button.button_pressed = true
	all_cards_array.append_array(orc_cards_array)
	all_cards_array.append_array(human_cards_array)
	all_cards_array.append_array(undead_cards_array)
	all_cards_array.append_array(elf_cards_array)
	all_cards_array.shuffle()	
	call_deferred("fill_the_shop")
	
func fill_the_shop():
	var index = 0
	for node in shop_nodes:
		var card: Control = card_scene.instantiate()
		card.add_to_group("shop_card")
		var resource = all_cards_array.pick_random()
		card.card_resource = resource
		node.card = card
		var position = node.global_position + node.pivot_offset
		node.add_child(card)
		card.global_position = position
		card.set_rest_node(node)
		card.name = "Card" + str(index) + " " + resource.name 
		index += 1

func _process(delta):
	if Input.is_action_just_released("open_shop"):
		open_ui()

func _on_shop_button_pressed():
	open_ui()

func open_ui():
	if ui_open == false:
		print("Shop UI opened")
		$CardsUI/CardsPanel/CardsPanelsAndTools/Tools/Roll.disabled = false
		ui.position.y -= 165
		ui_open = true
	elif ui_open == true:
		print("Shop UI closed")
		$CardsUI/CardsPanel/CardsPanelsAndTools/Tools/Roll.disabled = true
		ui.position.y += 165
		ui_open = false

func _on_refresh_cards():
	for node in deck_nodes:
		if node.card != null:
			print(node, " ", node.card, " ", node.card.current_rest_node)
		else:
			print("Null")
	print("\n")


func _on_roll_pressed():
	var cards_to_delete = get_tree().get_nodes_in_group("shop_card")
	if Game.blue_gold >= 10:
		Game.blue_gold -= 10
		for card in cards_to_delete:
			card.queue_free()
		fill_the_shop()


func _on_top_button_pressed():
	if lane_value == 0:
		return
	lane_value = 0
	top_button.button_pressed = true
	middle_button.button_pressed = false
	bottom_button.button_pressed = false
	for t_card in top_lane_cards:
		t_card.visible = true
	for m_card in middle_lane_cards:
		m_card.visible = false
	for b_card in bottom_lane_cards:
		b_card.visible = false

func _on_middle_button_pressed():
	if lane_value == 1:
		return
	lane_value = 1
	top_button.button_pressed = false
	middle_button.button_pressed = true
	bottom_button.button_pressed = false
	for t_card in top_lane_cards:
		t_card.visible = false
	for m_card in middle_lane_cards:
		m_card.visible = true
	for b_card in bottom_lane_cards:
		b_card.visible = false

func _on_bottom_button_pressed():
	if lane_value == 2:
		return
	lane_value = 2
	top_button.button_pressed = false
	middle_button.button_pressed = false
	bottom_button.button_pressed = true
	for t_card in top_lane_cards:
		t_card.visible = false
	for m_card in middle_lane_cards:
		m_card.visible = false
	for b_card in bottom_lane_cards:
		b_card.visible = true
	
