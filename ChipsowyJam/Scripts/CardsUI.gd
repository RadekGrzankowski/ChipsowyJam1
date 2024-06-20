extends CanvasLayer

@onready var ui = $CardsUI
@onready var top_button: Button = $CardsUI/LanesPanel/LaneButtons/TopButton
@onready var middle_button: Button = $CardsUI/LanesPanel/LaneButtons/MiddleButton
@onready var bottom_button: Button = $CardsUI/LanesPanel/LaneButtons/BottomButton
var lane_value: int = 0 #0 - top, 1 - middle, 2 - bottom
var ui_open: bool = false

signal refresh_cards

#DIFFERENT RACES: 
#HUMAN_KINGDOM, OUTLAWS, MOUNTAIN_CLAN, FOREST_ORCS, 
#BLOOD_BROTHERHOOD, UNDEAD_PACT, MOON_ELVES, SUN_ELVES, BEAST
@export var card_scene: PackedScene
@export var human_kingdom_cards_array: Array
@export var outlaws_cards_array: Array
@export var mountain_clan_cards_array: Array
@export var forest_orcs_cards_array: Array
@export var blood_brotherhood_cards_array: Array
@export var undead_pact_cards_array: Array
@export var moon_elves_cards_array: Array
@export var sun_elves_cards_array: Array
@export var beast_cards_array: Array
var all_cards_array: Array

@onready var shop_nodes : Array = get_tree().get_nodes_in_group("shop_zone")

@onready var top_lane_nodes: Array = get_tree().get_nodes_in_group("top_zone")
@export var top_lane_deck: Control

@onready var middle_lane_nodes: Array = get_tree().get_nodes_in_group("middle_zone")
@export var middle_lane_deck: Control

@onready var bottom_lane_nodes: Array = get_tree().get_nodes_in_group("botton_zone")
@export var bottom_lane_deck: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	top_button.button_pressed = true
	all_cards_array.append_array(human_kingdom_cards_array)
	all_cards_array.append_array(outlaws_cards_array)
	all_cards_array.append_array(mountain_clan_cards_array)
	all_cards_array.append_array(forest_orcs_cards_array)
	all_cards_array.append_array(blood_brotherhood_cards_array)
	all_cards_array.append_array(undead_pact_cards_array)
	all_cards_array.append_array(moon_elves_cards_array)
	all_cards_array.append_array(sun_elves_cards_array)
	all_cards_array.append_array(beast_cards_array)
	all_cards_array.shuffle()
	if !all_cards_array.is_empty():
		call_deferred("fill_the_shop")
	call_deferred("unlock_the_buttons")

func unlock_the_buttons():
	for node in top_lane_nodes:
		if node.is_in_group("locked"):
			node.get_node("UnlockButton").disabled = false
			break
	for node in middle_lane_nodes:
		if node.is_in_group("locked"):
			node.get_node("UnlockButton").disabled = false
			break
	for node in bottom_lane_nodes:
		if node.is_in_group("locked"):
			node.get_node("UnlockButton").disabled = false
			break

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
		
	if Input.is_key_label_pressed(KEY_1):
		lane_value = 0
		change_lane()	
	if Input.is_key_label_pressed(KEY_2):
		lane_value = 1
		change_lane()	
	if Input.is_key_label_pressed(KEY_3):
		lane_value = 2
		change_lane()		
		
func change_lane():
	match lane_value:
		0: 
			_on_top_button_pressed()
		1: 
			_on_middle_button_pressed()
		2: 
			_on_bottom_button_pressed()

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
	#INFO Debug print of cards WIP
	pass

func _on_roll_pressed():
	var cards_to_delete = get_tree().get_nodes_in_group("shop_card")
	if Game.blue_gold >= 10:
		Game.blue_gold -= 10
		for card in cards_to_delete:
			card.queue_free()
		if !all_cards_array.is_empty():
			fill_the_shop()


func _on_top_button_pressed():
	lane_value = 0
	top_button.button_pressed = true
	middle_button.button_pressed = false
	bottom_button.button_pressed = false
	
	top_lane_deck.visible = true
	middle_lane_deck.visible = false
	bottom_lane_deck.visible = false


func _on_middle_button_pressed():
	lane_value = 1
	top_button.button_pressed = false
	middle_button.button_pressed = true
	bottom_button.button_pressed = false
	
	top_lane_deck.visible = false
	middle_lane_deck.visible = true
	bottom_lane_deck.visible = false

func _on_bottom_button_pressed():
	lane_value = 2
	top_button.button_pressed = false
	middle_button.button_pressed = false
	bottom_button.button_pressed = true
	
	top_lane_deck.visible = false
	middle_lane_deck.visible = false
	bottom_lane_deck.visible = true
	
