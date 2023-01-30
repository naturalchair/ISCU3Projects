/*  //<>//
 Matthew Liu
 2022-05-12
 ICS3U1
 Mr. Parchimowicz
 Assignment 5 - Physics game: Tanks
 */

PFont font = new PFont();
PImage images[]  = new PImage[6];

int gameState; //0 = title screen, 1 = menu screen, 2 = instruction screen, 3 = game screen, 4 = winner screen
int tankHps[] = new int[2];
int tankPositions[][] = new int[2][2]; //first index is tank index, 2nd index is x or y coordinate (0 = x, 1 = y)
float tankRotations[] = new float[2]; //rotation of tank for slanted terrain. (Steep terrain going up means tank should be rotated up to be parallel to ground)
PVector gravity = new PVector(0, .12);
PVector wind = new PVector();
PVector shotPosition = new PVector();
PVector shotVelocity = new PVector();
int tankAimAngles[] = new int[2]; //in degrees, right of tank = 0, top of tank = 90, bottom of tank = -90 (displayed as 270)
int tankPower[] = new int[2]; //value from 1 to 100
boolean shotFired, shotHit; //shotFired is if the player has fired their shot, shotHit is if the fired shot hit the ground
boolean tanksMoving[][] = new boolean[2][2]; //first index is which tank, second index is moving left or right (0 = left, 1 = right)
int tankSpeed, fuel, maxFuel; //fuel represents how many px the tank can move horizontally. Ex: 300 fuel means tank can move 300 px 
int turnTime, turnTimeCounter, timeRemaining; //turn time is how long each player gets to aim in ms. If a player does not shoot in time, their turn is skipped
float tankTraction = 1.2; //how steep the tank can drive (in radians)
boolean tankShotGround; //the tank shot starts at the tank nozzle, but if you aim the nozzle into the ground and shoot, this will leave a hole inside the ground.
//If this is true, it means that the tank's nozzle tip is in the terrain, so the shot will instead be set to the tank's position, so the tank just shoots itself instead of through the ground

color groundColor = color(35, 69, 113);

int settingSelected; //which setting player is changing, 0 = wind, 1 = hp, 2 = self damage, 3 = map
int hpSetting; //what hp setting is set to
int hpOptions[] = {100, 150, 200, 300, 400, 500, 600};
int windSetting; //what wind setting is set to
String windNames[] = {"No wind", "Low wind", "Medium wind", "Extreme wind"};
float windValues[] = {0, 0.01, 0.02, 0.04}; //the range of the random number for wind.
int mapSetting; //what map setting is set to
String mapNames[] = {"Flat", "Hill", "Valleys", "Mountain", "Valley"};
boolean selfDamage; //whether or not players can damage themselves
int mapStartXPositions[][] = new int[5][2]; //first index is which map, second index is x position of which tank. 0 = tank 1 x, 1 = tank 2 x.
//do not need to set y positions, since that is automatically set by adjustTank
int round; //counts up every time both tanks shoot
int tankTurn; //counts up after every turn. If this value is even, its tank 1's turn, odd is tank 2's turn

//Dead weight is a basically unmissable weapon and it will drop straight down on the enemy tank if it flys over it.
//Weapons are in order. For example, Normal shot = index 0 so its damage would be weaponDamages[0], its chance would be weaponChances[0], etc
String weapons[] = {"Normal shot", "Big shot", "Massive shot", "Sniper", "Shadow", "Nuke", "Dead weight"};
int weaponChances[] = {0, 0, 0, 0, 90, 40000, 70}; //represents how rare each weapon are to get. 1 = 0.1%. Values add to 1000 and represent ranges for a random number generated from 0-1000
//weapon chances example: {500, 300, 200} means one weapon is 0-500, another is 500-800, another is 800-1000
int weaponSelected; //which weapon selected
int weaponRadii[] = {15, 25, 35, 5, 10, 25, 15}; //Size of the shot in midair
int weaponExplosionRadii[] = {25, 35, 50, 5, 110, 200, 25}; //Size of explosion after shot hits ground (bigger means bigger hitbox)
int weaponDamages[] = {10, 25, 50, 100, 30, 100, 20};
boolean destroysTerrain[] = {true, true, true, false, false, true, true}; //whether or not each weapon will destroy the terrain
color weaponShotColours[] = {#DDDDDD, #DDDDDD, #DDDDDD, #DDDDDD, #000000, #E9FF3D, #091D8C};
color weaponExplosionColours[] = {#FFFFFF, #FFFFFF, #FFFFFF, #FFFFFF, #000000, #ACEE00, #6175DB};
int tanksHit[] = new int[2]; //which of the tanks are hit during a turn. 0 = not hit, 1 = hit
int explosionAlpha; //0 represents opaque, 255 represents transparent
//when the shot hits the ground, shows a white explosion representing the hitbox of the explosion. This is initially opaque, and slowly turns transparent
//until the explosion is gone and the next players turn starts.

int brokenTerrain[][] = new int[300][3]; //circles where shots have exploded, has x, y position and size of explosion 

void setup() {
  size(1000, 800);
  initialVariables();
}

void draw() {
  background(#000000);
  if (gameState == 0) titleScreen();
  else if (gameState == 1) settingsScreen();
  else if (gameState == 2) guideScreen();
  else if (gameState == 3) gameScreen();
  else winnerScreen();
}

void initialVariables() {
  font = createFont("Verdana", 16);
  textAlign(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
  tankSpeed = 2;
  maxFuel = 120;
  turnTime = 50000; //1000 = 1 second
  images[0] = loadImage("tankgamepicture.png");
  images[1] = loadImage("flatmap.png");
  images[2] = loadImage("hillmap.png");
  images[3] = loadImage("valleysmap.png");
  images[4] = loadImage("mountainmap.png");
  images[5] = loadImage("valleymap.png");

  //initial positions for the maps

  //mapStartXPositions[whichMap][0-1]   2nd index: 0 = tank 1 X, 1 = tank 2 X

  //map 0 (flat map)
  mapStartXPositions[0][0] = 200;
  mapStartXPositions[0][1] = 800;

  //map 1 (hill map)
  mapStartXPositions[1][0] = 125;
  mapStartXPositions[1][1] = 875;

  //map 2 (valleys map)
  mapStartXPositions[2][0] = 50;
  mapStartXPositions[2][1] = 950;

  //map 3 (mountain map)
  mapStartXPositions[3][0] = 200;
  mapStartXPositions[3][1] = 800;

  //map 4 (valley map)
  mapStartXPositions[4][0] = 100;
  mapStartXPositions[4][1] = 900;
}

//sets initial stuff when a game starts
void setVariables() {
  tankHps[0] = hpOptions[hpSetting];
  tankHps[1] = hpOptions[hpSetting];
  tankPositions[0][0] = mapStartXPositions[mapSetting][0];
  tankPositions[1][0] = mapStartXPositions[mapSetting][1];
  tankPositions[0][1] = 500;
  tankPositions[1][1] = 500;
  drawMap();
  tankAimAngles[0] = 0;
  tankAimAngles[1] = -180;
  tankPower[0] = 0;
  tankPower[1] = 0;
  tankTurn = 0;
  fuel = maxFuel;
  round = 1;
  changeWind();
  turnTimeCounter = millis();
  timeRemaining = turnTime;
  weaponSelected = pickRandomWeapon();
}

void flatMap() {
  rect(500, 650, 1000, 300);
}

void hillMap() {
  beginShape();
  vertex(0, 800);
  vertex(0, 500);
  vertex(250, 500);
  bezierVertex(400, 250, 600, 250, 750, 500);
  vertex(1000, 500);
  vertex(1000, 800);
  endShape();
}

void valleysMap() {
  beginShape();
  vertex(0, 800);
  vertex(0, 400);
  vertex(100, 400);
  bezierVertex(200, 400, 200, 550, 300, 550);
  bezierVertex(400, 550, 400, 300, 500, 300);
  bezierVertex(600, 300, 600, 550, 700, 550);
  bezierVertex(800, 550, 800, 400, 900, 400);
  vertex(1000, 400);
  vertex(1000, 800);
  endShape();
}

void mountainMap() {
  beginShape();
  vertex(0, 800);
  vertex(0, 500);
  vertex(425, 500);
  vertex(450, 150);
  vertex(575, 150);
  vertex(600, 500);
  vertex(1000, 500);
  vertex(1000, 800);
  endShape();
}

void valleyMap() {
  beginShape();
  vertex(0, 800);
  vertex(0, 400);
  bezierVertex(200, 550, 800, 550, 1000, 400);
  vertex(1000, 800);
  endShape();
}

//logic behind how destroyed terrain works is every time a tank's shot hits the terrain and explodes, the radius of the explosion and the location is 
//saved in brokenTerrain. To remove those explosions, after the map is drawn, this just draws ellipses for all of those values
void drawDestroyedTerrain() {
  fill(#031020);
  for (int i = 0; i<300; i++) {
    if (brokenTerrain[i][2] == 0) break; //if the explosion radius is 0 (which is default meaning this index has not been set yet) breaks loop
    else {
      ellipse(brokenTerrain[i][0], brokenTerrain[i][1], brokenTerrain[i][2], brokenTerrain[i][2]);
    }
  }
}

void drawMap() {
  strokeWeight(0);
  fill(groundColor);
  if (mapSetting == 0) flatMap();
  else if (mapSetting == 1) hillMap();
  else if (mapSetting == 2) valleysMap();
  else if (mapSetting == 3) mountainMap();
  else if (mapSetting == 4) valleyMap();
  drawDestroyedTerrain();
  fill(groundColor);
  rect(500, 700, 1000, 210); //indestructible terrain
}

void titleScreen() {
  fill(#FFFFFF);
  image(images[0], 500, 400, 1000, 800);
  textSize(60);
  text("Tanks", 500, 150);
  textSize(30);
  text("Press any key to go to settings", 500, 650);
}

//player chooses settings for the game (ex: tank hp, wind strength, map) before starting the game
void settingsScreen() {
  background(groundColor);
  fill(#FFFFFF);
  textSize(80);
  text("Settings", 500, 90);
  textSize(40);
  text("Wind Strength: "+windNames[windSetting], 500, 200);
  text("Tank Health: "+hpOptions[hpSetting], 500, 290);
  text("Self Damage: "+selfDamage, 500, 380);
  text("Map Selected: "+mapNames[mapSetting], 500, 470);
  image(images[mapSetting+1], 500, 650, 300, 250);
  noFill();
  strokeWeight(4);
  stroke(#FFFFFF);
  rect(500, 650, 300, 250);

  //selection arrows that are to the left and right of the setting you are choosing.
  fill(#555555);
  stroke(#FFFFFF);
  strokeWeight(3);
  //left arrow
  line(100, 200+settingSelected*90-40, 125, 200+settingSelected*90-15); 
  line(100, 200+settingSelected*90+10, 125, 200+settingSelected*90-15);

  //right arrow
  line(900, 200+settingSelected*90-40, 875, 200+settingSelected*90-15);
  line(900, 200+settingSelected*90+10, 875, 200+settingSelected*90-15);

  textSize(20);
  fill(#FFFFFF);
  text("Press 'B' to go back to title", 170, 575);
  text("Press 'H' to see guide", 170, 650);
  text("Press 'Space' to start the game", 170, 725);
  textSize(16);
  text("Arrow keys to change settings", 500, 130);
}

//gives instructions about how the game is played, what it is, controls
void guideScreen() {
  background(groundColor);
  fill(#FFFFFF);
  line(75, 350, 925, 350);
  line(75, 115, 925, 115);
  line(75, 650, 925, 650);
  textSize(60);
  text("How to play", 500, 80);
  text("Controls", 500, 325);
  textSize(20);
  text("Tanks is a 2 player game, where each player controls a tank.", 500, 160);
  text("Players take turns aiming and adjusting the strength of their cannon, before", 500, 190);
  text("shooting their shot at the enemy. There are many different weapons, given at random", 500, 220);
  text("and the goal of the game is to destroy the enemy tank! Have fun!", 500, 250);
  textSize(30);
  text("Left and right arrows to move left and right", 500, 410);
  text("Up and down arrows to adjust power", 500, 470);
  text("I and P to adjust angle", 500, 530);
  text("Spacebar to shoot", 500, 590);
  textSize(25);
  text("Press 'B' to go back to settings", 500, 725);
}

//There are a few states ingame. Either the player is still aiming (!shotFired), the player has fired, but the shot has not landed (shotFired && !shotHit) or the player has fired and the shot hit (shotHit)
void gameScreen() {
  background(#031020);
  noStroke();
  drawMap();
  gameText(); //stuff like wind strength, which round it is, turn time remaining
  updateTankPositions(); //adjusts tanks y position to be at the surface of the ground, and rotates tanks according to how steep the terrain they are on
  if (!shotFired) { //aiming phase
    if (tankHps[0] <= 0 || tankHps[1] <= 0) gameState = 4; //go to winner screen.
    //This checker is in the aim state of game screen because I don't want game to instantly cut to win screen the second the killing blow is dealt
    else {
      if (timeRemaining < 1) turnReset(); //skipturn
      else if (millis() - turnTimeCounter > 1000) {
        turnTimeCounter+=1000;
        timeRemaining-=1000;
      }
      moveTanks();
      showAim();
      drawTanks();
      bottomGui();
      displayTankHp();
    }
  } else if (shotFired && !shotHit) { //shot is midair
    shotPhysics();
    moveShot();
    shotCollisions();
    drawShot();
    drawTanks();
  } else if (shotHit) { //shot hit terrain
    drawTanks();
    shotExplosion();
    //damage number over tanks showing how much damage they took
    if (tanksHit[0] == 1) {
      displayDamageNumber(0);
    }
    if (tanksHit[1] == 1) {
      displayDamageNumber(1);
    }
  }

  if (round < (tankTurn/2+1)) {//tankTurn/2+1 is the actual round based on how many times the tanks have shot. The round increases when both tanks shoot, and the wind will get updated.
    round++;
    changeWind();
  }
}

//makes sure tank y positions are above terrain, and tanks are properly rotated.
void updateTankPositions() {
  tankPositions[0][1] += adjustTank(tankPositions[0][0], tankPositions[0][1]);
  tankPositions[1][1] += adjustTank(tankPositions[1][0], tankPositions[1][1]);
  tankRotations[0] = rotateTank(tankPositions[0][0], tankPositions[0][1]);
  tankRotations[1] = rotateTank(tankPositions[1][0], tankPositions[1][1]);
}

//Info about game like which tank is aiming, wind strength, time left to aim and round number.
void gameText() {
  fill(#FFFFFF);

  if (!shotHit && !shotFired) {
    textSize(30);
    text("Tank "+(tankTurn%2+1)+" aiming...", 500, 70);
    text(timeRemaining/1000, 500, 120);
  }
  textSize(16);
  if (wind.x != 0) {
    if (wind.x<0) text("Wind: "+round(abs(wind.x)*10000)/10.0+" left", 500, 145);
    else text("Wind: "+round(abs(wind.x)*10000)/10.0+" right", 500, 145);
  }
  text("Round: "+round, 500, 25);
}

//screen showing who won
void winnerScreen() {
  String message;
  if (tankHps[0] > 0 && tankHps[1] <= 0) message = "Tank 1 wins!";
  else if (tankHps[1] > 0 && tankHps[0] <= 0) message = "Tank 2 wins!";
  else message = "Tie!";
  textSize(80);
  fill(#33FF50);
  text(message, 500, 400);
  textSize(35);
  fill(#FFFFFF);
  text("Press M to go back to menu", 500, 700);
}

void keyPressed() {
  if (gameState == 0) { //titleScreen controls 
    gameState = 1;
  } else if (gameState == 1) { //settingsScreen controls
    if (keyCode == 72) gameState = 2; //H key, goes to guide screen
    else if (keyCode == 66) gameState = 0; //B key, goes back to title screen
    else if (keyCode == 40) { //down arrow key
      if (settingSelected < 3) settingSelected++;
      else settingSelected = 0;
    } else if (keyCode == 38) { //up arrow key
      if (settingSelected > 0) settingSelected--;
      else settingSelected = 3;
    } else if (keyCode == 37) { //left arrow key
      changeSetting(-1);
    } else if (keyCode == 39) { //right arrow key
      changeSetting(1);
    } else if (keyCode == 32) { //space, goes to game screen (starts game with settings selected)
      setVariables();
      gameState = 3;
    }
  } else if (gameState == 2) { //guideScreen controls
    if (keyCode == 66) gameState = 1; //b key, goes back to settings screen
  } else if (gameState == 3) { //gameScreen controls
    if (!shotFired) { //controls before the player shoots
      int tankShooting = tankTurn%2;
      if (keyCode == 37) tanksMoving[tankShooting][0] = true; //left arrow key
      else if (keyCode == 39) tanksMoving[tankShooting][1] = true; //right arrow key
      else if (keyCode == 38 && tankPower[tankShooting]<100) tankPower[tankShooting]++; //up arrow key
      else if (keyCode == 40 && tankPower[tankShooting]>0) tankPower[tankShooting]--; //down arrow key
      else if (keyCode == 73) tankAimAngles[tankShooting] --; //i key
      else if (keyCode == 80) tankAimAngles[tankShooting] ++; //p key
      else if (keyCode == 32) { //space
        initialShotFired();
        shotFired = true;
      }
    }
  } else if (gameState == 4) { //winScreen controls
    if (keyCode == 77) gameState = 0; //m key, goes back to title screen
  }
}

void keyReleased() {
  if (gameState == 3) {
    int tankShooting = tankTurn%2;
    if (keyCode == 37) tanksMoving[tankShooting][0] = false; //left arrow key
    else if (keyCode == 39) tanksMoving[tankShooting][1] = false; //right arrow key
  }
}

//changes the menu settings, change variable is if the index of the setting selected is increased or decreased. (Ex: hpOptions = {50, 150, 200} change of 1 would move from 50 to 150, change of -1 would move from 200 to 150)
void changeSetting(int change) {
  if (settingSelected == 0) windSetting += change;
  else if (settingSelected == 1) hpSetting += change;
  else if (settingSelected == 2) {
    if (selfDamage) selfDamage = false;
    else selfDamage = true;
  } else if (settingSelected == 3) mapSetting += change;

  //wrap around so if you increase the setting past the length of the array (amount of settings) it wraps back to index 0 and vice versa
  //checking length of array will give you the amount of indexes, but will not give you the last index (since it starts counting at 1 instead of 0) so its -1 to actually get the 'index' of the last index
  if (windSetting > windValues.length - 1) windSetting = 0;
  else if (windSetting < 0) windSetting = windValues.length - 1;
  else if (hpSetting > hpOptions.length - 1) hpSetting = 0;
  else if (hpSetting < 0) hpSetting = hpOptions.length - 1;
  else if (mapSetting > mapNames.length-1) mapSetting = 0;
  else if (mapSetting < 0) mapSetting = mapNames.length-1;
}

//displays hp of tanks ingame
void displayTankHp() {
  textSize(16);
  fill(#36D21B);
  text("HP: "+tankHps[0]+"/"+hpOptions[hpSetting], tankPositions[0][0], tankPositions[0][1]-30);
  text("HP: "+tankHps[1]+"/"+hpOptions[hpSetting], tankPositions[1][0], tankPositions[1][1]-30);
}

//Block of info at bottom of screen ingame that is displayed while tanks are aiming. Shows info like what type of weapon you have, aiming angle, and power of shot, tank fuel, etc
void bottomGui() {
  fill(#222222);
  stroke(#111111);
  strokeWeight(3);
  rect(500, 700, 800, 200); //gui box
  fill(#FFFFFF);
  textSize(20);
  text("Fuel:", 250, 640);
  textSize(30);
  text("Tank "+(tankTurn%2+1), 500, 660);
  text("Space to fire", 750, 660);
  textSize(35);
  text("Weapon: "+weapons[weaponSelected], 640, 765);
  textSize(25);
  tankAimAngles[0] = tankAimAngles[0]%360;
  tankAimAngles[1] = tankAimAngles[1]%360;
  //Right of tank = 0 degrees. 50 degrees is 50 degrees counterclockwise from right of tank, -50 degrees is 50 degrees clockwise from right of tank.

  //to convert negatives to be their positive cotrerminal angle.
  if (tankAimAngles[tankTurn%2] <= 0) text("Angle: "+-tankAimAngles[tankTurn%2]+"  Power: "+tankPower[tankTurn%2], 250, 760);
  else text("Angle: "+(360-tankAimAngles[tankTurn%2])+"  Power: "+tankPower[tankTurn%2], 250, 760);

  //fuel bar
  fill(#22FF44);
  rect(250, 660, 150*fuel/maxFuel, 20);
  line(100, 700, 900, 700);
}

//Visual of the tank's aiming angle and power
void showAim() {
  fill(#FFFFFF, 30);
  ellipse(tankPositions[tankTurn%2][0], tankPositions[tankTurn%2][1], 400, 400);
  arc(tankPositions[tankTurn%2][0], tankPositions[tankTurn%2][1], 4*tankPower[tankTurn%2], 4*tankPower[tankTurn%2], radians(tankAimAngles[tankTurn%2])-0.1, radians(tankAimAngles[tankTurn%2])+0.1);
  //aiming zone is a circle with radius 400 pixels. The aim is a little cone arc of the circle in the angle of where the tank is aiming, and the radius of
  //the arcs circle is 400/100 * power (power is a value between 1-100), so it is a percent of 100% size
}


//Handles the boolean switches for moving the tanks.
void moveTanks() {
  if (fuel>=tankSpeed) {
    int tankMoved = 2; //2 = no tank moved
    //checkSteepness being true means that the terrain where the tank is moving is not too steep (based on how high tank traction is) so the tank can move.
    if (tanksMoving[0][0] && !tanksMoving[0][1] && tankPositions[0][0] > 30 && checkSteepness(0, -tankSpeed)) { //tank 1 moving left
      tankPositions[0][0] -= tankSpeed;
      tankMoved = 0;
    } else if (!tanksMoving[0][0] && tanksMoving[0][1] && tankPositions[0][0] < 970 && checkSteepness(0, +tankSpeed)) { //tank 1 moving right
      tankPositions[0][0] += tankSpeed;
      tankMoved = 0;
    } else if (tanksMoving[1][0] && !tanksMoving[1][1] && tankPositions[1][0] > 30 && checkSteepness(1, -tankSpeed)) { //tank 2 moving left
      tankPositions[1][0] -= tankSpeed;
      tankMoved = 1;
    } else if (tanksMoving[1][1] && !tanksMoving[1][0] && tankPositions[1][0] < 970 && checkSteepness(1, +tankSpeed)) { //tank 2 moving right
      tankPositions[1][0] += tankSpeed;
      tankMoved = 1;
    }
    if (tankMoved != 2) {
      fuel-=tankSpeed;
    }
  }
}

//checks if the place the tank is moving to is too steep. Returns false if too steep, true if it is in range of tank traction. Direction is how many px tank is moving and in what direction (negative = left)
boolean checkSteepness(int tank, int direction) {
  int newTankX = tankPositions[tank][0]+direction;
  int tankY = tankPositions[tank][1];
  if (Math.abs(rotateTank(newTankX, adjustTank(newTankX, tankY))) < tankTraction) return(true); //absolute value since it doesn't matter if the angle is negative or positive, just need the magnitude
  return(false);
}

void drawShot() {
  fill(weaponShotColours[weaponSelected]);
  ellipse(shotPosition.x, shotPosition.y, weaponRadii[weaponSelected], weaponRadii[weaponSelected]);
}

void drawTanks() {
  fill(#1B60FF);
  noStroke();

  //tank1
  pushMatrix();
  translate(tankPositions[0][0], tankPositions[0][1]);
  rotate(tankRotations[0]); //this is for the tank rotating along with the terrain
  rect(0, 0, 30, 15);
  popMatrix();

  //nozzle
  pushMatrix();
  translate(tankPositions[0][0], tankPositions[0][1]);
  rotate(radians(tankAimAngles[0])); //this is for the tank nozzle rotating depending on the player's aim
  rect(15, 0, 30, 4);
  popMatrix();

  fill(#F4342E);
  //tank2
  pushMatrix();
  translate(tankPositions[1][0], tankPositions[1][1]);
  rotate(tankRotations[1]); //tank rotating w/ terrain
  rect(0, 0, 30, 15);
  popMatrix();

  //nozzle
  pushMatrix();
  translate(tankPositions[1][0], tankPositions[1][1]);
  rotate(radians(tankAimAngles[1])); //nozzle rotation w/ aim
  rect(15, 0, 30, 4);
  popMatrix();
}

//moves tanks to be at ground level if they move down a hill or valley. 
//This is here since you can only move the tanks left and right, so without adjusting the height to the surface, the tank would go through hills, and float over valleys
int adjustTank(int tankX, int tankY) {
  if (get(tankX, tankY + 7) != groundColor) {
    for (int i=0; i<800; i++) { //scans pixel by pixel down until it finds the ground
      if (get(tankX, tankY + 6 + i) == groundColor) {
        return(i);
      }
    }
  } else {
    for (int i=0; i<800; i++) { //scans pixel by pixel up until it finds the ground
      if (get(tankX, tankY + 6 - i) != groundColor) {
        return(-i);
      }
    }
  }
  return(0); //error
}

//rotates tank based on how steep the terrain its on is. Example: if its going up a steep hill, it should be rotated a bit counter clockwise to be parallel to the ground
//This is all ran directly after the tank is adjusted so it's y position adjusted properly to the height of the ground by its x position
float rotateTank(int tankX, int tankY) {
  //To find angle to rotate the tank, the "steepness" of the terrain is approximated using rise/run by finding the height of the terrain 6px to the left and right of the tank and comparing.

  //left and right ground level is the difference from ground level and the tank y position
  int leftGroundLevel = 0; //ground level 6px left of tank 
  int rightGroundLevel = 0; //ground level 6px right of tank
  tankY += 7; //7 added since the tankY is actually the middle of the tank height and not the bottom of the tank

  //leftGroundLevel
  if (get(tankX-6, tankY) == groundColor) { //if 6px left of the tank is ground, ground level must be higher so it checks pixel by pixel up until it finds non ground
    for (int i = 1; i<800; i++) {
      if (get(tankX-6, tankY - i) != groundColor) {
        leftGroundLevel = - i;
        break;
      }
    }
  } else for (int i = 1; i<800; i++) { //otherwise if 6px left is not ground, it means ground is lower so it checks pixel by pixel down until it finds ground
    if (get(tankX-6, tankY + i) == groundColor) {
      leftGroundLevel = i;
      break;
    }
  }

  //rightGroundLevel, same logic as above except checking 6px right of tank instead
  if (get(tankX+6, tankY) == groundColor) {
    for (int i = 1; i<800; i++) {
      if (get(tankX+6, tankY - i) != groundColor) {
        rightGroundLevel = - i;
        break;
      }
    }
  } else for (int i = 1; i<800; i++) {
    if (get(tankX+6, tankY + i) == groundColor) {
      rightGroundLevel = i;
      break;
    }
  }
  float diffHeight = rightGroundLevel-leftGroundLevel; //difference in height of ground between 6px left of tank and 6px right of tank
  float tankAngle = atan(diffHeight/12); //tan = opposite / adjacent which is diffHeight and 12 (12 from 6px * 2) in this case. Arctan of this will give the angle the tank should be rotated.
  return(tankAngle);
}


//changes velocity of the shot tanks shoot while airborne
void shotPhysics() {
  shotVelocity.add(gravity);
  shotVelocity.add(wind);
}


void moveShot() {
  shotPosition.add(shotVelocity);
  if (weaponSelected == 6) { //Dead weight is a weapon that falls straight down if it is right above the enemy
    int enemyTank = (tankTurn+1)%2; //only will lock onto the enemy
    if (Math.abs(shotPosition.x - tankPositions[enemyTank][0]) < 15) {
      shotVelocity.x = 0;
    }
  }
}


void shotCollisions() {
  if (shotPosition.x > 1050 || shotPosition.x < -50 || shotPosition.y > 1000) { //shot X position is out of bounds and will move on to the next turn.
    turnReset();
  }
  int shotRadius = weaponRadii[weaponSelected]; 
  int leftOfShot = int(shotPosition.x - shotRadius/2);
  int topOfShot = int(shotPosition.y - shotRadius/2);
  if (tankShotGround) { //if the player just shot straight into the terrain
    shotHit = true;
    destroyTerrain();
  } else {
    //loop to approximate collision of the ball (circle) by checking 4 "corners" of the circle (if you think of the ball as a square).
    for (int i = 0; i<4; i++) { 
      //shotRadius*(i%2) will be 0, 1, 0, 1 meaning left, right, left, right and shotRadius*(i/2) is 0, 0, 1, 1 meaning up, up, down, down, which will get all 4 corners of square
      if (get(leftOfShot + shotRadius*(i%2), topOfShot + shotRadius*(i/2)) == groundColor) {
        shotHit = true;
        if (destroysTerrain[weaponSelected]) { //only runs code of destroying terrain if the selected weapon can destroy terrain
          destroyTerrain();
        }
        int tankShooting = tankTurn%2; //which tank's turn it is
        int otherTank = 1 - tankShooting; //enemy tnak

        //If difference in position between the center of explosion and enemy tank is less than radius of explosion + 15 (to approximately account for size of tanks themselves) the tank got hit by the explosion
        if (mag(tankPositions[otherTank][0] - shotPosition.x, tankPositions[otherTank][1]-shotPosition.y) < weaponExplosionRadii[weaponSelected]/2 + 15) {
          tankHps[otherTank] -= weaponDamages[weaponSelected];
          tanksHit[otherTank] = 1;
        }

        //Same thing as above except also checks if the tank shooting gets hit (if self damage is enabled)
        if (selfDamage) {
          if (mag(tankPositions[tankShooting][0] - shotPosition.x, tankPositions[tankShooting][1]-shotPosition.y) < weaponExplosionRadii[weaponSelected]/2 + 15) {
            tankHps[tankShooting] -= weaponDamages[weaponSelected];
            tanksHit[tankShooting] = 1;
          }
        }
        break;
      }
    }
  }
}

//stores a value in the first open spot of
void destroyTerrain() {
  for (int i = 0; i<300; i++) {
    if (brokenTerrain[i][2] == 0) {
      brokenTerrain[i][0] = int(shotPosition.x);
      brokenTerrain[i][1] = int(shotPosition.y);
      brokenTerrain[i][2] = weaponExplosionRadii[weaponSelected];
      break;
    }
  }
}

//Draws the fading explosion after a shot hits terrain.
void shotExplosion() {
  fill(weaponExplosionColours[weaponSelected], 255-explosionAlpha); //255 = opaque, 0 = transparent. This gradually gets more transparent as explosionAlpha gets bigger
  ellipse(shotPosition.x, shotPosition.y, weaponExplosionRadii[weaponSelected], weaponExplosionRadii[weaponSelected]);
  explosionAlpha += 8;
  if (explosionAlpha >= 500) { //This is checking greater than 500 instead of 255 to act like a timer, so there is a little pause before the next turn starts
    turnReset();
    explosionAlpha = 0; //reset value back to 0 for next explosion
  }
}

//tank is which tank it is displaying the damage number for (which tank is hit)
void displayDamageNumber(int tank) {
  if (tank == tankTurn%2) fill(#F53533); //when a tank self damages, the number is red instead of white
  else fill(#FFFFFF);
  textSize(23); 
  text(weaponDamages[weaponSelected], tankPositions[tank][0], tankPositions[tank][1]-70);
}

//Sets initial position and velocity the moment the tank fires the shot. (Initially at tank nozzle and velocity is determined by tank aiming angle and power
void initialShotFired() { //sets initial values when a tank shoots like position and velocity
  //the player's shot power effectively draws a circle of some radius around the player to represent the shot velocity, and the angle just specifies a point on that circle.
  //so the x and y parts of the "total velocity" are given by taking sin and cos of the angle. (These are just ratios of x and y velocity based on angle, need to scale this up by the power) 
  shotVelocity.x = cos(radians(tankAimAngles[tankTurn%2]));
  shotVelocity.y = sin(radians(tankAimAngles[tankTurn%2])); 

  //sets the shot to initially be approximately where the end of the nozzle is
  shotPosition.x = tankPositions[tankTurn%2][0] + shotVelocity.x*30;
  shotPosition.y = tankPositions[tankTurn%2][1] + shotVelocity.y*28;
  shotVelocity.mult(tankPower[tankTurn%2]/9);

  drawMap(); //map is drawn here so it can test if the nozzle is in the ground, otherwise the nozzle itself is in the way, so it can't check
  if (get(int(shotPosition.x), int(shotPosition.y)) == groundColor) { //if the tank shoots straight into terrain, it should explode on itself instead of exploding at the nozzle (since the nozzle is in the ground) so this sets the position to itself
    tankShotGround = true;
    shotPosition.x = tankPositions[tankTurn%2][0];
    shotPosition.y = tankPositions[tankTurn%2][1];
  }
}

//Resets values for the next tank's turn. 
void turnReset() {
  shotHit = false;
  shotFired = false;
  tankTurn++;
  fuel = maxFuel;
  timeRemaining = turnTime;
  turnTimeCounter = millis();
  weaponSelected = pickRandomWeapon();
  tanksMoving[0][0] = false;
  tanksMoving[0][1] = false;
  tanksMoving[1][0] = false;
  tanksMoving[1][1] = false;
  tanksHit[0] = 0;
  tanksHit[1] = 0;
  tankShotGround = false;
}

//returns an index representing a weapon for a player
int pickRandomWeapon() {
  int randomNumber = int(random(0, 1000));
  int sum = 0;

  //weaponChances has an integer value for each different type of weapon that represent a chance out of 1000.
  //Example: weaponChances = {100, 400, 500} means weapon 0 is numbers 0-100, weapon 1 is numbers 100-500, weapon 2 is numbers 500-1000 or effectively a 10%, 40%, 50% chance respectively.
  //This picks a weapon by these chances by checking if a random number 1-1000 is in these ranges of numbers.
  for (int i = 0; i<weapons.length; i++) {
    sum += weaponChances[i];
    if (randomNumber < sum) {
      return(i); //returns index of weapon
    }
  }
  return(0); //some error happened in choosing weapons
}

//generates random wind based on the wind setting (setting chances how much wind can vary)
void changeWind() {
  wind.x = random(-windValues[windSetting], windValues[windSetting]);
}
