extends Resource

@export var card_name: String
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

@export var model: PackedScene

@export var special_ability_stats: MobSpecialAbility
