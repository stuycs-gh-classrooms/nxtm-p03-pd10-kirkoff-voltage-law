

int NUM_ORBS = 10;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 0.1;
float D_COEF = 0.1;

int SPRING_LENGTH = 50;
float  SPRING_K = 0.005;

int MOVING = 0;
int BOUNCE = 1;
int GRAVITY = 2;
int DRAGF = 3;
boolean[] toggles = new boolean[4];
String[] modes = {"Moving", "Bounce", "Gravity", "Drag"};

FixedOrb earth;
Orb[] orbs;
int orbCount;

void setup()
{
  size(500, 500);
  makeOrbs(false);
  earth = new FixedOrb(width / 2, height * 1000, 5, 100000);
}

void draw()
{
  background(255);
  displayMode();

  //draw the orbs and springs
  for (int o=0; o < orbCount; o++) {
    orbs[o].display();
  }

  for (int o=0; o < orbCount - 1; o++) {
    drawSpring(orbs[o], orbs[o+1]);
  }

  if (toggles[MOVING]) {
    applySprings();

    for (int o=0; o < orbCount; o++) {
      if (toggles[GRAVITY])
      {
        orbs[o].applyForce(orbs[o].getGravity(earth, G_CONSTANT));
        for (int i = 0; i < orbCount; i++)
        {
          orbs[o].applyForce(orbs[o].getGravity(orbs[i], G_CONSTANT));
        }
      }
      if (toggles[DRAGF])
      {
        orbs[o].applyForce(orbs[o].getDragForce(D_COEF));
      }
    }//gravity, drag

    for (int o=0; o < orbCount; o++) {
      orbs[o].move(toggles[BOUNCE]);
    }
  }//moving
}//draw

void applySprings()
{
  if (orbCount < 2) return;

  for (int i = 0; i < orbCount; i++) {
    if (i == 0) {
      orbs[i].applyForce(orbs[i].getSpring(orbs[i + 1], SPRING_LENGTH, SPRING_K));
    } else if (i == orbCount - 1) {
      orbs[i].applyForce(orbs[i].getSpring(orbs[i - 1], SPRING_LENGTH, SPRING_K));
    } else {
      orbs[i].applyForce(orbs[i].getSpring(orbs[i + 1], SPRING_LENGTH, SPRING_K));
      orbs[i].applyForce(orbs[i].getSpring(orbs[i - 1], SPRING_LENGTH, SPRING_K));
    }
  }
}

void displayMode()
{
  textAlign(LEFT, TOP);
  textSize(20);
  noStroke();
  int spacing = 85;
  int x = 0;

  for (int m=0; m<toggles.length; m++) {
    //set box color
    if (toggles[m]) {
      fill(0, 255, 0);
    } else {
      fill(255, 0, 0);
    }

    float w = textWidth(modes[m]);
    rect(x, 0, w+5, 20);
    fill(0);
    text(modes[m], x+2, 2);
    x+= w+5;
  }
}//display

void makeOrbs(boolean ordered)
{
  orbCount = NUM_ORBS;
  orbs = new Orb[orbCount];
  if (!ordered)
  {
    for (int i = 0; i < orbs.length; i++)
    {
      orbs[i] = new Orb();
    }
  } else
  {
    for (int i = 0; i < orbs.length; i++)
    {
      orbs[i] = new Orb();
      if (i > 0)
      {
        orbs[i].center = new PVector(orbs[i-1].center.x + SPRING_LENGTH, height/2);
      } else
      {
        orbs[i].center = new PVector(orbs[i].bsize/2, height/2);
      }
    }
  }
}//makeOrbs

void addOrb()
{
  if (orbCount < orbs.length)
  {
    orbs[orbCount] = new Orb();
    orbCount++;
  } else
  {
    Orb[] tempOrbs = new Orb[orbs.length + 1];
    myArrayCopy(orbs, tempOrbs);
    orbs = tempOrbs;
    orbs[orbCount] = new Orb();
    orbCount++;
  }
}//addOrb

void myArrayCopy(Orb[] source, Orb[] target)
{
  for (int i = 0; i < source.length; i++)
  {
    target[i] = source[i];
  }
}

void drawSpring(Orb o0, Orb o1)
{
  if (o0.center.dist(o1.center) < SPRING_LENGTH)
  {
    stroke(0, 255, 0);
  } else if (o0.center.dist(o1.center) > SPRING_LENGTH)
  {
    stroke(255, 0, 0);
  } else
  {
    stroke(0);
  }
  line(o0.center.x, o0.center.y, o1.center.x, o1.center.y);
}//drawSpring

void keyPressed()
{
  if (key == ' ') {
    toggles[MOVING]  = !toggles[MOVING];
  }
  if (key == 'g') {
    toggles[GRAVITY] = !toggles[GRAVITY];
  }
  if (key == 'b') {
    toggles[BOUNCE]  = !toggles[BOUNCE];
  }
  if (key == 'd') {
    toggles[DRAGF]   = !toggles[DRAGF];
  }
  if (key == '1') {
    makeOrbs(true);
  }
  if (key == '2') {
    makeOrbs(false);
  }

  if (key == '-' && orbCount > 0) {
    orbs[orbCount - 1] = null;
    orbCount--;
  }//removal
  if (key == '=' || key == '+') {
    //Part 4: Write addOrb() below
    addOrb();
  }//addition
}//keyPressed
