# This damage table is meant for enemies/bosses in the Everlasting Prelude sidegame
class_name EPEnemyDamageTable extends Resource


## A custom table for determining how much damage all of the player's attacks deal to an enemy.
@export var damage_table: Dictionary[String, float] =\
{
	"Lemon": 1, # Default X-buster shot
	"Dash Lemon": 1.5, # Default shot while dashing
	"Lime": 2, # X-buster charge level 1
	"Blueberry": 3, # X-buster charge level 2
	"Rolling Cutter": 30, # * delta, since it's a continuous hitbox (0.5 damage per frame)
	"Elec Beam": 3, # Not multiplied by delta since it hits foes only once despite being continuous
	"Fire Storm": 3, # Includes the fireballs that circle the player
	"Hyper Bomb": 60, # * delta 
	"Thrown Guts Object": 5,
	"Bubble Lead": 2,
	"Atomic Fire Level 1": 2,
	"Atomic Fire Level 2": 4,
	"Atomic Fire Level 3": 8,
	"Leaf Shield": 3,
	"Air Shooter": 2, # Each projectile (up to 6 damage total)
	"Crash Bomber Bomb": 3,
	"Crash Bomber Explosion": 30, # * delta
	"Quick Boomerang": 0.5, # Each projectile
	"Metal Blade": 1,
	"Top Spin": 30, # * delta
	"Shadow Blade": 2,
	"Spark Shock": 1,
	"Magnet Missile": 2,
	"Hard Knuckle": 6,
	"Gemini Laser": 60, # * delta
	"Needle Cannon": 1,
	"Search Snake": 2
}
# Ice Slasher and Time Stopper are absent since they don't deal direct damage.
# I'm gonna make Time Stopper work like Flash Stopper (you can shoot lemons while stopping time)...
# ...and also give the player a way to toggle the time freeze.
# While Spark Shock actually deals damage now, it only stuns enemies for half a second...
# ...and enemies that ARE stunned will fall if in mid-air.
# Ice Slasher will freeze enemies in place indefinitely.
# (And yes, I know it's actually "Thunder Beam" and "Super Arm". I don't care.)
