## RowBot Rally
Team up with a mechanical pal and row for the gold in the annual Fish Bowl!

## Things to do!
* Title screen
  * Sound effects
  * Music
  * Smooth transition between options
  * Animation on the side arrows
  * Lock shake animation when trying to open a hidden item
  * "Reset progress?" prompt if starting new game with an existing file
* Options screen
  * Sound effects
  * Music
  * Music and SFX sliders
    * Make the sliders function graphically
    * Make them function aurally as well
  * Back to title slide button
  * Cutscene picker
    * Make graphics
    * Make selector
    * Animation on the side arrows
    * Gray out/disable OK button if cutscene is locked
    * Smooth sliding transition between scenes
    * Short names + thumbnails for each scene
    * Enter/exit animations on the selector
  * Reset all save data
    * Prompt
      * Hold button to reset, with inversion effect
    * Delete save data, show new prompt, return to title
  * Save music/SFX changes upon leaving
* Boat garage
  * Blast-doors transition out of the garage
* Track select
  * Make graphics
    * 2D side views for each boat
    * Thumbnails for each stage
  * Make selector logic
  * Show best time for each track
  * Short descriptions for every stage
  * Smooth transition between items
  * Gray out and disable go button if stage is locked
  * Hide stage info and art if stage is locked - obscured by dog?
* Race intro
  * Make graphics
    * Spinning 3D models of each rowbot? or just character portraits?
  * Show current stage name, key art?
  * Show quick stats of the current boat?
  * Stage objective ("beat this rowbot!", "get out of the maze!", etc.)
* Gameplay / Race screen
  * Restart race slide button (if race is active)
  * Back to title slide button (if the race hasn't ended)
  * Make graphics
    * Top views for all the boats
    * Draw out all seven tracks
    * Countdown overlay
    * Finish overlay
    * Reaction images for the corner
      * Win
      * Lose
      * Secret
      * Neutral
      * Crash
      * Obscured by crank UI
      * Dizzy
  * Sound effects
    * Moving & Steering
    * Crashes
    * Countdown
    * Finish
  * Music for each track
  * Boat steering logic
  * Boat collision logic
  * Laps logic
    * Checkpoints that the boat has to pass
    * Increment laps counter if all the checkpoints are passed when you cross the finish line
    * After 3 laps are done, finish race
  * opponent racer AI logic
    * Somehow get them to follow a track?
    * Different behaviors for different rowbots? junky rowbot is all over the place, etc
    * Check if they're ahead of or behind you
    * Track what lap they're on currently
  * Delta time
* Race Results
  * Get snapshot of last race frame to display in background arg
  * Arg of race time
  * Arg of track just played
  * Arg of win/loss/time trials
  * Make graphics
    * New background plates for win/loss/trials
    * Win/loss reaction images for the corner
  * Show current time on the plate
  * Show best time on the plate if not new best
  * If new best, show that graphic
  * Map buttons to appropriate actions depending on the outcome
    * Win = A proceed, B back to title
    * Lose = A retry, B back to title
    * Trials - A new track, B back to title
  * Add appropriate buttons to slide menu as well
    * Win = back to title
    * Loss = Retry, back to title
    * Trials = new track, new boat, back to title
* Shark chase
  * Map the crank to lefty-righty steering
  * Make graphics
    * Characters rowing on the Raft, from behind
    * Shark just under
    * Looping river view for background
    * Various rocks of different sizes
  * Sound effects
    * Rowing
    * Crash
    * Shark?
  * Randomly generate rock positions
  * End after a certain (random?) amt of time
  * Crash logic
* Cutscene viewer
  * Play border intro animation before cutscene starts (hang on first frame till then)
  * Figure out how PDV files work - ask nino for help?
  * Play border outro animation after cutscene ends (hang on last frame)
  * Skip button that immediately plays border outro, moves onwards
  * Back to title slide button
  * Mark cutscene in save data
  * Make the actual cutscenes (lol that this is one single entry)
* Credits sequence
  * Credits music (w/ lyrics?)
  * Post-story sequence in polaroids
  * Write out actual game credits
  * Arg to tell what scene to go to aftewards
* Addtl. stuff
  * System assets
    * Launcher card
    * Launch animation
    * Launch sound effect
    * New wrapping paper
  * Instruction manual
  * Key art for characters
  * Key art for stages
  * Key art for boats
  * Soundtrack
  * Set up itch page
  * pitch to catalog???
    * if that works(???)...deal w/ leaderboards.
