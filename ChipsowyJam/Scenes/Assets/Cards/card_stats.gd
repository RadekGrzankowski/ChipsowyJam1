extends Resource

@export var name: String
@export var image: Texture2D

enum mob_race {HUMAN, ORC, UNDEAD, ELVES}
@export var race: mob_race

enum card_tier {COMMON, RARE, EPIC, LEGENDARY}
@export var tier: card_tier

@export var description: String
@export var cost: int
@export var health: int
@export var attack_damage: int
@export var armor: int
@export var attack_speed: float

enum mob_type {MELEE, RANGED, MAGE}
@export var type: mob_type

func _init(p_name = "", p_image = null, p_cost = 0, p_race = 0, p_description = "", p_health = 0, 
p_attack_damage = 0, p_armor = 0, p_attack_speed = 0.0, p_type = 0, p_tier = 0):
	name = p_name
	image = p_image
	cost = p_cost
	race = p_race
	description = p_description
	health = p_health
	attack_damage = p_attack_damage
	armor = p_armor
	attack_speed = p_attack_speed
	type = p_type
	tier = p_tier
