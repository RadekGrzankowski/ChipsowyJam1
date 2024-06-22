extends Node

@onready var cardsUI: Node = get_node("/root/GameNode/CardsUI")

var top_lane_cards: Array
var middle_lane_cards: Array
var bottom_lane_cards: Array

var shop_cards: Array

func _init():
	top_lane_cards.resize(3)
	middle_lane_cards.resize(3)
	bottom_lane_cards.resize(3)
	shop_cards.resize(6)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for index in shop_cards.size():
		var resource = cardsUI.all_cards_array.pick_random()
		shop_cards[index] = resource
	perform_action()
	
func show_info():
	print("Available gold: ", Game.red_gold)
	for card in shop_cards:
		if card != null:
			print(card.card_name , ", ", card.health, "HP, ", card.cost , ' Gold')
		else:
			print("Null")
	print(top_lane_cards)
	print(middle_lane_cards)
	print(bottom_lane_cards)
	
func buy_new_slot():
	var lane = randi_range(0, 2)
	match lane:
		0:
			if top_lane_cards.size() < 6:
				top_lane_cards.append(null)
				return true
			else:
				return false
		1:
			if middle_lane_cards.size() < 6:
				middle_lane_cards.append(null)
				return true
			else:
				return false
		2:
			if bottom_lane_cards.size() < 6:
				bottom_lane_cards.append(null)
				return true
			else:
				return false
				
func buy_new_card():
	var card_bought_or_no_space: bool = false
	var no_space_top: bool = false
	var no_space_mid: bool = false
	var no_space_bot: bool = false
	while(!card_bought_or_no_space):
		if no_space_bot && no_space_mid && no_space_top:
			card_bought_or_no_space = true
			break
		var lane = randi_range(0, 2)
		match lane:
			0: #top
				for index in top_lane_cards.size():
					if top_lane_cards[index] == null:
						var card = pick_best_from_shop()
						if card != null:
							top_lane_cards[index] = card
							print("Bot bought new card: ", card.card_name , ", ", card.health, "HP, ", card.cost , ' Gold')
							Game.red_gold -= card.cost
							var card_to_remove = shop_cards.find(card)
							shop_cards[card_to_remove] = null
							card_bought_or_no_space = true
							break
				no_space_top = true			
			1: #middle
				for index in middle_lane_cards.size():
					if middle_lane_cards[index] == null:
						var card = pick_best_from_shop()
						if card != null:
							middle_lane_cards[index] = card
							print("Bot bought new card: ", card.card_name , ", ", card.health, "HP, ", card.cost , ' Gold')
							Game.red_gold -= card.cost
							var card_to_remove = shop_cards.find(card)
							shop_cards[card_to_remove] = null
							card_bought_or_no_space = true
							break
				no_space_mid = true
			2: #bottom
				for index in bottom_lane_cards.size():
					if bottom_lane_cards[index] == null:
						var card = pick_best_from_shop()
						if card != null:
							bottom_lane_cards[index] = card
							print("Bot bought new card: ", card.card_name , ", ", card.health, "HP, ", card.cost , ' Gold')
							Game.red_gold -= card.cost
							var card_to_remove = shop_cards.find(card)
							shop_cards[card_to_remove] = null
							card_bought_or_no_space = true
							break
				no_space_bot = true
				
func is_shop_empty():
	for card in shop_cards:
		if card != null:
			return false
	return true
	
	
func roll_the_shop():
	for index in shop_cards.size():
		var resource = cardsUI.all_cards_array.pick_random()
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
	

#INFO AI decides what action to perform
func perform_action():
	#before buying card check if there are any cards left in shop - if not roll
	if !is_shop_empty():
		if Game.red_gold >= 10:
			buy_new_card()
			show_info()
	else:
		#roll the shop, if there is enough money try to buy the card
		if Game.red_gold >= 10:
			Game.red_gold -= 10
			roll_the_shop()
			if Game.red_gold >= 10:
				buy_new_card()
			show_info()
	
func _on_action_timer_timeout():
	perform_action()
