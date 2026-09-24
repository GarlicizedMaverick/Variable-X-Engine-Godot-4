# Variable-X-Engine-Godot-4
Mega Man X-styled character controller in Godot 4.x

Current Godot version: 4.7.2

Base resolution: 960x540 pixels

Gameplay resolution: 640x512 pixels

Tile size: 32x32 pixels


Essentially, I use a resolution of 320x256 (1 tile taller than the PS1 games (which are 1 tile taller than the SNES games)). I'm using assets that are about proportional to the SNES games, just scaled by 2x on each axis. The rest of the screen is filled up by Godot logos on either side that I plan on replacing with wallpapers (as you'd see in one of the Legacy Collections).


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
  * In the actual SNES games, X doesn't jump higher while dashing down a slope, but he does here since I like it.
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
