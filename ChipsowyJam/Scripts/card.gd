extends Control

@export var name_label_big: Label
@export var image_rect_big: TextureRect
@export var description_label: Label
@export var cost_label_big: Label
@export var race_type_label: Label
@export var health_label_big: Label
@export var armor_label: Label
@export var attack_damage_label_big: Label

@export var name_label_small: Label
@export var image_rect_small: TextureRect
@export var cost_label_small: Label
@export var health_label_small: Label
@export var attack_damage_label_small: Label


var card_name: String
var image: Texture2D
var description: String

var health: int
var attack_damage: int
var armor: int
var attack_speed: float
var cost: int

enum mob_race {HUMAN, ORC, UNDEAD, ELVES}
var race: mob_race

enum mob_type {MELEE, RANGED, MAGE}
var type: mob_type

enum card_tier {COMMON, RARE, EPIC, LEGENDARY}
var tier: card_tier

@export var card_resource: Resource	
var is_showing_reverse: bool = false

var is_hovering_above: bool = false

#INFO drag & drop variables
var selected: bool = false
var rest_nodes = []
var rest_node: Control
var current_rest_node: int = -1
var cardsUI: Node

var lane: int = 0 # 0 - top, 1 - middle, 2 - bot

func _ready():
	cardsUI = get_tree().get_first_node_in_group("CardsUI")
	set_variables()
	update_card()
	
func set_rest_node(node: Control):
	rest_node = node

func set_variables():
	card_name = card_resource.name
	image = card_resource.image
	description = card_resource.description
	health = card_resource.health
	attack_damage = card_resource.attack_damage
	armor = card_resource.armor
	attack_speed = card_resource.attack_speed
	cost = card_resource.cost
	race = card_resource.race
	type = card_resource.type
	tier = card_resource.tier

func update_card():
	if card_resource:
		$CardPanelSmall.visible = true
		$CardPanelBig.visible = false
		$CardPanelBig/FaceSide.visible = true
		$CardPanelBig/ReverseSide.visible = false
		name_label_big.text = card_name
		name_label_small.text = card_name
		var ls = LabelSettings.new()
		#modify label color depending on card's tier
		var tier_value: int = tier
		match tier_value:
			0: #COMMON tier
				ls.font_color =  Color.WHITE
			1: #RARE tier
				ls.font_color =  Color.SKY_BLUE
			2: #EPIC tier
				ls.font_color =  Color.MEDIUM_PURPLE
			3: #LEGENDARY tier
				ls.font_color =  Color.DARK_ORANGE
			_: #Default case
				ls.font_color =  Color.WHITE
		ls.outline_size = 3
		ls.outline_color = Color.BLACK
		name_label_big.label_settings = ls
		name_label_small.label_settings = ls
		#modify card's background color depending on card's race
		var color
		var race_value: int = race
		match race_value:
			0: #HUMAN
				color = Color(0.24, 0.395, 0.493)
			1: #ORC
				color = Color(0.267, 0.435, 0.267)
			2: #UNDEAD
				color = Color(0.423, 0.331, 0.577)
			3: #ELVES
				color = Color(0.433, 0.382, 0.256)
			_: #Default case - HUMAN
				color = Color(0.24, 0.395, 0.493)
		$CardPanelBig/Panel.modulate = color
		$CardPanelSmall/Panel.modulate = color
		image_rect_big.texture = image
		image_rect_small.texture = image
		cost_label_big.text = str(cost) + "G"
		cost_label_small.text = str(cost) + "G"
		race_type_label.text = str(mob_type.keys()[type]) + " " + str(mob_race.keys()[race])
		health_label_big.text = str(health) + "♥"
		health_label_small.text = str(health) + "♥"
		attack_damage_label_big.text = str(attack_damage) + "AD"
		attack_damage_label_small.text = str(attack_damage) + "AD"
		description_label.text = str(health) + " Health" + "\n" + str(attack_damage) + " Attack Damage" + "\n" + \
		str(attack_speed) + "/s Attack Speed\n"+ str(armor) + " Armor Points" + "\n" + \
		str(card_tier.keys()[tier]) + " Tier" + "\n" + str(mob_type.keys()[type]) + " " + str(mob_race.keys()[race]) + " Unit" + "\n" + \
		str(cost) + " Gold"

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	else:
		if rest_node != null:
			global_position = lerp(global_position, rest_node.global_position + rest_node.pivot_offset, 10 * delta)

func _on_mouse_click_control_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not selected and event.pressed:
			# INFO change top level of the card to always be on top for duration of drag
			var position = global_position
			top_level = true
			global_position = position
			selected = true
		# Stop dragging if the button is released.
		if selected and not event.pressed:
			var shortest_dist = 70
			var index = 0
			var _lane_value = cardsUI.lane_value
			# INFO card is in shop and it does not have rest nodes array set yet - not in any deck
			if rest_nodes.is_empty():
				if !is_in_group("shop_card"):
					return
				var _rest_nodes
				match _lane_value:
					0: 
						_rest_nodes = cardsUI.top_lane_nodes
					1: 
						_rest_nodes = cardsUI.middle_lane_nodes
					2: 
						_rest_nodes = cardsUI.bottom_lane_nodes
				# INFO moving shop card into the deck - charging gold
				for node: Control in _rest_nodes:
					if node.is_in_group("locked"):
						continue
					if node.card == null:
						var distance = global_position.distance_to(node.global_position + node.pivot_offset)
						if distance < shortest_dist:
							if Game.blue_gold >= cost:
								Game.blue_gold -= cost
								add_to_group("deck_card")
								remove_from_group("shop_card")
								lane = _lane_value
								rest_node = node
								current_rest_node = index
								#changing the parent of card to the node in the deck
								get_parent().remove_child(self)
								node.add_child(self)
								node.card = self
								#assigning current lane card zones
								rest_nodes = _rest_nodes
								break
					index += 1	
			else:	
				var is_card_moved: bool = false
				for node: Control in rest_nodes:
					var distance = global_position.distance_to(node.global_position + node.pivot_offset)
					if distance < shortest_dist:
						if node.card:
							if !node.card.is_in_group("shop_card") && !is_in_group("shop_card"):
								rest_nodes[current_rest_node].remove_child(self)
								var temp_card: Control = node.card
								node.remove_child(temp_card)
								temp_card.rest_node = rest_node
								temp_card.current_rest_node = current_rest_node
								rest_nodes[current_rest_node].card = temp_card
								rest_node = node
								rest_nodes[current_rest_node].add_child(temp_card)
								current_rest_node = index
								node.add_child(self)
								node.card = self
								is_card_moved = true
								break
						else:
							if !node.is_in_group("locked"):
								if current_rest_node >= 0: 
									rest_nodes[current_rest_node].card = null
								rest_node = node
								rest_nodes[current_rest_node].remove_child(self)
								current_rest_node = index
								node.add_child(self)
								node.card = self
								is_card_moved = true
								break
					index += 1
				if !is_card_moved:
					#if card wasn't moved to any slot, check whenever player moved the card to sell spot
					print("check sell")
					var sell_zone = get_tree().get_first_node_in_group("sell_zone")
					var distance = global_position.distance_to(sell_zone.global_position + sell_zone.pivot_offset)
					if distance < shortest_dist:
						#INFO sell the card, as the rest node is the sell zone
						Game.blue_gold += (cost / 2)
						rest_nodes[current_rest_node].card = null
						queue_free()
			cardsUI.refresh_cards.emit()
			selected = false
			#reset the top level and position to not obstruct other cards
			var position = global_position
			top_level = false
			global_position = position
			
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_RIGHT && is_hovering_above:
			if is_showing_reverse:
				is_showing_reverse = false
				$CardPanelBig/FaceSide.visible = true
				$CardPanelBig/ReverseSide.visible = false
			else:
				is_showing_reverse = true
				$CardPanelBig/FaceSide.visible = false
				$CardPanelBig/ReverseSide.visible = true

func _on_mouse_click_control_mouse_entered():
	is_hovering_above = true
	$CardPanelBig.visible = true
	$CardPanelSmall.visible = false

func _on_mouse_click_control_mouse_exited():
	is_hovering_above = false
	$CardPanelBig.visible = false
	$CardPanelSmall.visible = true