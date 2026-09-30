# Variable X Engine [Godot 4]
Mega Man X-styled character controller in Godot 4.x

Current Godot version: 4.7.2

Base resolution: 960x540 pixels

Gameplay resolution: 640x512 pixels

Tile size: 32x32 pixels

<br>

Essentially, I use a resolution of 320x256 (1 tile taller than the PS1 games (which are 1 tile taller than the SNES games)). I'm using assets that are about proportional to the SNES games, just scaled by 2x on each axis. The rest of the screen is filled up by Godot logos on either side that I plan on replacing with wallpapers (as you'd see in one of the Legacy Collections).

<br>

## Features
* Jumping
* Walking
  * In the SNES games, when beginning to walk from the idle state, X will move slower (1 p/f (pixel per frame)) for the first five frames. This is akin to the "tiptoe" of the Classic games. I've implemented that here as an option (boolean).
* Dashing
  * In the SNES games, the dash has a constant speed, but in the PS1 games, the dash starts slow and accelerates. I use the SNES style.
  * In the PS1 games, X can gain dash speed from a normal jump if the player holds the dash button. I've implemented this as an option (boolean).
  * In most X games, if the player inputs the opposite direction while dashing, the dash will be canceled (like the slide in Classic). I chose to implement the Zero/ZX style that allows you to turn around while dashing.
  * I've created an optional "Superdash" (boolean) that lets X dash indefinitely. It also makes X dash so long as the dash button is held, so you can dash constantly in other words.
  * Dashing shortens the player's hurtbox in every implementation of a post-Classic title, but some of them (Zero/ZX) also make the collider wider. The SNES and PSX X games don't, and this is what I follow.
  * However, unlike any implementation of the dash seen before, the dash in this project also allows X to traverse between 1-tile gaps like the Classic slide. Naturally, the collider shortens to allow this, although from my testing, I don't believe that the actual collider of the dash gets shorter in any Mega Man game, just the hurtbox. I can definitely say that the collider *doesn't* get shorter in the SNES games and MHX, as you can get pushed by the Axe Max's logs even while dashing beneath them.
* Slopes
  * The SNES and PS1 games only use two slope grades: 2x1 tiles & 4x1 tiles.
  * I've implemented slopes of 4x1 tiles (~14 degrees) / 3x1 tiles (~18 degrees) / 2x1 tiles (~26 degrees) / 1x1 tiles (45 degrees)
* SNES-style Slope Physics
  * When walking down a slope, X will go faster depending on the gradient. His speed is unaffected while going up a slope.
    * Note that the tiptoe overrides slope speed while active. This is accurate to the SNES games.
  * X will also jump higher if he does so while walking down a slope (again, the height depending on the gradient).
  * In the actual SNES games, X doesn't jump higher while dashing down a slope, but he does in this project since I prefer it that way (and it makes more sense).
* Wall Physics
  * In the SNES games, X takes 8 frames to grab onto a wall. Only then will he start sliding down it. I use this timing.
  * X's walljump in the SNES/PS1 games have a minimum jump height. In the Zero/ZX games, the wall jump can be cancelled immediately. I chose the Zero/ZX implementation.
  * When X hits a ceiling while walljumping, the walljump gets canceled.
  * When X's back hits terrain while walljumping, the walljump doesn't get canceled in the SNES games, but *does* in the PS1 games. I chose the SNES implementation.
  * In most post-Classic titles, the player can wall jump without actually need to be ON the wall. The length of how far the player can be varies greatly depending on the game. I use RayCast2Ds of a certain length to implement this. They can be easily changed to suit one's needs.
  * In the SNES games, X will snap closer to a wall if he walljumps off of it from a distance. I've simulated this mechanic (probably not particularly accurately).
  * Dash wall jumps are styled after X2's and onward (the dash button only needs to be held) rather than X1/MHX's (dash button needs to be pressed around the same time as the jump button).
  * In the SNES games and MHX (and some Classic titles such as 6 and Wily Wars) when the player walks off of a ledge, if they move back into it before they fall too far, they will snap back to the floor above. I do not implement it, as I personally find it annoying in an X game. I'd prefer to walk off of a ledge, change direction, then start sliding immediately. I find it moderately useful in a Classic game, however.
* Knockback State
  * In the SNES games, the knockback state lasts 31 frames (~0.51666 seconds) but I have it set to 0.3 seconds (closer to the Zero/ZX games)
  * In the SNES and GBC games, X could cancel the knockback state by grabbing onto a wall. I have implemented this.
  * If X gets hit while sliding down a wall, he gets knocked off of the wall, but is able to grab it immediately in the SNES/GBC games. I've implemented this. In all of the other X(-esque) games, the player can't re-grab the wall *at all*.
  * X can wall jump out of the knockback state if he's close enough to a wall, though this behavior isn't in ANY post-Classic Mega Man title.
* Invincibility Frames
  * Last for exactly 1.5 second (90 frames at 60 Hz) by default. This is slightly inaccurate to the SNES games which have an i-frame period of 93 frames. Although, the Zero/ZX games use 90 frames.
* Jump Buffer
  * A side effect of the jump buffer is that it lets the player do dash jumps as long as the dash button is held while the buffered jump starts. This nearly perfectly resembles the frame-perfect chained dash jumps of the Zero/ZX games. This wasn't an intentional design decision, just a neat coincidence.
  * Do note however, that in *my* version, the dash button *needs* to be held to get the dash jump, whereas in the Zero/ZX games, the dash button *doesn't* strangely enough.
* Coyote Timer
  * Note that you probably won't notice it if you just walk off of a ledge, as X will most likely wall jump instead. It's more noticeable with the dash since you get out of near-wall range sooner. Though do note using my default values, it IS possible to do a coyote jump without dashing.
* Basic Hitbox/Hurtbox System
* Dummy Enemy
  * Does nothing but damage the player to show off the knockback state.
* Lemons
  * No interactions are coded, just spawning, moving, and self-deletion once offscreen.
  * In the SNES games, lemons start at a speed of 4 p/f and accelerate at a rate of 0.25 p/f^2 to a max speed of 6 p/f. I've multiplied these values by 5/4 since I use a base width of 320 px rather than the SNES's 256 px.
* Basic Camera System
  * Somewhat based off of how the SNES/PS1 games handle it (a bunch of areas that interpolate the camera bounds over a set amount of time)
  * X's position is clamped within the camera bounds. I believe this is how the actual SNES/PS1 games work.
  * While I haven't implemented a death/respawn system yet, I could pretty easily implement instant death pits by checking if X's position equals the camera's lower bound.
  * You don't hit your head on an invisible ceiling at the camera's upper bound (unless there's terrain above, of course). This is how the SNES games work, but I believe that in the PlayStation games the camera's upper bound *does* act as a ceiling.
* Ki
  * This is completely of my own designs. This project is a base for a personal project of mine: a(nother) remake of X1 (and maybe the rest, too). Part of that involves playing more into the growth arc present in the narrative. Ki is the instrument that brings it into gameplay.
  * As Ki increases, X will jump higher, dash/shoot faster, increase his attack power, gain various properties taken from the parts systems of X5-X7, and so on.
  * You can safely ignore this if you want a vanilla X-styled controller, but feel free to play around with it if you like it and maybe even implement it in your own projects.

<br>

## Notes on the SNES Titles
### Player Velocity
X’s speed in subpixels (using signed notation) given in pixels per frame and pixels per second (+Y is up)  
(divide by 256 to get pixels per frame (p/f) multiply that by 60 to get pixels per second (p/s))

Horizontal speed values occupy the hex address 0009F2 (X2/X3) or 000BC2 (X1).  
Vertical speed values occupy the hex address 0009F4 (X2/X3) or 000BC4 (X1).
Each hex address mentioned is 2 bytes large.

#### Horizontal
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

#### Vertical
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

### Invincibility

I-frames in all 3 SNES X games last for 92 frames (You get hit again on the 93rd frame).  
You gain back control after 33 frames (on the 34th frame). I can’t quite tell, but I think X3 takes an extra frame to give back control.  

SNES Charged Chameleon Sting lasts for 482 frames (you get hit again on the 483rd frame).  
This is just over eight seconds. (8.0333~)

<br>

### X-Buster Data

Values occupy hex address 0010F2 (X2/X3) or 001242 (X1).  
Each hex address mentioned is 2 bytes large.

NAMING:  
"Lemons" are the yellow default X-Buster shot. It's a common name for default shots within the community.  

"Dash-lemons" are just lemons that have been shot while X is in the dashing state/has dash speed. They're not identical to normal lemons, hence the differentiation.  

"Limes" are the first-level charge of the default X-Buster. They're green and longer than they are tall, so to fit with lemons, I just call them limes as a shorthand.  

"Blueberries" are the second-level charge of the default X-Buster. They're large, round, and blue. While not citrus, it still fits within the fruit category.  

"Spiral Crush Buster" is the official name of the third-level charge of the upgraded X-Buster in X1. You may or may not see me refer to them as "bubblegum" or "raspberries".  

"Double Charge Shot" or "Double-shot" refers to an archetype of shot wherein X can unleash two charged blasts in succession. There are multiple variations, so I'll specify when necessary.

#### Lemons
* Initial Speed: 1024 sp/f   ||   4 p/f   ||   240 p/s
* Acceleration: 64 sp/f   ||   0.25 p/f   ||   15 p/s
* Max Speed: 1536 sp/f   ||   6 p/f   ||   360 p/s

#### Dash-lemons, Limes, and Spiral Crush Buster
* Speed: 1536 sp/f   ||   6 p/f   ||   360 p/s
* No acceleration

#### Blueberries
* Speed: 2048 sp/f   ||   8 p/f   ||   480 p/s
* No acceleration

#### Double-shots (X2)
* Initial Speed: 512 sp/f   ||   2 p/f   ||   120 p/s
* Acceleration: 64 sp/f   ||   0.25 p/f   ||   15 p/s
* Max Speed: 2048 sp/f   ||   8 p/f   ||   360 p/s
