extends Control

@export var name_label: Label
@export var image_rect: TextureRect
@export var description_label: Label
@export var cost_label: Label
@export var race_type_label: Label
@export var health_label: Label
@export var armor_label: Label
@export var attack_damage_label: Label

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

var card_resource: Resource	
var is_showing_reverse: bool = false
func _ready():
	update_card()

func _set_variables(resource: Resource):
	card_resource = resource
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
		$FaceSide.visible = true
		$ReverseSide.visible = false
		name_label.text = card_name
		image_rect.texture = image
		cost_label.text = str(cost) + "G"
		race_type_label.text = str(mob_type.keys()[type]) + " " + str(mob_race.keys()[race])
		health_label.text = str(health) + "♥"
		attack_damage_label.text = str(attack_damage) + "AD"
		
		description_label.text = str(health) + " Health" + "\n" + str(attack_damage) + " Attack Damage" + "\n" + \
		str(attack_speed) + "/s Attack Speed\n"+ str(armor) + " Armor Points" + "\n" + \
		str(card_tier.keys()[tier]) + " Tier" + "\n" + str(mob_type.keys()[type]) + " " + str(mob_race.keys()[race]) + " Unit Type" + "\n" + \
		str(cost) + " Gold"


func _on_mouse_click_control_gui_input(event):
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_showing_reverse:
				is_showing_reverse = false
				$FaceSide.visible = true
				$ReverseSide.visible = false
			else:
				is_showing_reverse = true
				$FaceSide.visible = false
				$ReverseSide.visible = true
				
