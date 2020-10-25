//Kelly Jellison Oct 2020
//Spiral Image takes a picture, gets the grayscale value of each pixel in a spiral and draws out the spiral.
//Outputs Gcode that draws the spiral with higher laser power on darker pixels.

float r = 0;
float theta = 0;
PVector spiralpoint;
PImage picture;
ArrayList<PVector> spoints = new ArrayList<PVector>();
ArrayList<Integer> colors = new ArrayList<Integer>();

//Spiral Settings
final float rStep = 0.001;
final float tStep = 0.001;

//GCode Variables
float engwidth;
float engheight;
float ppmmwidth;
float ppmmheight;
ArrayList<PVector> gcodepoints = new ArrayList<PVector>();
PrintWriter gcode;
float feedrate;
int minlaser;
int maxlaser;

void settings()  //Load picture in settings so the window size can be set to the size of the image, it doesn't work if you try to do it in setup.
{
  picture = loadImage("siblings.png");
  size(constrain(picture.width, 400, 800), constrain(picture.height, 400, 800));
}

void setup() {
  background(255);
  picture.loadPixels();
  picture.filter(GRAY);
  //Start in the middle
  spiralpoint = new PVector(r * cos(theta)+picture.width/2, r * sin(theta)+picture.height/2);

  


  //Physical size of engraving in millimeters Bigger number is smaller will fix later
  engwidth = 50;
  engheight = 50;

  //Pixels per millimeter
  engwidth = 1/engwidth;
  engheight = 1/engheight;

  ppmmwidth = picture.width*engwidth;
  ppmmheight = picture.height*engheight;
  gcode = createWriter("gcode.nc");

  //Adjustments for the laser
  feedrate = 1200;
  minlaser = 200;
  maxlaser = 1000;
}

void draw() {

  while ((spiralpoint.x > 0) && (spiralpoint.x < picture.width) && (spiralpoint.y >0) && (spiralpoint.y < picture.height)) 
  {
    spiralpoint.x = r * cos(theta)+picture.width/2;
    spiralpoint.y = r * sin(theta)+picture.height/2;
    spoints.add(new PVector(spiralpoint.x, spiralpoint.y));

    color pixelcolor = picture.get((int)spiralpoint.x, (int)spiralpoint.y);
    colors.add(pixelcolor);

    //Uses the z-coordinates as laser intensity This can also be used for z-azis on a v-bit engraver
    PVector gpoint = new PVector(spiralpoint.x/ppmmwidth, spiralpoint.y/ppmmheight, map(red(pixelcolor), 0, 255, maxlaser, minlaser));
    gcodepoints.add(gpoint);

    theta += tStep;
    r += rStep;
  }
  strokeWeight(1);

  for (int i = 1; i < spoints.size(); i++)
  {
    //Change stroke based on grayscale value
    //stroke(colors.get(i));
    //line(spoints.get(i-1).x, spoints.get(i-1).y, spoints.get(i).x, spoints.get(i).y);

    //Change stroke width based on grayscale value
    strokeWeight(map(red(colors.get(i)), 0, 255, 5, 0));
    line(spoints.get(i-1).x, spoints.get(i-1).y, spoints.get(i).x, spoints.get(i).y);
  }
}

void keyPressed()
{
  if (key == 's')
  {
    save("spiral.png");
    println("Image Saved");
  }
  if (key == 'o')
  {
    gcode.println("G90");
    gcode.println("M5 S"+(int)gcodepoints.get(0).z);
    gcode.println("G1 F"+feedrate);
    gcode.println("G0 X"+nf(gcodepoints.get(0).x, 0, 2)+" Y"+nf(gcodepoints.get(0).y, 0, 2));
    gcode.println("M4");
    for (int i = 1; i < gcodepoints.size(); i++)
    {
      PVector pnt = gcodepoints.get(i);
      gcode.println("G1 X"+nf(pnt.x, 0, 2)+" Y"+nf(pnt.y, 0, 2)+" S"+(int)pnt.z);
    }
    gcode.println("M5");
    gcode.println("G0 X0 Y0 Z0");
    gcode.flush();
    gcode.close();
    println("Gcode saved");
  }
}
