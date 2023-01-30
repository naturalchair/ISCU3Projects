/*
Matthew Liu
 Due date
 ICS3U1
 Mr. Parchimowicz
 Assignment 6 - Cookie Clicker
 */

//This game takes a while to "finish" (get mostly everything) so to test it quickly, you can start with a bunch of cookies by setting a value to cookies.
//The roulette part of the game comes with golden cookies that spawn randomly (Approx every 111 seconds on avg)
float cookies;
float cps; //cookies per second

int gameState; // 0 = title screen, 1 = instruction screen, 2 = actual game
boolean rouletteOnScreen;
int rouletteState; //0 = not spun, 1 = spinning, 2 = done spinning, 3 = roulette info
float rotation; //angle in radians the roulette is rotated
float rotateSpeed; //angle in radians the roulette rotates per frame
float rotateSpeedDecay = 0.99; //ratio multiplied to rotate speed every frame (less than 1)
int sectionLanded; //what section the roulette lands on, 0 = red, 1 = blue, 2 = green, 3 = gold
color rouletteSectionColors[] = {#FF5454, #5DC4F7, #FF5454, #FFD640, #FF5454, #5DC4F7, #FF5454, #84FA4C, #FF5454, #5DC4F7};
//#FF7557 = red, #5DC4F7 = blue,  #FFD640 = gold, #84FA4C = green

float goldenCookieBoostAmount = 33; //multiplied to your cookies per second
boolean goldenCookieBoost; //is the boost active
int goldenCookieTimer; //is set to millis + boost length, and will turn off boost when millis is greater than this
int goldenCookieBoostLength = 60000; //how long golden cookie boost last in ms
boolean goldenCookie; //whether or not golden cookie is on screen
PVector goldenCookiePosition = new PVector();
float goldenCookieChance = 0.00015; //percent chance every frame for golden cookie to appear
int goldenCookieRadius = 50; //how big is the cookie

float cursorRotation; //rotation value for cursors shown spinning around the cookie.

PFont font = new PFont();
PImage[] images = new PImage[3];
int[][] buttonPositions = new int[13][2]; //first index is which button, second index is x or y position (using center mode)
int[][] buttonSizes = new int[13][2]; //same as above but for size of buttons

/* button indexes: 
 0 = cursor buy
 1 = grandma buy
 2 = farm buy
 3 = factory buy
 4 = alchemist  buy
 5 = time machine buy
 6 = mint cookies upgrade buy
 7 = vanilla cookies upgrade buy
 8 = electric cookies upgrade buy
 9 = spin button for roulette
 10 = info button for roulette
 11 = close button for roulette info
 12 = close button for roulette
 */
float[] shopPrices = {10, 2000, 100000, 10000000, 1000000000L, 1000000000000000L, 10000000, 1000000000000L, 1000000000000000000L}; 
//order: Cursor, Grandma, Farm, Factory, Alchemist, Time Machine, Mint cookies upgrade, Vanilla cookies upgrade, Electric cookies upgrade
float[] cpsIncreases = {2.5, 20, 400, 30000, 123450, 727000000L}; //how much each shop item increases cps (for upgrades);
float[] upgradeMultipliers = {7.28, 133.5, 12345.67}; //how much of a cps multiplier the upgrades give
String[] itemNames = {"Cursor", "Grandma", "Farm", "Factory", "Alchemist", "Time Machine", "Mint Cookies", "Vanilla Cookies", "Electric Cookies"};
String[] suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "De", "UD", "DD", "TrD", "QtD", "QnD"}; //converts big numbers to smaller with suffix (5 230 213 -> 5.23M)

int[] amountPurchased = new int[6]; //how many of each structures purchased
int[] upgradesPurchased = new int[3];
float priceIncreaseRatio = 1.2; //actual shop price = initial shop price * ratio ^ amount bought

PVector cookiePosition = new PVector(250, 400);
int cookieRadius = 130;

//same order as buttons
void setup() {
  size(800, 800);
  rectMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER);
  font = createFont("Verdana", 16);
  initialVariables();
}

void draw() {
  if (gameState == 0) titleScreen();
  else if (gameState == 1) instructionScreen();
  else if (gameState == 2) gameScreen();
}

void keyPressed() {
  print(keyCode);
  if (gameState == 0) { //Menu screen controls
    if (keyCode == 72) gameState = 1; //h key
    else if (keyCode == 32) { //space bar
      gameState = 2; //starts the game
    }
  } else if (gameState == 1) { //Instruction screen controls
    if (keyCode == 66) gameState = 0; //b key
  } else if (gameState == 2) { //Game screen controls
  }
}

void keyReleased() {
}

void mousePressed() {
  if (gameState == 2) { //gameScreen
    if (!rouletteOnScreen) { //roulette isnt on screen
      if (mag(cookiePosition.x-mouseX, cookiePosition.y-mouseY) < cookieRadius) cookies+=cps/2 + 1; //clicking main cookie
      //Clicking main cookie gives you 1/4 of your cps cookies (+1 to be able to start the game) multiplied by 1+0.01*total buildings bought
      //Ex: 200 total buildings bought means clicking gives (1/4 * 3) * cps cookies
      if (mag(goldenCookiePosition.x-mouseX, goldenCookiePosition.y-mouseY) < goldenCookieRadius) gotGoldCookie(); //clicking gold cookie
      else {
        for (int i = 0; i<amountPurchased.length + upgradesPurchased.length; i++) { //sees if player clicked on any of the buy buttons for buildings
          if (inRangeOfButton(i)) buyShopItem(i);
        }
      }
    } else { //roulette is on screen.     Roulette states: 0 = not spun, 1 = spinning, 2 = finished spinning, 3 = info about roulette rewards
      if (rouletteState == 0) {//not spun roulette
        if (inRangeOfButton(9)) rouletteState = 1; //spin the roulette
        else if (inRangeOfButton(10)) rouletteState = 3; //go to info screen
      } else if (rouletteState == 3) { //roulette info
        if (inRangeOfButton(11)) rouletteState = 0; //go back to not spinning
      } else if (rouletteState == 2) { //roulette finished spinning
        if (inRangeOfButton(12)) { //if person clicked the close button
          rouletteOnScreen = false;
          rouletteState = 0;
        }
      }
    }
  }
}

void titleScreen() { 
  background(#29AEE7);
  textSize(90);
  text("Cookie Clicker", 400, 200);
  textSize(40);
  text("Press H for instructions", 400, 400);
  text("Press space to start game", 400, 500);
}

void instructionScreen() {
  background(#29AEE7);
  textSize(50);
  text("Cookie Clicker", 400, 100);
  stroke(#FFFFFF);
  strokeWeight(3);
  line(50, 120, 750, 120);
  textSize(24);
  text("The goal of the game is to get lots of cookies!", 400, 170);
  text("Use cookies to buy buildings which will generate you cookies.", 400, 210);
  text("Clicking on the big coookie will you cookies based on your", 400, 250);
  text("cps (cookies per second, generated from buildings)", 400, 290);
  text("Every 20 of a type of building you buy, its cookie generation", 400, 340);
  text("is increased by 5x.", 400, 380);
  text("Occasionally, a golden cookie will appear on the screen.", 400, 450);
  text("Clicking the golden cookie will open a roulette screen where you", 400, 490);
  text("can spin a roulette, to get a random reward! (more cookies)", 400, 530);
  text("Warning: Does not save data", 400, 600);
  text("Press 'B' to go back", 400, 730);
}

void gameScreen() {
  background(#1E86F3);
  updateCps();
  updateCookies();
  drawCursors();
  displayCookies();
  drawButtons();
  if (!goldenCookie) goldenCookieSpawn();
  else displayGoldenCookie();
  if (rouletteOnScreen) displayRoulette();
}

void initialVariables() {
  images[0] = loadImage("cookie.png");
  images[1] = loadImage("goldenCookie.png");
  images[2] = loadImage("cursor.png");

  for (int i = 0; i<(amountPurchased.length+upgradesPurchased.length); i++) { //set shop button positions
    buttonPositions[i][0] = 700;
    buttonPositions[i][1] = 60 + 85*i + 20*(i/amountPurchased.length);
    buttonSizes[i][0] = 180;
    buttonSizes[i][1] = 60;
  }
  //spin roulette button
  buttonPositions[9][0] = 400;
  buttonPositions[9][1] = 690;
  buttonSizes[9][0] = 200;
  buttonSizes[9][1] = 60;

  //roulette info button
  buttonPositions[10][0] = 630;
  buttonPositions[10][1] = 690;
  buttonSizes[10][0] = 120;
  buttonSizes[10][1] = 40;

  //go back button for info page
  buttonPositions[11][0] = 400;
  buttonPositions[11][1] = 700;
  buttonSizes[11][0] = 150;
  buttonSizes[11][1] = 50;

  //close button for roulette
  buttonPositions[12][0] = 400;
  buttonPositions[12][1] = 690;
  buttonSizes[12][0] = 200;
  buttonSizes[12][1] = 60;

  for (int i = 0; i<shopPrices.length; i++) {
    shopPrices[i] = shopPrices[i];
  }
}


void drawButtons() {
  fill(#0B437D);
  stroke(#000000);
  strokeWeight(3);
  rect(650, 400, 300, 900);
  //buy building buttons
  for (int i = 0; i<amountPurchased.length; i++) { 
    fill(#FFFFFF);
    rect(buttonPositions[i][0], buttonPositions[i][1], buttonSizes[i][0], buttonSizes[i][1]);
    textSize(14);
    fill(#000000);
    text(itemNames[i]+" $"+displayWithSuffix(shopPrices[i]), buttonPositions[i][0], buttonPositions[i][1]-5); //show building name and price
    text("+ "+displayWithSuffix(cpsIncreases[i])+" cps", buttonPositions[i][0], buttonPositions[i][1]+20); //show how much cps it gives
    textSize(40);
    fill(#FFFFFF);
    text(amountPurchased[i], buttonPositions[i][0]-140, buttonPositions[i][1]+10); //display how many of the building you own
  }

  //buy upgrade buttons
  for (int i = amountPurchased.length; i<amountPurchased.length+upgradesPurchased.length; i++) {
    fill(#FFFFFF);
    rect(buttonPositions[i][0], buttonPositions[i][1], buttonSizes[i][0], buttonSizes[i][1]);
    textSize(13);
    fill(#000000);
    if (upgradesPurchased[i-amountPurchased.length] != 1) { //if the upgrade is not bought yet, show the button as normal
      text(itemNames[i]+" $"+displayWithSuffix(shopPrices[i]), buttonPositions[i][0], buttonPositions[i][1]-5);
      text(upgradeMultipliers[i-amountPurchased.length]+"x to cps", buttonPositions[i][0], buttonPositions[i][1]+20);
    } else text("Sold Out", buttonPositions[i][0], buttonPositions[i][1]-5); //if its bought, just show sold out
    text(upgradeMultipliers[i-amountPurchased.length]+"x to cps", buttonPositions[i][0], buttonPositions[i][1]+20); //display how much it boosts cps
    textSize(40);
    fill(#FFFFFF);
    text(upgradesPurchased[i-amountPurchased.length], buttonPositions[i][0]-140, buttonPositions[i][1]+10); //display if you have bought it or not
  }
  line(500, 550, 800, 550);
}

void displayCookies() { //shows cookies, cps and draws the big cookie you click on
  image(images[0], cookiePosition.x, cookiePosition.y, cookieRadius*2, cookieRadius*2);
  fill(#111111, 200);
  noStroke();
  rect(400, cookiePosition.y-240, 1000, 110); //dark background behind cookies numbers so they are easier to see
  fill(#FFFFFF);
  textSize(40);
  if (cookies>1000) text("Cookies: "+displayWithSuffix(cookies), cookiePosition.x, cookiePosition.y - 250);
  else text("Cookies: "+int(cookies), cookiePosition.x, cookiePosition.y - 250);
  textSize(25);
  if (goldenCookieBoost) { //cps displayed in gold color if boost is active and screen gets a yellow glow
    fill(#FFCD18, 100);
    rect(400, 400, 900, 900);
    fill(#FFCD18);
  }
  text("cps: "+displayWithSuffix(cps), cookiePosition.x, cookiePosition.y - 200);
}

//handles purchasing shop items
void buyShopItem(int item) {
  if (cookies >= shopPrices[item]) { //can afford
    if (item < amountPurchased.length) { //buildings
      amountPurchased[item]++;
      if (amountPurchased[item]%20 == 0) cpsIncreases[item]*=5; //every 20 of a structure bought increases that structures cps generation by 5x
      cookies -= shopPrices[item]; 
      shopPrices[item]*=priceIncreaseRatio;
    } else { //upgrades
      //the upgradesPurchased array includes all the buildlings, then all the upgraders, while the amountPurchased array is just for upgrades,
      //and the item variable represents the index in the upgradesPurchased array, so the index for upgrades would be the item value - amount of buildings
      if (upgradesPurchased[item-amountPurchased.length] == 0) {
        upgradesPurchased[item-amountPurchased.length] = 1;
        cookies -= shopPrices[item];
      }
    }
  }
}

void updateCps() { //updates cps to the value it should be
  cps = 0;
  //give all the building cps
  for (int i = 0; i<amountPurchased.length; i++) {
    cps+=(cpsIncreases[i]*amountPurchased[i]);
  }

  //give golden cookie cps boost if active
  if (goldenCookieBoost) { 
    cps*=goldenCookieBoostAmount;
    goldCookieTimer();
  }

  //give upgrade cps boosts if bought
  for (int i = 0; i<upgradesPurchased.length; i++) {
    if (upgradesPurchased[i] != 0) cps*=upgradeMultipliers[i];
  }
}

void updateCookies() { //adds cps to cookies. Divided by 60 since this happens 60 times a second
  cookies+=cps/60.0;
}

float roundValue(float value, int decimals) {
  return(int(value*pow(10, decimals))*1.0/pow(10, decimals));
}

//takes in a value and returns a string representing that value with a suffix (ex: 52 354 756 returns "52.35 B")
String displayWithSuffix(float value) {
  if (value > 1000) {
    int digits = int(log(value)/log(10));
    int oOM = digits/3;

    return(nf(roundValue(value/pow(10, oOM*3), 2), 0, 2)+" "+suffixes[oOM]);
  }
  return(nf(roundValue(value, 2), 0, 2));
}

void displayGoldenCookie() {
  image(images[1], goldenCookiePosition.x, goldenCookiePosition.y, goldenCookieRadius*2, goldenCookieRadius*2);
}

void goldenCookieSpawn() {
  if (random(1) <= goldenCookieChance) {
    goldenCookiePosition.x = int(random(width));
    goldenCookiePosition.y = int(random(height));
    goldenCookie = true;
  }
}

//makes the roulette on screen. This is also where the roulette rotation speed and initial rotation are randomized since I didn't think another method was necesarry for just that
void gotGoldCookie() {
  goldenCookie = false;
  rouletteOnScreen = true;
  rotateSpeed = random(0.4, 1);
  rotation = random(0, 3);
}

//adds the rotation speed to the rotation angle, and also slows down the speed a bit so the wheel gradually slows to a stop
void updateRotation() {
  rotation += rotateSpeed;
  rotateSpeed *= rotateSpeedDecay;

  if (rotateSpeed < 0.001) { //roulette stopped (done spinning and finding which part it landed on)
    rouletteState = 2;
    drawRoulette();

    //I used color collisions instead of angles to find which section the player lands on since
    //a lot of the sections are the same colour (and give the same reward), although I could have used angles.
    //One tiny bug (now a feature) is that if the player gets very lucky and the roulette lands exactly inbetween two colours,
    //It will give the golden cookie boost, since none of the colors will match
    color colorLanded = get(530, 320);
    if (colorLanded == rouletteSectionColors[0]) sectionLanded = 0;
    else if (colorLanded == rouletteSectionColors[1]) sectionLanded = 1; //blue
    else if (colorLanded == rouletteSectionColors[7]) sectionLanded = 2; //green
    else sectionLanded = 3; //gold
    giveReward(sectionLanded);
  }
}

//for landed: 0 = red, 1 = blue, 2 = green, 3 = gold
void giveReward(int landed) {
  if (landed == 0) cookies+=(cps*180);
  else if (landed == 1) cookies+=(cps*900);
  else if (landed == 2) cookies+=(cps*3000);
  else if (landed == 3) {
    goldenCookieTimer = millis() + goldenCookieBoostLength;
    goldenCookieBoost = true;
  }
}

void drawRoulette() {
  pushMatrix();
  translate(400, 320);

  rotate(rotation);
  for (int i = 0; i<10; i++) {
    fill(rouletteSectionColors[i]);
    arc(0, 0, 400, 400, radians(36*i), radians(36*(i+1)));
  }
  popMatrix();
  fill(#FFFFFF);
  triangle(600, 300, 600, 340, 540, 320);
}

void displayRoulette() {
  fill(#000000, 140);
  rect(400, 400, 900, 900);
  if (rouletteState != 3) { //if not info screen
    fill(#99e6ff);
    rect(400, 400, 700, 700);
    fill(#FFFFFF);
    strokeWeight(3);
    line(50, 620, 750, 620);
    if (rouletteState == 0) { //if the wheel isnt spun
      rect(buttonPositions[9][0], buttonPositions[9][1], buttonSizes[9][0], buttonSizes[9][1]); //spin wheel button
      rect(buttonPositions[10][0], buttonPositions[10][1], buttonSizes[10][0], buttonSizes[10][1]); //info button
      textSize(30);
      fill(#000000);
      text("Spin!", buttonPositions[9][0], buttonPositions[9][1] + 10);
      textSize(20);
      text("Info", buttonPositions[10][0], buttonPositions[10][1] + 10);
      drawRoulette();
    } else if (rouletteState == 1) { //roulette spinning
      updateRotation();
      drawRoulette();
    } else if (rouletteState == 2) { //roulette done spinning, showing reward
      drawRoulette();
      rect(buttonPositions[12][0], buttonPositions[12][1], buttonSizes[12][0], buttonSizes[12][1]);
      fill(#000000);
      textSize(30);
      if (sectionLanded == 0) text("You got "+displayWithSuffix(cps*150)+" cookies!", 400, 600); //red 
      else if (sectionLanded == 1) text("You got "+displayWithSuffix(cps*400)+" cookies!", 400, 600); //blue
      else if (sectionLanded == 2) text("You got "+displayWithSuffix(cps*1500)+" cookies!", 400, 600); //green
      else text("Cps increased by "+goldenCookieBoostAmount+"x for "+goldenCookieBoostLength/1000+" seconds", 400, 600); //gold
      text("Close", buttonPositions[12][0], buttonPositions[12][1]+10);
    }

    fill(#000000);
    ellipse(400, 320, 50, 50);
  } else if (rouletteState == 3) { //info screen
    noStroke();
    fill(rouletteSectionColors[0]); //red
    rect(400, 125, 700, 150);
    fill(rouletteSectionColors[1]); //blue
    rect(400, 275, 700, 150);
    fill(rouletteSectionColors[7]); //green
    rect(400, 425, 700, 150);
    fill(rouletteSectionColors[3]); //gold
    rect(400, 575, 700, 150);
    fill(#FFFFFF);
    rect(400, 700, 700, 100);
    noFill();
    strokeWeight(4);
    stroke(#000000);
    rect(400, 400, 700, 700);
    fill(#000000);
    textSize(34);
    text("Red: Gain some cookies", 400, 130);
    text("Blue: Gain a lot of cookies", 400, 280);
    text("Green: Gain a huge amount of cookies", 400, 430);
    text("Gold: Cps increase for 1 minute", 400, 580);
    fill(#FFFFFF);
    rect(buttonPositions[11][0], buttonPositions[11][1], buttonSizes[11][0], buttonSizes[11][1]); //go back button (goes from info back to roulette)
    fill(#000000);
    textSize(25);
    text("Go back", 400, 710);
  }
}

//checks to see if the mouse x and y positions are on the button given
boolean inRangeOfButton(int buttonIndex) {
  if (Math.abs(mouseX - buttonPositions[buttonIndex][0]) < buttonSizes[buttonIndex][0]/2) {
    if (Math.abs(mouseY - buttonPositions[buttonIndex][1]) < buttonSizes[buttonIndex][1]/2) {
      return(true);
    }
  }
  return(false);
}

//checks to see if the golden cookie timer has run out and if it has it disables the boost
void goldCookieTimer() {
  if (millis() > goldenCookieTimer) goldenCookieBoost = false;
}

//draws the rotating cursors around the big cookie
void drawCursors() {
  cursorRotation+=0.05;
  for (int i = 0; i<amountPurchased[0]; i++) {
    pushMatrix();
    translate(cookiePosition.x, cookiePosition.y);
    rotate(radians(9*i) + radians((i/40)*4) + radians(cursorRotation));
    image(images[2], 0, cookieRadius+15 + (i/40)*25);
    popMatrix();
  }
}
