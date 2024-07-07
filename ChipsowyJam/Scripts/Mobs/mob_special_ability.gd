@tool
class_name MobSpecialAbility extends Resource

enum activation {ON_HIT, ON_DAMAGED, ON_KILL, ON_DEATH, ON_BUFF, ON_SPAWN}
@export var ability_activation: activation #1 - On hit | 2 - On damaged | 3 - On kill | 4 - On death | 5 - On buff | 6 - On spawn 
@export var ability_amount: float ## If <1 - percentage, >1 - int amount
enum elemental {FIRE, ACID, BLOOD, TOXIC}
@export var ability_elemental: elemental #Fire, acid, blood etc
@export var ability_radius: int # Used for aoe abilities and auras
@export var ability_chance: float # Float <1 (percentage)
@export var ability_duration: float # Used for damage over time abilities as well as stuns and other timed abilities (in seconds) 
enum buff_type {ATTACK, ARMOR, ATTACK_SPEED, RANGE, MOVEMENT_SPEED}
@export var ability_buff_type: buff_type #1 - Attack | 2 - Armor | 3 - Attack speed | 5 - Range | 6 - Movement Speed tbd
