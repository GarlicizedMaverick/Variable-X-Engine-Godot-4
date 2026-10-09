extends Node


@export_flags\
(
	"ARMS",
	"LEGS",
	"HEAD",
	"BODY"
)
var armor_parts_acquired: int

@export_flags\
(
	"CHILL",
	"SPARK",
	"ARMORED",
	"LAUNCH",
	"BOOMER",
	"STING",
	"STORM",
	"FLAME"
)
var heart_tanks_collected: int
var number_of_heart_tanks_collected: int = 0

@export_flags\
(
	"INTRO STAGE",
	"CHILL",
	"SPARK",
	"ARMORED",
	"LAUNCH",
	"BOOMER",
	"STING",
	"STORM",
	"FLAME",
	"SIGMA INTRO",
	"FLOOR 1",
	"FLOOR 2",
	"FLOOR 3",
	"FLOOR 4",
	"X'S LAST STAND",
	"SIGMAGEDDON",
	"THE RISE OF MEGA MAN X"
)
var stages_completed: int = 0

@export_flags\
(
	"CHILL",
	"SPARK",
	"ARMORED",
	"LAUNCH",
	"BOOMER",
	"STING",
	"STORM",
	"FLAME"
)
var mavericks_defeated: int

@export_flags\
(
	"CHILL",
	"SPARK",
	"ARMORED",
	"LAUNCH",
	"BOOMER",
	"STING",
	"STORM",
	"FLAME"
)
var capsule_bosses_defeated: int
var number_of_capsule_bosses_defeated: int = 0

var order_of_maverick_stages_beaten: Array[String]
var number_of_maverick_stages_beaten: int# = len(order_of_maverick_stages_beaten)
var number_of_completed_playthroughs: int = 0

var current_ki: int = 0
