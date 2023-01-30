/*
Matthew Liu
 2022-04-18
 ICS3U1
 Mr. Parchimowicz
 Assignment 4 - Classic game of space invaders
 */

PImage[] images = new PImage[11];
PFont font = new PFont();
int gameState;  // 0 = menu, 1 = instructions, 2 = alien guide, 3 = ingame, 4 = win screen, 5 = lose screen

//Variables for menu
int selectedDiff; //Value of 0 is easy, 1 is medium, 2 is hard

//Variables for ingame  
boolean movingLeft, movingRight;
int playerBulletSpeed = -20; // p means player, a means alien
int playerSpeed, alienSpeed, playerX, playerY;  //playerX is x position of player, playerY is y position of player
//currentAlienDelay is the delay for aliens moving
int initialAlienDelay, alienCounter, finalAlienDelay, currentAlienDelay; //initialAlienDelay is the delay between alien movements in milliseconds, finalAlienDelay is the delay when there is just one alien left. counter counts up every time the aliens move

int aliensPerRow = 11;
int maxRows = 5; //Different gamemodes have different amounts of rows, this is the most amount of rows in any difficulty
int maxTotalAliens = aliensPerRow*maxRows;

int alienRowTypes[] = new int[maxRows]; //Tells you what type of alien is at each row. Index specifies which row aliens, 0 = top row, 1 = 2nd top row, etc
//I use alienRowTypes to figure out what kind of alien an alien index is. alienIndex/aliensPerRow will give me the row number of the alien and since all aliens in the same row are the same type, alienRowTypes[index/aliensPerRow] gives what type of alien it is 
// For 11 aliens per row, row 0 is first 11 aliens. Row 1 is aliens 12 - 22, etc. All aliens in the same "row" might not actually all be in the same "row" displayed while playing the game due to how the screen wrap works

int alienRows; //alienRows is set to the actual amount of rows. Example: for easy mode, there are 3 rows so this would be 3
int aliensAlive, initialAliensAlive; //aliensAlive is set when the game starts to how many aliens there are total and decreases as you kill aliens. initialAliensAlive is set to the same value, but is never changed unless a new game started
int playerHP;
int alienScoreValues[] = {100, 300, 500, 5000}; //Points awarded for each alien, index 0 = green alien, 1 = red alien, 2 = blue alien, 3 = ufo
int alienHp[] = new int[maxTotalAliens+1]; //how much hp each alien ingame has. Example: alienHp[13] would be equal to how much hp alien index 13 currently has

int alienHpValues[] = {1, 3, 5, 10}; //Hp each type of alien has. Index 0 = green alien, 1 = red alien, 2 = blue alien, 3 = ufo. You can set these values to all 1 to test the game faster

int alienBulletSpeedValues[] = {5, 10, 30}; //Speed of alien bullets. Index 0 = red alien, 1 = blue alien, 2 = UFO (Green alien does not shoot at all)
int alienShootChance[] = {1, 3, 25}; //percent chance that the aliens fire bullets every half second (or value of alienShootDelay in ms) . Index 0 = red alien, 1 = blue alien, 2 = UFO (Green alien does not shoot at all)
int alienShootDelay = 500, alienShootCounter = 0; //AlienShootDelay is the delay for how often aliens can shoot in ms.

color alienBulletColours[] = {#FF0000, #0000FF, #661390}; //The colour of alien bullets. Index 0 = red alien, 1 = blue alien, 2 = UFO (Green alien does not shoot at all)
int score, alienState; //alienState is which frame the alien is in. If the value is even, its at frame 0, if its odd, its at frame 1. This increments by 1 at a time so the aliens alternate between their 2 frames

boolean ufoExists; //Whether or not there is a UFO enemy (true in hard difficulty)
int ufoXSpeed = 2; //UFO actually moves every frame instead of following the alien delay so it moves more smoothly. Pixels moved per second would be this value * 60 fps
int alienPositions[][] = new int[maxTotalAliens + 1][2]; //First index box tells which alien, second box tells if it is x or y position. Ex: alienPositions[10][1] means y position of alien index 10, alienPositions[2][0] is x position for alien index 2
int alienBulletPositions[][] = new int[maxTotalAliens + 1][2]; //x and y position of alien bullets. First index specifies which alien and second specifies if the value is the x or y position. (0 = x, 1 = y)
boolean aliensShooting[] = new boolean[maxTotalAliens + 1]; //The same as playerBulletOnScreen but for all the aliens, Index 55 is the ufo
boolean playerBulletOnScreen; 
int pBulletX, pBulletY;
int alienRowSpacing = 50; //How much further down the next row of aliens are
int hitBoxes[][] = new int[5][2]; //The length and widths of the alien images and the player. first index is which type of alien (0 = green, 1 = red, 2 = blue, 3 = ufo, 4 = player), second index is x or y size (0 = x, 1 = y)
boolean ufoBoss; //this is set to true during the UFO bossfight when you kill all the other aliens and makes the ufo start making its way down the screen and makes it shootable
float scoreDecay; //This constantly rises while you are playing the game and is deducted from your score to reward you for beating the game faster

boolean playerFlash; //player turns red when this is true 
int playerFlashDelay = 300; //when player gets hit, playerFlash is set to true and will be set to false after this value in ms
int playerFlashCounter;

int aliensKilled; //Gets constantly updated ingame along with percentAliensKilled
float percentAliensKilled; //ex: 40 total aliens, 20 killed, this is 0.5 or 50%



void setup() {
  size(800, 800);
  rectMode(CENTER);
  textAlign(CENTER);
  imageMode(CENTER);
  loadImages();
  setHitboxes();
  initialVariables();
}



void draw() {
  background(#000000);
  if (gameState == 0) menuScreen();
  else if (gameState == 1) instructionScreen();
  else if (gameState == 2) guideScreen();
  else if (gameState == 3) gameScreen();
  else if (gameState == 4) winScreen();
  else loseScreen();
}



void keyPressed() {
  if (gameState == 0) { //menuScreen controls
    if (keyCode == 37) { //left arrow key
      if (selectedDiff > 0) selectedDiff = selectedDiff - 1;
      else selectedDiff = 2;
    } else if (keyCode == 39) { //right arrow key
      if (selectedDiff < 2) selectedDiff++;
      else selectedDiff = 0;
    } else if (keyCode == 73) { //I key
      gameState = 1; //instruction screen
    } else if (keyCode == 71) { //G key
      gameState = 2; //alien guide screen
    } else if (keyCode == 32) { //Spacebar
      gameState = 3; //game screen
      alienCounter = millis();
      setVariables();
    }
  } else if (gameState == 1 || gameState == 2) { //instructionScreen and guideScreen controls
    if (keyCode == 77) { //M key
      gameState = 0;
    }
  } else if (gameState == 3) { //inGame controls
    if (keyCode == 37) movingLeft = true; //Left arrow key
    else if (keyCode == 39) movingRight = true; //Right arrow key
    else if (keyCode == 32 && !playerBulletOnScreen) playerShoot(); //space bar
  } else if (gameState == 4 || gameState == 5) { //win or lose screen controls
    if (keyCode == 77) { //M key
      initialVariables();
      gameState = 0; //menu screen
    }
  }
}



void keyReleased() {
  if (gameState == 3) { //inGame controls
    if (keyCode == 37) movingLeft = false; //left arrow key
    else if (keyCode == 39) movingRight = false; //right arrow key
  }
}



void loadImages() {
  images[0] = loadImage("alien1f1.png");
  images[1] = loadImage("alien1f2.png");
  images[2] = loadImage("alien2f1.png");
  images[3] = loadImage("alien2f2.png");
  images[4] = loadImage("alien3f1.png");
  images[5] = loadImage("alien3f2.png");
  images[6] = loadImage("spaceship.png");
  images[7] = loadImage("ufo.png");
  images[8] = loadImage("trophy.png");
  images[9] = loadImage("lose.png");
  images[10] = loadImage("spaceshipflash.png");
}



void setHitboxes() {
  for (int i=0; i<3; i++) {
    hitBoxes[i][0] = images[i*2].width;
  }
  for (int i=0; i<3; i++) {
    hitBoxes[i][1] = images[i*2].height;
  }

  //ufo hitbox
  hitBoxes[3][0] = images[7].width;
  hitBoxes[3][1] = images[7].height;

  //player hitbox
  hitBoxes[4][0] = images[6].width;
  hitBoxes[4][1] = images[6].height;
}



void initialVariables() { //sets initial variable values for the start of each game
  font = createFont("Verdana", 20);
  gameState = 0;
  playerSpeed = 10;
  alienSpeed = 30;
  score = 0;
  scoreDecay = 0;
  ufoBoss = false;
  movingLeft = false;
  movingRight = false;

  //resetting all alien positions and if they are shooting
  for (int i = 0; i<maxTotalAliens; i++) {
    alienPositions[i][0] = 0;
    alienPositions[i][1] = 0;
    aliensShooting[i] = false;
  }
}



void setVariables() { //This sets up the variables for the game to be played, depending on the difficulty chosen and is run right when the game starts
  if (selectedDiff == 0) { //Easy mode
    playerHP = 10;
    initialAlienDelay = 800;
    finalAlienDelay = 800;
    alienRows = 3;
    ufoExists = false;
    aliensAlive = alienRows*aliensPerRow;
    alienRowTypes[0] = 2; //Sets what type of alien is in each row, 0 = green, 1 = red, 2 = blue, 3 = nothing
    alienRowTypes[1] = 1;
    alienRowTypes[2] = 0;
    alienRowTypes[3] = 3;
    alienRowTypes[4] = 3;
  } else if (selectedDiff == 1) { //Medium mode
    playerHP = 8;
    initialAlienDelay = 1200;
    finalAlienDelay = 400;
    alienRows = 4;
    ufoExists = false;
    aliensAlive = alienRows*aliensPerRow;
    alienRowTypes[0] = 0; 
    alienRowTypes[1] = 1;
    alienRowTypes[2] = 1;
    alienRowTypes[3] = 2;
    alienRowTypes[4] = 3;
  } else { //Hard mode
    playerHP = 8;
    initialAlienDelay = 1200;
    finalAlienDelay = 400;
    alienRows = 5;
    ufoExists = true;
    aliensAlive = alienRows*aliensPerRow;
    alienRowTypes[0] = 1;
    alienRowTypes[1] = 2;
    alienRowTypes[2] = 2;
    alienRowTypes[3] = 0;
    alienRowTypes[4] = 2;
  }
  playerX = 400;
  playerY = 650;
  initialAliensAlive = aliensAlive;

  //sets initial alien positions and alien hp
  for (int i=0; i<alienRows*aliensPerRow; i++) { //This is looping for how many aliens the difficulty has, not the max total aliens
    alienPositions[i][0] = 67 + 67*(i%aliensPerRow);
    alienPositions[i][1] = 100 + alienRowSpacing*(i/aliensPerRow);
    alienHp[i] = alienHpValues[alienRowTypes[i/aliensPerRow]]; //sets alienHp for each index to how much hp it's alien type has
  }
  //ufo hp and positions
  alienPositions[55][0] = 0;
  alienPositions[55][1] = 40; //UFO y position, this wont change during the game since ufo goes left to right, but when you beat it, the UFO will retreat up
  alienHp[55] = alienHpValues[3];
}



void menuScreen() { 
  textFont(font, 60);
  fill(#FFFFFF);
  stroke(#FFFFFF);
  text("Space Invaders", 400, 120);
  fill(#000000);

  rect(150, 350, 200, 200); //easy box
  rect(400, 350, 200, 200); //medium box
  rect(650, 350, 200, 200); //hard box

  fill(#FFFFFF);

  textFont(font, 40);
  text("Press space to start game", 400, 625);

  textFont(font, 30);
  text("Press 'I' for instructions", 400, 750);  
  text("Press 'G' for alien guide", 400, 700);  

  textFont(font, 18);
  text("Left and right arrow to change difficulty", 400, 180);

  //easy box text
  text("3 rows of aliens", 150, 300);
  text("10 lives", 150, 350);
  text("Alien speed: Fast", 150, 400);

  //medium box text
  text("4 rows of aliens", 400, 290);
  text("8 lives", 400, 320);
  text("Alien speed: Slow", 400, 350);
  text("Aliens speed up", 400, 380);
  text("as they are killed", 400, 410);

  //hard box text
  text("5 rows of aliens", 650, 280);
  text("8 lives", 650, 310);
  text("Alien speed: Slow", 650, 340);
  text("Aliens speed up", 650, 370);
  text("as they are killed", 650, 400);
  text("Enemy UFO", 650, 430);


  textFont(font, 40);
  fill(#22FF66);
  text("Easy", 150, 550);
  fill(#EEFF22);
  text("Medium", 400, 550);
  fill(#FF2222);
  text("Hard", 650, 550);

  //selection arrows to show which difficulty you are selecting
  strokeWeight(2);
  // 150 is x for easy box. 150 + 250 is x for medium box. 150 + 250*2 is x for hard box.    150 + 250*selectedDiff works since the boxes from left to right are easy, medium, hard and selectedDiff is 0=easy, 1=medium, 2=hard
  line(150 + selectedDiff*250, 475, 125 + selectedDiff*250, 490);
  line(150 + selectedDiff*250, 475, 175 + selectedDiff*250, 490);
  line(150 + selectedDiff*250, 225, 125 + selectedDiff*250, 210);
  line(150 + selectedDiff*250, 225, 175 + selectedDiff*250, 210);
}



void instructionScreen() {
  textFont(font, 60);
  fill(#FFFFFF);
  text("How to play", 400, 80);
  text("Controls", 400, 360);

  textFont(font, 22);
  text("The goal of space invaders is to shoot down all enemy aliens before", 400, 140);
  text("they reach your spaceship.", 400, 170);
  text("Aim your shots by moving your spaceship left and right", 400, 230);
  text("and be sure to dodge any attacks the aliens might shoot!", 400, 260);
  text("Left and right arrow keys to move your spaceship", 400, 420);
  text("Up arrow key to shoot a bullet", 400, 490);
  text("You can only shoot one bullet at a time so aim well!", 400, 560);

  textFont(font, 30);
  text("Press 'M' to go back to the menu", 400, 700);
}



void guideScreen() {
  textFont(font, 50);
  fill(#FFFFFF);
  text("Alien types", width/2, 75);
  //pictures of aliens
  image(images[0], 80, 160, 66, 48);
  image(images[2], 80, 320, 72, 48);
  image(images[4], 80, 480, 48, 48);
  image(images[7], 80, 640, 96, 42);

  textFont(font, 20);

  //Green alien
  text("Green alien", 80, 210);
  text("Health: 1 | Does not shoot at player |", 450, 140);
  text("Awards "+alienScoreValues[0]+" score on kill", 450, 180);

  //Red alien
  text("Health: 3 | Rarely shoots slow speed red bullets |", 450, 300);
  text("Awards "+alienScoreValues[1]+" score on kill", 450, 340);
  text("Red alien", 80, 370);

  //Blue alien
  text("Health: 5 | Occasionally shoots medium speed", 450, 460);
  text("blue bullets | Awards "+alienScoreValues[2]+" score on kill", 450, 500);
  text("Blue alien", 80, 530);

  //UFO
  text("Health: 20 | Unattackable until all aliens killed |", 450, 600);
  text("Shoots very fast purple bullets | Shoots more and moves", 450, 640);
  text("faster as aliens are killed | Awards "+alienScoreValues[3]+" score on kill", 450, 680);
  text("UFO", 80, 690);

  textFont(font, 30);
  text("Press 'M' to go back to the menu", 400, 750);
}



void gameScreen() {
  if (aliensAlive > 0 && playerHP > 0 || ufoBoss && playerHP > 0) {
    if (score>0) scoreDecay = scoreDecay + 0.15;
    if (ufoBoss) {
      textFont(font, 40);
      fill(#FF2200);
      text("Kill the UFO before it reaches you!", 400, 50);
    }

    updateGameValues();
    alienMoveTimer(currentAlienDelay);
    alienShootTimer(percentAliensKilled);
    bulletCollisions();
    movePlayer();
    drawPlayer();
    drawAliens();
    displayScore();
    displayPlayerHp();
    displayAlienHp();
    drawBullets();
    moveBullets();
    playerFlashTimer();
    checkIfAlienReachPlayer();
    checkIfBulletsOutOfBounds();
    moveUFO(percentAliensKilled);
  } else if (playerHP <= 0) { //player is dead
    gameState = 5; //lose screen
  } else if (aliensAlive <= 0 && !ufoBoss && ufoExists) ufoBoss = true; //player killed all aliens and now the ufo boss is active
  else gameState = 4; //gameState 4 is winscreen. If no aliens or UFO boss is alive and the player has more than 0 hp he wins.
}



void winScreen() { 
  textFont(font, 50); 
  fill(#FFFFFF); 
  text("Score: "+(score-int(scoreDecay)), 400, 100);
  image(images[8], 400, 400, 400, 400);
  textFont(font, 30);
  text("Press 'M' to go back to menu", 400, 700);
}



void loseScreen() {
  image(images[9], 400, 350, 400, 500);
  fill(#FFFFFF);
  textFont(font, 30);
  text("Press 'M' to go back to menu", 400, 700);
}



//Gamescreen methods
void updateGameValues() {
  aliensKilled = initialAliensAlive-aliensAlive;
  percentAliensKilled = aliensKilled*1.0/initialAliensAlive;
  currentAlienDelay = initialAlienDelay - int((initialAlienDelay - finalAlienDelay)*percentAliensKilled);
}


//sets playerFlash to false on a timer
void playerFlashTimer() { 
  if (millis() - playerFlashCounter > playerFlashDelay) playerFlash = false;
  //when the player gets hit, player flashes red. This makes it so the player only flashes red for a certain amount of time (value of playerFlashDelay in ms)
}


//timer for how often aliens are moved
void alienMoveTimer(int currentAlienDelay) {
  if (millis()-alienCounter > currentAlienDelay) {
    alienCounter = millis();
    moveAliens();
    alienState++;
  }
}



void movePlayer() { //30 and 770 are the furthest points on left and right of screen player can move to
  if (movingLeft && !movingRight && playerX >= 30) playerX = playerX - playerSpeed;
  else if (!movingLeft && movingRight && playerX <= 770) playerX = playerX + playerSpeed;
}



void moveAliens() {
  for (int i = 0; i<initialAliensAlive; i++) {
    alienPositions[i][0] = alienPositions[i][0] + alienSpeed; 
    if (alienPositions[i][0] > 840) { //if alien goes off screen to the right, it wraps and teleports to the left and 1 row down
      alienPositions[i][0] = -40; 
      alienPositions[i][1] = alienPositions[i][1] + alienRowSpacing;
    }
  }
}


//alienPositions[55][0] is the x position of the UFO
void moveUFO(float percentAliensKilled) {
  if (ufoExists) {
    if (ufoBoss) { //ufo moves a set speed during the bossfight
      alienPositions[55][0] = alienPositions[55][0] + ufoXSpeed*4;
    } else alienPositions[55][0] = alienPositions[55][0] + ufoXSpeed*int(1 + 5*percentAliensKilled); //during a normal game, ufo speeds up as more aliens are killed
    if (alienPositions[55][0] > 840) { //ufo screen wrap
      alienPositions[55][0] = -40;
      if (ufoBoss) alienPositions[55][1] = alienPositions[55][1] + alienRowSpacing;
    }
  }
}



void moveBullets() {
  //Player bullet
  if (playerBulletOnScreen) {
    pBulletY = pBulletY + playerBulletSpeed;
  }

  //Alien bullets
  for (int i=0; i<aliensShooting.length-1; i++) {
    if (aliensShooting[i]) alienBulletPositions[i][1] = alienBulletPositions[i][1] + alienBulletSpeedValues[alienRowTypes[i/aliensPerRow]-1]; //alienBulletSpeedValues[alienRowTypes[i/aliensPerRow]]; is getting the bullet speed value for the alien type
  }

  //ufo bullet
  if (aliensShooting[55]) alienBulletPositions[55][1] = alienBulletPositions[55][1] + alienBulletSpeedValues[2];
}



void drawPlayer() {
  if (playerFlash) image(images[10], playerX, playerY); //drawing red version of space ship 
  else image(images[6], playerX, playerY); //drawing normal spaceship
}


//this is the little green hp bars that appear under aliens
void displayAlienHp() {
  fill(#22FF22);
  stroke(#FFFFFF);
  for (int i = 0; i<initialAliensAlive; i++) {
    int alienType = alienRowTypes[i/aliensPerRow];
    int alienMaxHp = alienHpValues[alienType];
    if (alienHp[i] > 0 && alienHp[i] < alienMaxHp) rect(alienPositions[i][0], alienPositions[i][1] + hitBoxes[alienType][1], (hitBoxes[alienType][0]*3/2) * alienHp[i] / alienMaxHp, hitBoxes[alienType][1]/4);
    //The rect draws a rectangle center with x coordinate of alien and y coordinate a little below the alien. The width and height are based on the alien image dimensions and the width gets shorter as the hp gets lower compared to the alien's max hp
  }
  if (ufoBoss) {
    int ufoMaxHp = alienHpValues[3];
    rect(alienPositions[55][0], alienPositions[55][1] + hitBoxes[3][1], (hitBoxes[3][0]*3/2) * alienHp[55] / ufoMaxHp, hitBoxes[3][1]/4);
  }
}



void alienShootTimer(float percentAliensKilled) {
  if (millis()-alienShootCounter > alienShootDelay) {
    alienShootCounter = millis();
    aliensShoot(percentAliensKilled);
  }
}



void drawAliens() {
  //draw aliens
  for (int i = 0; i<initialAliensAlive; i++) {
    if (alienHp[i] > 0) image(images[alienRowTypes[i/aliensPerRow]*2 + alienState%2], alienPositions[i][0], alienPositions[i][1]); 
    /*  i represents the index of the each alien. alienRowTypes[i/aliensPerRow] is just giving what kind of alien index 'i' is (if its a green alien, red alien, etc)
        This gives us 0 for green alien, 1 for red alien, 2 for blue alien, but the image indexes for the aliens are images[0] = green alien, images[2] = red alien, images[4] = blue alien.
        This is because each alien has two images for its two frames (images[2] = red alien frame 1, images[3] = red alien frame 2) so the alienType is multiplied by 2 to get the index of it's image.
        alienState increases by 1 at a time when the aliens move, which means it alternates from even and odd, so its remainder modulo 2 is alternating between 0 and 1. Adding this value would make the aliens alternate
        between their image index and their image index + 1, which is the image of the alien's second frame so the alien gets alternates between it's two images and is animated.
    */
  }

  //draw ufo (UFO is alien index 55)
  if (ufoExists) {
    image(images[7], alienPositions[55][0], alienPositions[55][1]);
  }
}



void displayScore() {
  textFont(font, 30); 
  fill(#FFFFFF);
  text("Score: "+(score - int(scoreDecay)), 600, 740);
  //Score decay constantly increases as the game goes on to reward players for winning faster. The actual score variable is not changed, it is just displayed as its value minus the score decay
}



void displayPlayerHp() {
  if (playerHP == 1) fill(#FF2200);
  else if (playerHP <= 3) fill(#FFEE22);
  else fill(#11FF55);
  textFont(font, 30); 
  text("Health: "+playerHP, 200, 740);
}



void drawBullets() {
  stroke(#FFFFFF);
  fill(#FFFFFF); 
  if (playerBulletOnScreen) rect(pBulletX, pBulletY, 5, 15); //player bullets


  //alien bullets
  for (int i=0; i<aliensShooting.length-1; i++) {
    if (aliensShooting[i]) {
      fill(alienBulletColours[alienRowTypes[i/aliensPerRow]-1]); 
      rect(alienBulletPositions[i][0], alienBulletPositions[i][1], 5, 15);
    }
  }

  //ufo bullet
  if (aliensShooting[55]) {
    fill(alienBulletColours[2]); 
    rect(alienBulletPositions[55][0], alienBulletPositions[55][1], 5, 15);
  }
}


//makes all the aliens have a chance to shoot based on their percent chances in alienShootChance
void aliensShoot(float percentAliensKilled) {
  //aliens
  for (int i = 0; i<alienRows; i++) {
    if (alienRowTypes[i] > 0) { //Alien type 0 does not shoot, while type 1 and 2 shoot. This is making sure the type of aliens in each row actually shoot in the first place
      int freq = alienShootChance[alienRowTypes[i]-1]; //freq is an integer 0-100 representing a percent chance that the alien will shoot
      for (int j = 0; j<aliensPerRow; j++) {
        int alienIndex = i*aliensPerRow+j;
        if (random(100) <= freq && !aliensShooting[i] && alienHp[alienIndex] > 0) {
          aliensShooting[alienIndex] = true;
          alienBulletPositions[alienIndex][1] = alienPositions[alienIndex][1];
          alienBulletPositions[alienIndex][0] = alienPositions[alienIndex][0];
        }
      }
    }
  }

  //ufo
  int ufoFreq = int(alienShootChance[2]*(1+percentAliensKilled)); //goes from default bullet frequency to 2x frequency as percent aliens killed gets closer to 100% 
  if (random(100)<=ufoFreq && aliensShooting[55] && ufoExists && !ufoBoss) {
    aliensShooting[55] = true;
    alienBulletPositions[55][1] = alienPositions[55][1] + 20;
    alienBulletPositions[55][0] = alienPositions[55][0];
  }
}



void playerShoot() {
  playerBulletOnScreen = true; 
  pBulletX = playerX; 
  pBulletY = 625;
}



void bulletCollisions() {
  //player bullet collisions on aliens
  if (playerBulletOnScreen) {
    for (int i = aliensPerRow*alienRows-1; i>0; i--) {
      if (Math.abs(pBulletY-alienPositions[i][1]) <= hitBoxes[alienRowTypes[i/aliensPerRow]][1]/2) { //This checks if the player bullet y position is within the height of the alien's hitbox (checks if the player bullet is at any rows y position)
        for (int alienIndex = i; alienIndex>=0; alienIndex--) { 
          if (alienPositions[alienIndex][1] != alienPositions[i][1]) break; //we are checking all aliens at the same y point so this stops it if it gets to an alien at a different y position

          if (Math.abs(pBulletX-alienPositions[alienIndex][0]) <= hitBoxes[alienRowTypes[alienIndex/aliensPerRow]][0]/2 + 3 && alienHp[alienIndex] > 0) { //checks whether the player bullet x position is within the width of the alien hitbox
            alienHp[alienIndex]--; 
            if (alienHp[alienIndex] <= 0) { //killed the alien
              score = score + alienScoreValues[alienRowTypes[alienIndex/aliensPerRow]]; 
              aliensAlive--;
            }
            playerBulletOnScreen = false; 
            break; //break since we hit an alien so we shouldn't keep checking if it hits more aliens
          }
        }
        break; //break since we have already found a row of aliens thats at the bullet y position
      }
    }
  }

  //player bullet collisions on UFO boss (hitBoxes[3] is the UFO hitbox, alienHp[55] is the UFO)
  if (playerBulletOnScreen && ufoBoss) {
    if (Math.abs(pBulletY - alienPositions[55][1]) < hitBoxes[3][1]/2) {
      if (Math.abs(pBulletX-alienPositions[55][0]) < hitBoxes[3][0]/2) {
        alienHp[55]--;
        if (alienHp[55] <= 0) { //if you kill the ufo
          score = score+alienScoreValues[3];
          gameState = 4; //win
        }
        playerBulletOnScreen = false;
      }
    }
  }

  //alien bullet collisions on player (hitboxes[4] is the player hitbox)
  for (int i=0; i<aliensPerRow*alienRows-1; i++) {
    if (aliensShooting[i]) {
      if (Math.abs(alienBulletPositions[i][1] - playerY) < hitBoxes[4][1]/2) {
        if (Math.abs(alienBulletPositions[i][0] - playerX) < hitBoxes[4][0]/2) {
          playerHP--;
          aliensShooting[i] = false;
          playerFlash = true;
          playerFlashCounter = millis();
        }
      }
    }
  }

  //ufo bullet collision on player, alien 55 is the ufo
  if (aliensShooting[55]) {
    if (Math.abs(alienBulletPositions[55][1] - playerY) < hitBoxes[4][1]/2) {
      if (Math.abs(alienBulletPositions[55][0] - playerX) < hitBoxes[4][0]/2) {
        playerHP--;
        aliensShooting[55] = false;
        playerFlash = true;
        playerFlashCounter = millis();
      }
    }
  }
}


//checks if the aliens got all the way down to the alien, in which case you lose instantly
void checkIfAlienReachPlayer() {
  for (int i = aliensPerRow*alienRows-1; i>0; i--) {
    if (alienHp[i]>0 && alienPositions[i][1] > 630) gameState = 5; // When aliens get past Y = 630, you instantly lose
  }
  if (alienPositions[55][1] > 630) gameState = 5; //ufo
}


//checks if player or alien bullets go out of bounds of the screen, in which case sets the corresponding shooting boolean to false. Example: player bullet goes out of bounds --> playerBulletOnScreen = false
void checkIfBulletsOutOfBounds() {
  if (pBulletY < -20) playerBulletOnScreen = false; //player bullets

  //alien bullets
  for (int i = 0; i<alienBulletPositions.length; i++) { 
    if (alienBulletPositions[i][1] > 820 && aliensShooting[i]) {
      aliensShooting[i] = false;
    }
  }
}
