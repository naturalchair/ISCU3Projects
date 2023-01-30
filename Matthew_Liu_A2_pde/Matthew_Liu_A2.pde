/*
 Matthew Liu
 2022-03-04
 ICS 3U1
 Mr. Parchimowicz
 Skyline picture
*/

/* Draws rectangle buildings with parameters called with. X specifices the x position of the bottom left corner of the rectangle, all buildings draw
 at 0.65*display height. camX, camY is the position of the camera for prespective, columns is how many columns of windows, windowHeight is the offset
 from the base of the building to when windows start drawing (ex: windowHeight=500 means windows only appear 500 units from the base of the building)*/
void drawBuilding(int x, int h, int w, int brightness, int columns, int windowHeight) {
  float midpoint = x+(w/2);
  float xOffset = (camX-midpoint)/displayWidth*75;
  float yOffset = ((camY-(displayHeight*0.65-h))/(displayHeight*0.65))*50;

  fill(brightness, brightness, brightness);
  stroke(brightness, brightness, brightness);
  rect(x+xOffset, (displayHeight*0.65)-h+yOffset, x+w+xOffset, (displayHeight*0.65)); //Side of building from prespective

  if (xOffset>0) {
    triangle(x+w, displayHeight*0.65-h, x+w, displayHeight*0.65-h+yOffset, x+w+xOffset, displayHeight*0.65-h+yOffset); //Little corner filling part of building

    fill(brightness+40, brightness+40, brightness+70, 130);
    stroke(brightness+40, brightness+40, brightness+70, 0);
    rect(x+w, displayHeight*0.65, x+w+xOffset, displayHeight*0.65+reflectionScale*(h-yOffset)); //Side of building from prespective (Reflection)

    triangle(x+w, displayHeight*0.65+h*reflectionScale, x+w+xOffset, displayHeight*0.65+reflectionScale*(h-yOffset), x+w, displayHeight*0.65+reflectionScale*(h-yOffset)); //Little corner filling part of building reflection
  } else {
    triangle(x, displayHeight*0.65-h, x, displayHeight*0.65-h+yOffset, x+xOffset, displayHeight*0.65-h+yOffset); //Little corner filling part of building

    fill(brightness+40, brightness+40, brightness+70, 130);
    stroke(brightness+40, brightness+40, brightness+70, 0);
    rect(x+xOffset, displayHeight*0.65, x, displayHeight*0.65+reflectionScale*(h-yOffset)); //Side of building from prespective (Reflection)

    triangle(x, displayHeight*0.65+h*reflectionScale, x+xOffset, displayHeight*0.65+reflectionScale*(h-yOffset), x, displayHeight*0.65+reflectionScale*(h-yOffset)); //Little corner filling part of building reflection
  }

  fill(brightness+20, brightness+20, brightness+20);
  stroke(brightness+20, brightness+20, brightness+20);
  rect(x, displayHeight*0.65-h, x+w, displayHeight*.65); //Main part of building

  fill(brightness+40, brightness+40, brightness+70, 130);
  stroke(brightness+40, brightness+40, brightness+70, 130);
  rect(x, displayHeight*0.65, x+w, displayHeight*0.65+(h*reflectionScale));  //Main part of building reflection

  //Windows
  int windowOffset = w/(columns*3+1);
  int rows = (h-windowHeight)/(windowOffset*3 + 1);
  fill(brightness+70, brightness+100, brightness+130);
  stroke(brightness+70, brightness+100, brightness+130);
  for (int i = 0; i<rows; i++) {
    for (int j = 0; j<columns; j++) {
      rect(x+windowOffset*(3*j+1), displayHeight*0.65-h+windowOffset*(3*i+1), x+windowOffset*(3*j+3), displayHeight*0.65-h+windowOffset*(3*i+3));
    }
  }

  //Windows reflection
  fill(brightness+70, brightness+100, brightness+130, 100);
  stroke(brightness+70, brightness+100, brightness+130, 100);
  for (int i = 0; i<rows; i++) {
    for (int j = 0; j<columns; j++) {
      rect(x+windowOffset*(3*j+1), displayHeight*0.65+h*reflectionScale - windowOffset*(3*i+3)*reflectionScale, x+windowOffset*(3*j+3), displayHeight*0.65+h*reflectionScale - windowOffset*(3*i+1)*reflectionScale);
    }
  }
}

/* Makes a rectangle/triangle with a gradient of colour. x, y specifies bottom left corner of rectangle/triangle, Sr/Sg/Sb is the RGB of the start
 position (x,y parameters) and rangeR/rangeG/rangeB is how much each RGB parameter changes from start to end of rectangle (bottom to top with positive parameters)
 Tri draws a triangle instead, basically same as rectangle except starts at tiny width and ends with full width
 */
void gradient(float x, float y, float h, float w, int Sr, int Sg, int Sb, int rangeR, int rangeG, int rangeB, boolean tri) {
  float greencounter = rangeG/(h);
  float redcounter = rangeR/(h);
  float bluecounter = rangeB/(h);
  int r = 0;
  int g = 0;
  int b = 0;
  if (tri == false) { //I copied the code for the loop so the computer only needs to check this conditional once, instead of every iteration of the loop
    for (int i = 0; i<=h; i++) {
      if (redcounter>r && rangeR>0) {
        r++;
      }
      if (bluecounter>b && rangeB>0) {
        b++;
      }
      if (greencounter>g && rangeG>0) {
        g++;
      }
      if (redcounter<r && redcounter<0) {
        r=r-1;
      }
      if (bluecounter<b && bluecounter<0) {
        b=b-1;
      }
      if (greencounter<g && greencounter<0) {
        g=g-1;
      }

      stroke(Sr+r, Sg+g, Sb+b);

      line(x, y-i, x+w, y-i);
      redcounter = redcounter+(rangeR/h);
      bluecounter = bluecounter+(rangeB/h);
      greencounter = greencounter+(rangeG/h);
    }
  } else {
    for (int i = 0; i<=h; i++) {
      if (redcounter>r && rangeR>0) {
        r++;
      }
      if (bluecounter>b && rangeB>0) {
        b++;
      }
      if (greencounter>g && rangeG>0) {
        g++;
      }
      if (redcounter<r && redcounter<0) {
        r=r-1;
      }
      if (bluecounter<b && bluecounter<0) {
        b=b-1;
      }
      if (greencounter<g && greencounter<0) {
        g=g-1;
      }

      stroke(Sr+r, Sg+g, Sb+b);

      line(x, y-i, x+(w*(i/h)), y-i);
      redcounter = redcounter+(rangeR/h);
      bluecounter = bluecounter+(rangeB/h);
      greencounter = greencounter+(rangeG/h);
    }
  }
}

void makeBuildings() {
  if (camX > displayWidth/2) {
    for (int i=0; i<= 10; i++) { //Draws a bunch of buildings using the values set in array
      drawBuilding(displayWidth/12 * i + displayWidth/18, buildingHeights[i], displayWidth/18, 40, windowColumns[i], 100);
    }
    for (int i=10; i<=20; i++) { //Draws more buildings, but ontop of the previous ones and a little bigger
      drawBuilding(displayWidth/11 * (i-10) + displayWidth/75, buildingHeights[i], displayWidth/15, 80, windowColumns[i], 100);
    }
  } else {
    for (int i=10; i>= 0; i=i-1) { //Draws a bunch of buildings using the values set in array
      drawBuilding(displayWidth/12 * i + displayWidth/18, buildingHeights[i], displayWidth/18, 40, windowColumns[i], 100);
    }
    for (int i=20; i>=10; i=i-1) { //Draws more buildings, but ontop of the previous ones and a little bigger
      drawBuilding(displayWidth/11 * (i-10) + displayWidth/75, buildingHeights[i], displayWidth/15, 80, windowColumns[i], 100);
    }
  }
}

//draws all the background things like the water, sky, sun, etc
void drawBackground() {
  background(255, 110, 75);
  gradient(0, displayHeight*0.4, displayHeight*0.4, displayWidth, 255, 110, 75, -200, -60, 10, false); //sky gradient

  fill(255, 150, 20);
  stroke(255, 150, 20);
  ellipse(displayWidth*0.5, displayHeight*0.55, displayWidth/3, displayWidth/3); //sun

  fill(40, 75, 160);
  stroke(40, 75, 160);
  rect(0, displayHeight*0.9, displayWidth, displayHeight); //bottom part of water

  gradient(0, displayHeight*0.9, displayHeight*0.25, displayWidth, 40, 75, 160, 200, 30, -100, false); //water gradient
  fill(255, 210, 180);
  stroke(255, 210, 180);
  rect(0, displayHeight*0.6425, displayWidth, displayHeight*0.6475); //Horizon bright thing
}

int[] buildingHeights;
int[] windowColumns;
float camY;
float camX;
float reflectionScale;

void setup() {
  int hP = displayHeight/100; //hP means 1 percent of total height, just so the array of building heights doesn't become super long
  buildingHeights = new int[]{hP*41, hP*48, hP*34, hP*45, hP*52, hP*33, hP*57, hP*36, hP*44, hP*39, hP*49, hP*28, hP*41, hP*34, hP*43, hP*35, hP*26, hP*41, hP*29, hP*53, hP*25};
  windowColumns = new int[]{2, 2, 3, 2, 2, 3, 3, 4, 2, 3, 3, 2, 2, 2, 3, 2, 4, 3, 3, 2, 2}; //# of columns of windows for building
  /*camX and camY is the "position of the camera" and affects the building prespective things. camX can be changed alot but if camY becomes higher
   than some buildings, it starts to bug since I didn't account for that in my code*/
  camY = displayHeight*0.65-hP*10;
  camX = displayWidth/2;
  reflectionScale = 0.6;
  fullScreen();

  rectMode(CORNERS);

  drawBackground();
  makeBuildings();

  fill(50, 50, 50);
  stroke(50, 50, 50);
  rect(0, displayHeight*0.66, displayWidth, displayHeight*0.65); //black road thing that gets drawn after buildings
}
