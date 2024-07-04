extends Control

@export var name_label_big: Label
@export var image_rect_big: TextureRect
@export var description_label: Label
@export var name_label_back: Label
@export var cost_label_big: Label
@export var special_ability_label: Label
@export var health_label_big: Label
@export var armor_label_big: Label
@export var attack_damage_label_big: Label

@export var name_label_small: Label
@export var image_rect_small: TextureRect
@export var cost_label_small: Label
@export var health_label_small: Label
@export var attack_damage_label_small: Label
@export var armor_label_small: Label
@export var cost_sprite_small: Sprite2D

var card_name: String
var image: Texture2D
var description: String

var health: int
var attack_damage: int
var armor: int
var attack_speed: float
var attack_range: float
var cost: int

enum mob_race {HUMAN_KINGDOM, OUTLAWS, MOUNTAIN_CLAN, FOREST_ORCS, BLOOD_BROTHERHOOD, UNDEAD_PACT, MOON_ELVES, SUN_ELVES, BEAST}
var race: mob_race

enum mob_type {MELEE, RANGED, MAGE}
var type: mob_type

enum mob_sub_type {WARRIOR, ARCHER, HEALER, TANK, CASTER, AOE, ASSASSIN, ENCHANTER} #mob's sub-class
var sub_type: mob_sub_type

enum card_tier {COMMON, RARE, EPIC, LEGENDARY}
var tier: card_tier

var model: PackedScene

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
	card_name = card_resource.card_name
	image = card_resource.image
	description = card_resource.description
	health = card_resource.health
	attack_damage = card_resource.attack_damage
	armor = card_resource.armor
	attack_speed = card_resource.attack_speed
	attack_range = card_resource.attack_range
	cost = card_resource.cost
	race = card_resource.race
	type = card_resource.type
	sub_type = card_resource.sub_type
	tier = card_resource.tier
	model = card_resource.model

func update_card():
	if card_resource:
		$CardPanelSmall.visible = true
		$CardPanelBig.visible = false
		$CardPanelBig/FaceSide.visible = true
		$CardPanelBig/ReverseSide.visible = false
		name_label_big.text = card_name
		name_label_back.text = card_name
		name_label_small.text = card_name
		var ls = LabelSettings.new()
		#modify label color depending on card's tier
		var tier_value: int = tier
		match tier_value:
			0: #COMMON tier
				ls.font_color =  Game.common_color
			1: #RARE tier
				ls.font_color =  Game.rare_color
			2: #EPIC tier
				ls.font_color =  Game.epic_color
			3: #LEGENDARY tier
				ls.font_color =  Game.legendary_color
			_: #Default case
				ls.font_color =  Game.common_color
		ls.outline_size = 3
		ls.outline_color = Color.BLACK
		var fv = FontVariation.new()
		fv.set_variation_embolden(0.5)
		name_label_big.label_settings = ls
		name_label_big.add_theme_font_override("font", fv)
		name_label_small.label_settings = ls
		name_label_small.add_theme_font_override("font", fv)
		name_label_back.label_settings = ls
		name_label_back.add_theme_font_override("font", fv)
		#modify card's background color depending on card's race
		var color
		#0 - HUMAN_KINGDOM, 1 - OUTLAWS, 2 - MOUNTAIN_CLAN, 3 - FOREST_ORCS, 4 - BLOOD_BROTHERHOOD
		#5 - UNDEAD_PACT, 6 - MOON_ELVES, 7 - SUN_ELVES, 8 - BEAST
		var race_value: int = race
		match race_value:
			0: #HUMAN_KINGDOM
				color = Game.human_kingdom_color
			1: #OUTLAWS
				color = Game.outlaws_color
			2: #MOUNTAIN_CLAN
				color = Game.mountain_clan_color
			3: #FOREST_ORCS
				color = Game.forest_orcs_color
			4: #BLOOD_BROTHERHOOD
				color = Game.blood_brotherhood_color
			5: #UNDEAD_PACT
				color = Game.undead_pact_color
			6: #MOON_ELVES
				color = Game.moon_elves_color
			7: #SUN_ELVES
				color = Game.sun_elves_color
			8: #BEAST
				color = Game.beast_color
			_: #Default case - HUMAN_KINGDOM
				color = Game.human_kingdom_color
		$CardPanelBig/Panel.modulate = color
		$CardPanelSmall/Panel.modulate = color
		image_rect_big.texture = image
		image_rect_small.texture = image
		cost_label_big.text = str(cost)
		cost_label_small.text = str(cost)
		#race_type_label.text = str(mob_type.keys()[type]) + " " + str(mob_sub_type.keys()[sub_type])
		special_ability_label.text = str(description)
		health_label_big.text = str(health)
		health_label_small.text = str(health)
		attack_damage_label_big.text = str(attack_damage)
		attack_damage_label_small.text = str(attack_damage)
		armor_label_small.text = str(armor)
		armor_label_big.text = str(armor)
		var _race = str(mob_race.keys()[race])
		var _race_words = _race.split("_")
		if _race_words.size() > 1:
			_race = _race_words[0].to_pascal_case() + " " + _race_words[1].to_pascal_case()
		else:
			_race = _race.to_pascal_case()
		description_label.text = str(health) + " Health" + "\n" + str(attack_damage) + " Attack Damage" + "\n" + \
		str(attack_speed) + "/s Attack Speed\n"+ str(armor) + " Armor Points" + "\n" + \
		str(card_tier.keys()[tier]) + " Tier" + "\n" +  _race + " Unit" + "\n" + \
		str(attack_range) + " Attack Range"

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	else:
		if rest_node != null:
			var position = rest_node.global_position + rest_node.pivot_offset
			if is_hovering_above == true:
				position = position - Vector2(0, 15)
			global_position = lerp(global_position, position, 10 * delta)

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
							if Game.player1_gold >= cost:
								Game.player1_gold -= cost
								cardsUI.card_cost_popup.visible = true
								cardsUI.card_cost_popup.get_node("Label").text = "-" + str(cost) + "G"
								cardsUI.popup_timer.start()
								cardsUI.card_cost_popup.position = node.global_position - Vector2(-25, 70)
								add_to_group("deck_card")
								remove_from_group("shop_card")
								cost_sprite_small.visible = false
								#cost_label_small.text = ""
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
					var sell_zone = get_tree().get_first_node_in_group("sell_zone")
					var distance = global_position.distance_to(sell_zone.global_position + sell_zone.pivot_offset)
					if distance < shortest_dist:
						#INFO sell the card, as the rest node is the sell zone
						Game.player1_gold += (cost / 2)
						rest_nodes[current_rest_node].card = null
						queue_free()
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
	position = position - Vector2(0, 20)

func _on_mouse_click_control_mouse_exited():
	is_hovering_above = false
	$CardPanelBig.visible = false
	$CardPanelSmall.visible = true
