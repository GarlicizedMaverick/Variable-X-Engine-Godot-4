extends Node


var arms_parts_acquired: bool
var legs_parts_acquired: bool
var head_parts_acquired: bool
var body_parts_acquired: bool

enum HeartTanksCollected # Values are powers of two so I can do bitwise operations on them.
{
	NONE = 0,
	CHILL = 1,
	SPARK = 2,
	ARMORED = 4,
	LAUNCH = 8,
	BOOMER = 16,
	STING = 32,
	STORM = 64,
	FLAME = 128
}
var heart_tanks_collected: HeartTanksCollected
var number_of_heart_tanks_collected: int = 0

enum StageFlags
{
	NULL = 0,
	INTRO_STAGE_BEATEN = 1,
	CHILL_BEATEN = 2,
	SPARK_BEATEN = 4,
	ARMORED_BEATEN = 8,
	LAUNCH_BEATEN = 16,
	BOOMER_BEATEN = 32,
	STING_BEATEN = 64,
	STORM_BEATEN = 128,
	FLAME_BEATEN = 256,
	SIGMA_INTRO_BEATEN = 512,
	FLOOR_1_BEATEN = 1024,
	FLOOR_2_BEATEN = 2048,
	FLOOR_3_BEATEN = 4096,
	FLOOR_4_BEATEN = 8192,
	X_LAST_STAND = 16384,
	SIGMAGEDDON = 32768,
	RISE_OF_MMX = 65536
}
var stage_flags: StageFlags

enum CapsuleBossesDefeated
{
	NONE = 0,
	CHILL = 1,
	SPARK = 2,
	ARMORED = 4,
	LAUNCH = 8,
	BOOMER = 16,
	STING = 32,
	STORM = 64,
	FLAME = 128
}
var capsule_bosses_defeated: CapsuleBossesDefeated

var order_of_maverick_stages_beaten: Array
var number_of_maverick_stages_beaten: int# = len(order_of_maverick_stages_beaten)
var number_of_completed_playthroughs: int = 0

var current_ki: int = 0
