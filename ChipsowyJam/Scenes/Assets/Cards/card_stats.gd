extends Resource

@export var name: String
@export var image: Texture2D

enum mob_race {HUMAN_KINGDOM, OUTLAWS, MOUNTAIN_CLAN, FOREST_ORCS, BLOOD_BROTHERHOOD, UNDEAD_PACT, MOON_ELVES, SUN_ELVES, BEAST}
@export var race: mob_race

enum card_tier {COMMON, RARE, EPIC, LEGENDARY}
@export var tier: card_tier

@export var description: String
@export var cost: int
@export var health: int
@export var attack_damage: int
@export var armor: int
@export var attack_speed: float
@export var attack_range: float

enum mob_type {MELEE, RANGED, MAGE} #mob's class
@export var type: mob_type

enum mob_sub_type {WARRIOR, ARCHER, HEALER, TANK, CASTER, AOE, ASSASSIN, ENCHANTER} #mob's sub-class
@export var sub_type: mob_sub_type

func _init(p_name = "", p_image = null, p_cost = 0, p_race = 0, p_description = "", p_health = 0, 
p_attack_damage = 0, p_armor = 0, p_attack_speed = 0.0, p_type = 0, p_tier = 0, p_sub_type = 0, p_range = 0.0):
	name = p_name
	image = p_image
	cost = p_cost
	race = p_race
	description = p_description
	health = p_health
	attack_damage = p_attack_damage
	armor = p_armor
	attack_speed = p_attack_speed
	attack_range = p_range
	type = p_type
	sub_type = p_sub_type
	tier = p_tier
	
