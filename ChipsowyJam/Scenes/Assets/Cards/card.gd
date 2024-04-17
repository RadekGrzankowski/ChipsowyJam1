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
func _ready():
	_update_card()

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

func _update_card():
	if card_resource:
		name_label.text = card_name
		image_rect.texture = image
		description_label.text = description
		cost_label.text = str(cost) + "G"
		race_type_label.text = str(mob_type.keys()[type]) + " " + str(mob_race.keys()[race])
		health_label.text = str(health) + "HP"
		armor_label.text = str(armor) + "ARM"
		attack_damage_label.text = str(attack_damage) + "AD"
