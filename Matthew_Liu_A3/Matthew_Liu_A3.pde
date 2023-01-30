/*
 Matthew Liu
 ICS3U1
 Assigment 3 - Pong: Classic game of pong for 2 players or 1 player vs bot
 March 24, 2021
*/

boolean lPaddleUp, rPaddleUp, lPaddleDown, rPaddleDown, gameStarted, gameEnded, wb2, botMode, instructionScreen; //wb2 is win by two
int lPaddleY, rPaddleY, paddleSpeed, paddleLength, minPaddleLength, paddleStartLength;
int ballX, ballY, maxBallSpeed, ballStartSpeed, botSpeed;
float ballXSpeed, ballYSpeed, ballSpeed; /*ballXSpeed and ballYSpeed are sort of "multipliers" for the X and Y speed of the ball to create a bit of
 randomness with the ball movement and angles. It is set to a random value when the ball hits a paddle    Example: ballXSpeed = random(0.7, 1.3)
 */
int gameTimer; //game timer just increases every draw loop. The paddles get shorter and ball gets faster every 150 frames
int leftWins, rightWins, playTo;
PFont font;

//Dummy variables
int leftPaddleFace = 1280/20 + 1280/50;
int rightPaddleFace = 1280/20*19 - 1280/50;


void setup() {
  //Code made for 1024 x 1280
  size(800, 800);
  surface.setResizable(true);
  rectMode(CENTER);
  fill(#FFFFFF);
  stroke(#FFFFFF);
  font = createFont("Yu Gothic Medium", 16, true);
  textFont(font, width/15);
  textAlign(CENTER);
  setVariables();
}

void setVariables() {
  leftWins = 0;
  rightWins = 0;
  lPaddleY = 512;
  rPaddleY = 512;
  ballX = 640;
  ballY = 512;
  ballStartSpeed = 6;
  botSpeed = 18; // the bot's maximum paddle movement speed, sort of the "difficulty" of the bot
  ballSpeed = ballStartSpeed;
  ballXSpeed = 1;
  ballYSpeed = 1;
  maxBallSpeed = 25;
  gameTimer = 0;
  paddleSpeed = 25;
  gameEnded = false;
  instructionScreen = false;
  wb2 = false;
  botMode = false;
  paddleStartLength = 256;
  paddleLength = paddleStartLength;
  minPaddleLength = 100;
  playTo = 3; //amount of wins before winning the game
  gameStarted = false;
}

//true = ratio for height, false = for width    This is the thing that just scales things to how big the window is compared to the 1024*1280 that I made the things for
int ratio(int input, boolean h) {
  if (h==false) return(int(input*(width/1280.0)));
  else return(int(input*(height/1024.0)));
}

//0 = Left win, else = right win
void resetGame(int win) {
  ballX = 640;
  ballY = 512;
  ballSpeed = ballStartSpeed;
  paddleLength = paddleStartLength;
  if (int(random(0, 2)) == 0) ballXSpeed = 1;
  else ballXSpeed = -1;
  if (int(random(0, 2)) == 0) ballYSpeed = 1;
  else ballYSpeed = -1;
  if (win==0) leftWins++;
  else rightWins++;
}

//0 = Left win, else = right win
void endGame(int win) {
  //this code is ran when a player gets more or as many points as the game is playing to.
  //the game is only ended when either wb2 is off or the difference in points is atleast 2
  if (Math.abs(leftWins-rightWins) > 1 || wb2==false) {
    if (win==0) text("Left Wins  |  Enter to reset", width/2, height/2);
    else text("Right Wins  |  Enter to reset", width/2, height/2);
    gameEnded = true;
    ballXSpeed = 0;
    ballYSpeed = 0;
    ballX = -width/8;
    ballY = -height/8;
  }
}

//this is for the menu screen where you can change stuff like wb2 and how much score is needed to win
void menuText() {
  if (instructionScreen == false) {
    //this is the main menu
    textFont(font, width/10);
    text("Pong", width/2, height/2);
    textFont(font, width/15);
    text("Press spacebar to start game", width/2, height/8*5);
    textFont(font, width/30);
    text("Press H to open instructions", width/2, height/4*3);
    text("Win by 2: "+wb2+"      Play to: "+playTo+"      Play vs Bot: "+botMode, width/2, height/4);
    textFont(font, width/15);
  } else {
    //this is the instructions screen
    textFont(font, width/30);
    text("Use your paddle to bounce the ball away from your", width/2, height/16*2);
    text("side, and score goals by hitting the ball past", width/2, height/16*3);
    text("the opponent's paddle.", width/2, height/16*4);
    text("W and S keys to move the left paddle up and down", width/2, height/16*8);
    text("Up and down arrows to move the right paddle up and down", width/2, height/16*9);
    text("G key to turn win by 2 on and off", width/2, height/16*10);
    text("Number keys 1 to 9 to change score to play to", width/2, height/16*11);
    text("B key to play vs a bot", width/2, height/16*12);
    text("H key to go back to main menu", width/2, height/16*14);
    textFont(font, width/15);
    text("---   Controls   ---", width/2, height/16*6);
  }
}

void movePaddles() {
  if (lPaddleUp && lPaddleY > 1024/50 + paddleLength/2) lPaddleY = lPaddleY-paddleSpeed;
  if (lPaddleDown && lPaddleY < 1024/50*49 - paddleLength/2) lPaddleY = lPaddleY+paddleSpeed;
  if (rPaddleUp && rPaddleY > 1024/50 + paddleLength/2) rPaddleY = rPaddleY-paddleSpeed;
  if (rPaddleDown && rPaddleY < 1024/50*49 - paddleLength/2) rPaddleY = rPaddleY+paddleSpeed;
}

void botMove() {
  if (ballXSpeed > 0 && ballX > width/3 && ballX <= 1280) {
    if (Math.abs(rPaddleY - ballY) >= 10) {
      if (rPaddleY < ballY && rPaddleY < 1024/50*49 - paddleLength/2) rPaddleY = rPaddleY + ratio(botSpeed, true);
      else if (rPaddleY > ballY && rPaddleY > 1024/50 + paddleLength/2) rPaddleY = rPaddleY - ratio(botSpeed, true);
    }
  }
}

void ballCollision() {
  if (ballX<1280*-0.4) resetGame(1);
  else if (ballX>1280*1.4) resetGame(0);

  /*ballX+ballSpeed*ballXSpeed >= width/20*19 just checks if the ball will pass the paddle next "frame" I did this since with the speed
   increasing the ball could skip past the "collision area" which is just the very front side of the paddle.  Math.abs thing basically if the 
   between ball and paddle Y position (paddleYPos is the middle of the rectangle) is bigger than half the paddle length
   */
  if (ballX+ballSpeed*ballXSpeed>=rightPaddleFace && Math.abs(ballY-rPaddleY) <= 1024/40 + paddleLength/2 && ballX<=1280/20*19 || ballX+ballXSpeed*ballSpeed<=leftPaddleFace && Math.abs(ballY-lPaddleY) <= 1024/50 + 1024/8 && ballX >= 1280/20) {
    if (ballXSpeed < 0) ballXSpeed = random(0.7, 1.3);
    else ballXSpeed = -random(0.7, 1.3);
    if (ballYSpeed < 0) ballYSpeed = -random(0.5, 1.5);
    else ballYSpeed = random(0.5, 1.5);
  }
  if (ballY>1024/50*49) ballYSpeed = -Math.abs(ballYSpeed);
  else if (ballY<1024/50) ballYSpeed = Math.abs(ballYSpeed);
}

void drawPaddles() {
  if (botMode == true) {
    fill(#00FF00);
    stroke(#00FF00);
    rect(width/20, ratio(lPaddleY, true), width/50, ratio(paddleLength, true)); //lPaddle
    fill(#FFFFFF);
    stroke(#FFFFFF);
  } else rect(width/20, ratio(lPaddleY, true), width/50, ratio(paddleLength, true)); //lPaddle
  rect(width-width/20, ratio(rPaddleY, true), width/50, ratio(paddleLength, true)); //rPaddle
}

void drawBall() {
  ellipse(ratio(ballX, false), ratio(ballY, true), height/40, height/40);
}

//makes ball faster and paddles shorter when called
void difficultyAdjust() {
  if (paddleLength > minPaddleLength) {
    paddleLength = paddleLength*98/100;
  }
  if (ballSpeed < maxBallSpeed) ballSpeed++;
}

void moveBall() {
  ballX=ballX+int(ballSpeed*ballXSpeed);
  ballY=ballY+int(ballSpeed*ballYSpeed);
}

void draw() {
  background(#000000);
  if (gameStarted == true) {
    gameTimer++;
    if (leftWins >= playTo) endGame(0);
    else if (rightWins >= playTo) endGame(1);
    textFont(font, width/15);
    text(leftWins+"  -  "+rightWins, width/2, height/10);
    if (gameEnded == false)
    {
      if (botMode == true) botMove();
      movePaddles();
      moveBall();
      ballCollision();
      drawPaddles();
      drawBall();
      if (gameTimer%150 == 0) difficultyAdjust(); //using modulus as sort of a timer of 150/60 or 2.5 seconds (gameTimer is increased by 1 every draw loop)
    }
  } else {
    menuText();
  }
}

//paddle controls and start game button
void keyPressed() {
  if (keyCode == 38 && botMode == false) rPaddleUp = true; //Up arrow
  else if (keyCode == 40 && botMode == false) rPaddleDown = true; //Down arrow
  else if (keyCode == 87) lPaddleUp = true; //W key
  else if (keyCode == 83) lPaddleDown = true; //S key
  else if (keyCode == 32) gameStarted = true; //Space key
  else if (keyCode == 10 && gameEnded == true) setVariables(); //Enter key

  else if (gameStarted == false) {
    if (keyCode == 72) { //H key
      if (instructionScreen == true) instructionScreen = false;
      else instructionScreen = true;
    } else if (keyCode == 71) { //G key
      if (wb2 == false) wb2 = true;
      else wb2 = false;
    } else if (keyCode == 66) { //B key
      if (botMode == true) botMode = false;
      else botMode = true;
    } else {
      for (int i = 1; i<=9; i++) {
        if (keyCode == i+48) { //number keys 1 to 9
          playTo = i;
          break;
        }
      }
    }
  }
}


void keyReleased() {
  if (keyCode == 38) rPaddleUp = false;
  else if (keyCode == 40) rPaddleDown = false;
  else if (keyCode == 87) lPaddleUp = false;
  else if (keyCode == 83) lPaddleDown = false;
}
