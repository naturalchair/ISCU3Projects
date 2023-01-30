/*
 Matthew Liu
 2022-02-14
 ICS3U1
 Michael Parchimowicz
 Assignment 1 - Nameplate
*/
 
//xPositions is to store the locations of each drawn letter from left to right, letter is to store the order of the letters from left to right
int xPositions[] = new int[14];
char letter[] = {'m', 'a', 't', 't', 'h', 'e', 'w'};

//clicking on a letter makes it flash white, the loops are to check whether or not the mouseposition is on a letter, and which letter it is on
void mousePressed() {
  for (int k = 0; k <= 6; k++) {
    //Checking if the mouse position is in the range of the letters and which letter it is on
    if (mouseY > 75 && mouseY < 325) {
      if (mouseX > xPositions[k*2] && mouseX < xPositions[(k*2)+1]) {
        changeColour(letter[k], xPositions[k*2], 75);
      }
    }
  }
}
//changes the colour of a letter to white
void changeColour(char letter, int x, int y) {
  fill(255, 255, 255);
  stroke(255, 255, 255);
  if (letter == 'm') drawM(x, y, 0);
  else if (letter == 'a') drawA(x, y, 2);
  else if (letter == 't') drawT(x, y, 4);
  else if (letter == 'h') drawH(x, y, 6);
  else if (letter == 'e') drawE(x, y, 8);
  else if (letter == 'w') drawW(x, y, 10);
}

void draw() {
  background(#FFFFFF);
  fill(50, 220, 220);
  rect(25, 25, 1000, 350); 
  /* I did not make a method for basic shapes like ellipse, rect, etc as that is redundant, 
   however, I made one for triangles to use degrees and a radius for the points */
  fill(150, 255, 255);
  rect(50, 50, 950, 300);
  stroke(#555555);
  fill(200, 200, 200);

  //the ellipse and triangles are for screws I decided to add in the corners of the nameplate. 
  ellipse(38, 38, 20, 20);
  ellipse(1012, 38, 20, 20);
  ellipse(38, 362, 20, 20);
  ellipse(1012, 362, 20, 20);

  drawTriangle(38, 38, 7.5, 20, 140, 260);
  drawTriangle(1013, 38, 7.5, 80, 200, 320);
  drawTriangle(38, 362, 7.5, 50, 170, 290);
  drawTriangle(1013, 362, 7.5, 30, 150, 270);

  stroke(#0096FF);
  fill(0, 150, 255);

  drawM(75, 75, 0);
  drawA(225, 75, 2);
  drawT(350, 75, 4);
  drawT(475, 75, 6);
  drawH(600, 75, 8);
  drawE(725, 75, 10);
  drawW(850, 75, 12);
}

void drawEllipse(int xPos, int yPos, int x, int y) {
  ellipse(xPos, yPos, x, y);
}

/* Draws a triangle by defining the center of a circle and setting the 3 verticies to points on the circle's radius. 
 Angles are in degrees, 0 Deg = Right most point of circle, 90 Deg = Top most point of circle */
void drawTriangle(int x, int y, float radius, float deg1, float deg2, float deg3) {
  triangle(x+(radius*cos(deg1/180*3.14159265)), y+radius*sin(deg1/180*3.1415926535), x+(radius*cos(deg2/180*3.14159265)), y+radius*sin(deg2/180*3.1415926535), x+(radius*cos(deg3/180*3.14159265)), y+radius*sin(deg3/180*3.1415926535));
}

void drawM(int x, int y, int i) {
  rect(x, y, 25, 250); //M letter
  rect(x, y, 100, 25);
  rect(x+50, y, 25, 250);
  rect(x+100, y, 25, 250);
  xPositions[i] = x;
  xPositions[i+1] = x+125;
}

void drawA(int x, int y, int i) {
  rect(x, y, 25, 250); //A letter
  rect(x, y, 100, 25);
  rect(x+75, y, 25, 250);
  rect(x, y+150, 100, 25);
  xPositions[i] = x;
  xPositions[i+1] = x+100;
}

void drawT(int x, int y, int i) {
  rect(x, y, 100, 25); //Both T's
  rect(x+37, y, 25, 250); 
  xPositions[i] = x;
  xPositions[i+1] = x+100;
}

void drawH(int x, int y, int i) {
  rect(x, y, 25, 250); // H letter
  rect(x+75, y, 25, 250);
  rect(x, y+150, 75, 25);
  xPositions[i] = x;
  xPositions[i+1] = x+100;
}

void drawE(int x, int y, int i) {
  rect(x, y, 100, 25); //E letter
  rect(x, y, 25, 250);
  rect(x, y+150, 75, 25);
  rect(x, y+225, 100, 25);
  xPositions[i] = x;
  xPositions[i+1] = x+100;
}

void drawW(int x, int y, int i) {
  rect(x, y, 25, 250); //W letter
  rect(x+50, y, 25, 250);
  rect(x, y+225, 100, 25);
  rect(x+100, y, 25, 250);
  xPositions[i] = x;
  xPositions[i+1] = x+125;
} 
void setup() {
  //  size(displayWidth,displayHeight); -> full screen
  size(1050, 400);
}
