# Notes on the SNES Titles
## Player Velocity
X’s speed in subpixels (using signed notation) given in pixels per frame and pixels per second (+Y is up)  
(divide by 256 to get pixels per frame (p/f) multiply that by 60 to get pixels per second (p/s))

Horizontal speed values occupy the hex address 0009F2 (X2/X3) or 000BC2 (X1).  
Vertical speed values occupy the hex address 0009F4 (X2/X3) or 000BC4 (X1).
Each hex address mentioned is 2 bytes large.

### Horizontal
* 256 starting from a walk (ground only) for the first five frames (1 p/f   ||   60 p/s)
  * Also while sliding down a wall, for whatever reason
  * This also applies while walking down a slope
* 376 while walking/wall jumping (1.46875 p/f   ||   88.125 p/s)
  * If the player jumps while walking down a slope before gaining the proper slope speed, this will be their speed instead
  * This only applies from a tiptoe, not from landing on a slope from a jump/fall as they gain the proper slope speed in that instance
  * Both of these properties also apply to vertical speed
* 408 while walking down a gentle slope (1.59375 p/f   ||   95.625 p/s)
* 456 while walking down a steep slope (1.78125 p/f   ||   106.875 p/s)
* 885 while dashing/dash wall jumping (3.45703125 p/f   ||   207.421875 p/s)
* ±138 (depending on direction) while taking damage (31 frames) (±0.5390625 p/f   ||   ±32.34375 p/s)
  * NOT halved with the chest part
* ±64 (depending on direction) while starting a Giga Crash (~32 frames) (±0.25 p/f   ||   ±15 p/s)

### Vertical
* 1363 when starting a jump/wall jump (5.32421875 p/f   ||   319.453125 p/s)
* 1417 when starting a jump from a gentle downslope (4x1 tiles) (5.53515625 p/f   ||   332.109375 p/s)
* 1505 when starting a jump from a steep downslope (2x1 tiles) (5.87890625 p/f   ||   352.734375 p/s)
* 0 while grabbing a wall (this lasts for eight frames)
* -64 when cancelling a jump (NOT halved when underwater) (-0.25 p/f   ||   -15 p/s)
  * This also applies to letting go of a wall, climbing down a raised ladder, and letting go of a ladder.
* -512 while wall-sliding (halved when underwater) (-2 p/f   ||   -120 p/s)
* -1472 terminal velocity (-737 when underwater) (-5.75 p/f   ||   -345 p/s) . . . (-2.87890625 p/f   ||   -172.734375 p/s)
* -2048 when entering a level (teleporting downward) (-8 p/f   ||   -480 p/s)
* ±376 up/down ladders (no armor) (same as walking)
* ±752 up/down ladders (with arm and leg parts) (±2.9375 p/f   ||   ±176.25 p/s)
* 512 when climbing up the top of a ladder (four frames) (2 p/f   ||   120 p/s)
* 512 when first taking knockback from a damage source (2 p/f   ||   120 p/s)
  * Halved with the chest part
* 128 while starting a Giga Crash (~32 frames) (0.5 p/f   ||   30 p/s)

NOTE: His actual movement speed can differ, as these horizontal values are identical while it’s raining in Wire Sponge’s stage despite it lowering his speed.

<br>

## Invincibility

I-frames in all 3 SNES X games last for 92 frames (You get hit again on the 93rd frame).  
You gain back control after 33 frames (on the 34th frame). I can’t quite tell, but I think X3 takes an extra frame to give back control.  

SNES Charged Chameleon Sting lasts for 482 frames (you get hit again on the 483rd frame).  
This is just over eight seconds. (8.0333~)

<br>

## X-Buster Data

Horizontal values occupy hex address 0010F2 (X2/X3) or 001242 (X1).  
Vertical values occupy hex address 0010F4 (X2/X3) or 001244 (X1).  
Each hex address mentioned is 2 bytes large.

NAMING:  
"Lemons" are the yellow default X-Buster shot. It's a common name for default shots within the community.  

"Dash-lemons" are just lemons that have been shot while X is in the dashing state/has dash speed. They're not identical to normal lemons, hence the differentiation.  

"Limes" are the first-level charge of the default X-Buster. They're green and longer than they are tall, so to fit with lemons, I just call them limes as a shorthand.  

"Blueberries" are the second-level charge of the default X-Buster. They're large, round, and blue. While not citrus, it still fits within the fruit category.  

"Spiral Crush Buster" is the official name of the third-level charge of the upgraded X-Buster in X1. You may or may not see me refer to them as "bubblegum" or "raspberries".  

"Double Charge Shot" or "Double-shot" refers to an archetype of shot wherein X can unleash two charged blasts in succession. There are multiple variations, so I'll specify when necessary.

### Lemons
* Initial Speed: 1024 sp/f   ||   4 p/f   ||   240 p/s
* Acceleration: 64 sp/f   ||   0.25 p/f   ||   15 p/s
* Max Speed: 1536 sp/f   ||   6 p/f   ||   360 p/s

### Dash-lemons, Limes, and Spiral Crush Buster
* Speed: 1536 sp/f   ||   6 p/f   ||   360 p/s
* No acceleration

### Blueberries
* Speed: 2048 sp/f   ||   8 p/f   ||   480 p/s
* No acceleration

### Double-shots (X2)
* Initial Speed: 512 sp/f   ||   2 p/f   ||   120 p/s
* Acceleration: 64 sp/f   ||   0.25 p/f   ||   15 p/s
* Max Speed: 2048 sp/f   ||   8 p/f   ||   360 p/s
