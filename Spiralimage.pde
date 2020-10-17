float r = 0;
float theta = 0;

PVector spiralpoint;
PImage picture;
ArrayList<PVector> spoints = new ArrayList<PVector>();
ArrayList<Integer> colors = new ArrayList<Integer>();

void settings()
{
  picture = loadImage("img.jpg");
  size(picture.width, picture.height);
}

void setup() {
  background(255);
  picture.loadPixels();
  picture.filter(GRAY);
  spiralpoint = new PVector(r * cos(theta)+picture.width/2, r * sin(theta)+picture.height/2);
}

void draw() {

  while ((spiralpoint.x > 0) && (spiralpoint.x < picture.width) && (spiralpoint.y >0) && (spiralpoint.y < picture.height))
  {
    spiralpoint.x = r * cos(theta)+picture.width/2;
    spiralpoint.y = r * sin(theta)+picture.height/2;
    spoints.add(new PVector(spiralpoint.x, spiralpoint.y));

    color pixelcolor = picture.get((int)spiralpoint.x, (int)spiralpoint.y);
    colors.add(pixelcolor);

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
  }
}
