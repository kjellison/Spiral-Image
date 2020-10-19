float r = 0;
float theta = 0;

PVector spiralpoint;
PImage picture;
ArrayList<PVector> spoints = new ArrayList<PVector>();
ArrayList<Integer> colors = new ArrayList<Integer>();
float engwidth;
float engheight;
float ppmmwidth;
float ppmmheight;
ArrayList<PVector> gcodepoints = new ArrayList<PVector>();
PrintWriter gcode;
float feedrate;
int minlaser;
int maxlaser;

void settings()
{
  picture = loadImage("ada.jpg");
  size(picture.width, picture.height);
}

void setup() {
  background(255);
  picture.loadPixels();
  picture.filter(GRAY);
  spiralpoint = new PVector(r * cos(theta)+picture.width/2, r * sin(theta)+picture.height/2);
  engwidth = 150;
  engheight = 150;
  ppmmwidth = width/engwidth;
  ppmmheight = height/engheight;
  gcode = createWriter("gcode.txt");
  feedrate = 800;
  minlaser = 0;
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
    
    PVector gpoint = new PVector(spiralpoint.x*ppmmwidth, spiralpoint.y*ppmmheight, map(red(pixelcolor), 0, 255, maxlaser, minlaser));
    gcodepoints.add(gpoint);

    theta += 0.001;
    r += 0.001;
  }
  strokeWeight(1);

    for (int i = 1; i < spoints.size(); i++)
  {
    stroke(colors.get(i));
    line(spoints.get(i-1).x, spoints.get(i-1).y, spoints.get(i).x, spoints.get(i).y);
  }
}

void keyPressed()
{
  if (key == 's')
  {
    save("spiral.png");
    println("Saved");
  }
  if (key == 'o')
  {
    gcode.println("G90");
    gcode.println("M5 S"+(int)gcodepoints.get(0).z);
    gcode.println("G1 F"+feedrate);
    gcode.println("G0 X"+gcodepoints.get(0).x+" Y"+gcodepoints.get(0).y);
    gcode.println("M4");
    for (int i = 1; i < gcodepoints.size(); i++)
    {
      PVector pnt = gcodepoints.get(i);
      gcode.println("G1 X"+pnt.x+" Y"+pnt.y+" S"+(int)pnt.z);
    }
    gcode.println("M5");
    gcode.println("G0 X0 Y0 Z0");
    gcode.flush();
    gcode.close();
    println("Gcode saved");
  }
}
