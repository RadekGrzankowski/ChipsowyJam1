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
var rest_node: Control
var current_rest_node: int = -1
var rest_nodes = []
var cardsUI

func _ready():
	rest_nodes = get_tree().get_nodes_in_group("zone")
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
			#change top level of the card to always be on top for duration of drag
			var position = global_position
			top_level = true
			global_position = position
			selected = true
		# Stop dragging if the button is released.
		if selected and not event.pressed:
			var shortest_dist = 70
			var index = 0
			for child in rest_nodes:
				var distance = global_position.distance_to(child.global_position + child.pivot_offset)
				if distance < shortest_dist:
					if child.is_in_group("sell_zone"):
						if !is_in_group("shop_card"):
							#sell the card as the rest node is sell zone
							Game.blue_gold += (cost / 2)
							match cardsUI.lane_value:
								0: 
									cardsUI.top_lane_cards.erase(self)
								1: 
									cardsUI.middle_lane_cards.erase(self)
								2: 
									cardsUI.bottom_lane_cards.erase(self)
							queue_free()
					else:
						if child.card != null:
							if !child.card.is_in_group("shop_card") && !is_in_group("shop_card"):
								var temp_card: Control = rest_nodes[index].card
								temp_card.rest_node = rest_node
								temp_card.current_rest_node = current_rest_node
								rest_nodes[current_rest_node].card = temp_card
								rest_node = child
								current_rest_node = index
								child.card = self
						else:
							if !child.is_in_group("locked"):
								if current_rest_node >= 0: 
									rest_nodes[current_rest_node].card = null
								if is_in_group("shop_card"):
									# moving shop card into the deck - charging gold
									if Game.blue_gold >= cost:
										Game.blue_gold -= cost
										add_to_group("deck_card")
										remove_from_group("shop_card")
										match cardsUI.lane_value:
											0: 
												cardsUI.top_lane_cards.append(self)
											1: 
												cardsUI.middle_lane_cards.append(self)
											2: 
												cardsUI.bottom_lane_cards.append(self)
										rest_node = child
										current_rest_node = index
										child.card = self
								else:
									rest_node = child
									current_rest_node = index
									child.card = self
						cardsUI.refresh_cards.emit()
				index += 1
			selected = false
			is_hovering_above = false
			$CardPanelBig.visible = false
			$CardPanelSmall.visible = true
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
