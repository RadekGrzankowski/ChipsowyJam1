extends Node

@onready var cardsUI: Node = get_node("/root/GameNode/CardsUI")

var top_lane_cards: Array
var middle_lane_cards: Array
var bottom_lane_cards: Array

var shop_cards: Array

enum action_state {DECK_BUILDING, NEW_SLOT, FULL_DECK, FULL_DECK_NO_MORE_SLOTS}
var state: action_state

#Debug section - info panel
@onready var info_panel = $CanvasLayer/InfoPanel
@onready var log_label: RichTextLabel = $CanvasLayer/InfoPanel/DebugLabel
@onready var stats_label: RichTextLabel = $CanvasLayer/InfoPanel/StatsLabel

func _init():
	state = action_state.DECK_BUILDING
	top_lane_cards.resize(3)
	middle_lane_cards.resize(3)
	bottom_lane_cards.resize(3)
	shop_cards.resize(6)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	roll_the_shop()
	perform_action()
	
func _process(delta):
	if Input.is_key_label_pressed(KEY_F1):
		info_panel.visible = true
	if info_panel.visible == true:
		show_info()
	
func show_info():
	var top_cards_string: String
	var mid_cards_string: String
	var bot_cards_string: String
	for card in top_lane_cards:
		if card != null:
			top_cards_string += card.card_name + ", "
		else:
			top_cards_string += "Null, "
	for card in middle_lane_cards:
		if card != null:
			mid_cards_string += card.card_name + ", "
		else:
			mid_cards_string += "Null, "
	for card in bottom_lane_cards:
		if card != null:
			bot_cards_string += card.card_name + ", "
		else:
			bot_cards_string += "Null, "
	stats_label.text = "Available gold: " + str(Game.red_gold) + "\n" + \
	"Top Lane: " + top_cards_string + "\n" + "Mid Lane: "+  mid_cards_string + "\n" + "Bot Lane: " + bot_cards_string + \
	"\nCurrent AI state: " + str(action_state.keys()[state])+"\n"
	
func buy_new_slot():
	var lane = randi_range(0, 2)
	match lane:
		0:
			if top_lane_cards.size() < 6:
				top_lane_cards.append(null)
				log_label.append_text("Bot bought new slot at top!\n")
		1:
			if middle_lane_cards.size() < 6:
				middle_lane_cards.append(null)
				log_label.append_text("Bot bought new slot at mid!\n")
		2:
			if bottom_lane_cards.size() < 6:
				bottom_lane_cards.append(null)
				log_label.append_text("Bot bought new slot at bot!\n")
	#INFO - after perfoming one action bot has a chance to change current action state
	change_action()
				
func buy_new_card():
	var card_bought_or_no_space: bool = false
	var no_space_top: bool = false
	var no_space_mid: bool = false
	var no_space_bot: bool = false
	while(!card_bought_or_no_space):
		if no_space_bot && no_space_mid && no_space_top:
			log_label.append_text("All decks full!")
			card_bought_or_no_space = true
			state = action_state.FULL_DECK
			break
		var lane = randi_range(0, 2)
		match lane:
			0: #top
				for index in top_lane_cards.size():
					if top_lane_cards[index] == null:
						var card = pick_best_from_shop()
						if card == null:
							return
						top_lane_cards[index] = card
						log_label.append_text("Bot have new card at top: " + card.card_name + ", " + str(card.health) + "HP, "+ str(card.cost) +' Gold\n')
						Game.red_gold -= card.cost
						var card_to_remove = shop_cards.find(card)
						shop_cards[card_to_remove] = null
						card_bought_or_no_space = true
						#INFO - after perfoming one action bot has a chance to change current action state
						change_action()
						break
				no_space_top = true		
			1: #middle
				for index in middle_lane_cards.size():
					if middle_lane_cards[index] == null:
						var card = pick_best_from_shop()
						if card == null:
							return
						middle_lane_cards[index] = card
						log_label.append_text("Bot have new card at mid: " + card.card_name + ", " + str(card.health) + "HP, "+ str(card.cost) +' Gold\n')
						Game.red_gold -= card.cost
						var card_to_remove = shop_cards.find(card)
						shop_cards[card_to_remove] = null
						card_bought_or_no_space = true
						#INFO - after perfoming one action bot has a chance to change current action state
						change_action()
						break
				no_space_mid = true
			2: #bottom
				for index in bottom_lane_cards.size():
					if bottom_lane_cards[index] == null:
						var card = pick_best_from_shop()
						if card == null:
							return
						bottom_lane_cards[index] = card
						log_label.append_text("Bot have new card at bot: " + card.card_name + ", " + str(card.health) + "HP, "+ str(card.cost) +' Gold\n')
						Game.red_gold -= card.cost
						var card_to_remove = shop_cards.find(card)
						shop_cards[card_to_remove] = null
						card_bought_or_no_space = true
						#INFO - after perfoming one action bot has a chance to change current action state
						change_action()
						break
				no_space_bot = true
				
func is_shop_empty():
	for card in shop_cards:
		if card != null:
			return false
	return true
	
func roll_the_shop():
	for index in shop_cards.size():
		var tier = Game.return_tier(Game.blue_barracks_level)
		var resource
		match tier:
			0: resource = cardsUI.all_cards_common.pick_random()
			1: resource = cardsUI.all_cards_rare.pick_random()
			2: resource = cardsUI.all_cards_epic.pick_random()
			3: resource = cardsUI.all_cards_legendary.pick_random()
		shop_cards[index] = resource
							
func pick_best_from_shop():
	var best_card
	var cost = 0
	for card in shop_cards:	
		if card != null:
			if card.cost > cost && Game.red_gold >= card.cost:
				cost = card.cost
				best_card = card
	if cost == 0:
		return null
	else:
		return best_card		

func deck_building():
	#before buying card check if there are any cards left in shop - if not roll
	if !is_shop_empty():
		if Game.red_gold >= 10:
			buy_new_card()
			#show_info()
	else:
		#roll the shop, if there is enough money try to buy the card
		if Game.red_gold >= 10:
			Game.red_gold -= 10
			log_label.append_text("Shop empty - rolling it!\n")
			roll_the_shop()
			if Game.red_gold >= 10:
				buy_new_card()
			#show_info()

#INFO AI decides what action to perform
func perform_action():
	if state == action_state.DECK_BUILDING:
		deck_building()
	elif state == action_state.NEW_SLOT:
		if Game.red_gold >= 100:
			Game.red_gold -= 100
			buy_new_slot()
	elif state == action_state.FULL_DECK:
		if Game.red_gold >= 100:
			Game.red_gold -= 100
			buy_new_slot()
	
func change_action():
	var value = randf_range(0.0, 1.0)
	#INFO if value bigger than a threshhold - change action to new slot
	if value > 0.75:
		state = action_state.NEW_SLOT
	else:
		state = action_state.DECK_BUILDING
	log_label.append_text("New state action: " + str(action_state.keys()[state])+"\n")

func _on_action_timer_timeout():
	perform_action()


func _on_button_pressed():
	info_panel.visible = false
