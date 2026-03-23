boolean ordered = false;
boolean layeredDrag = false;

int NUM_ORBS = 10;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 0.1;
float K_CONSTANT = 2 * pow(10, 4);

float D_COEF = 0.1; // uniform drag coefficient, this is NOT the value used in the drag simulation.

// ACTUAL DRAG COEFFICIENT VALUES
float dragAir = 0.3;
float dragWater = 0.4;
float dragHoney = 0.6; // Technically, drag isn't supposed to be applied to honey because of its viscosity, but oh well I'm not researching another equation for this.
                       // Instead, I just used a higher drag for honey to simulate viscosity instead.

// FLUID DENSITY VALUES
float airDensity = 0.001;
float waterDensity = 0.005;
float honeyDensity = 0.01;

int SPRING_LENGTH = 120;
float  SPRING_K = 0.01;

float ELECTRIC_FIELD_MAGNITUDE = 10000; // Units are N/C or V/m
float ELECTRIC_FIELD_ANGLE = -PI/2; // very importantly in RADIANS, not degrees.
//  Also, processing coordinate system is flipped cross the x-axis, keep this in mind when orbs dont move in the intended direction.
PVector ELECTRIC_FIELD = new PVector(ELECTRIC_FIELD_MAGNITUDE * cos(ELECTRIC_FIELD_ANGLE), ELECTRIC_FIELD_MAGNITUDE * sin(ELECTRIC_FIELD_ANGLE));


float MAGNETIC_FIELD = 1500; // SI units are teslas (N/Am)


int MOVING = 0;
int BOUNCE = 1;
int GRAVITY = 2;
int DRAGF = 3;
int ELECTROSTAT = 4;
int SPRING = 5;
int EFIELD = 6;
int BFIELD = 7;
boolean[] toggles = new boolean[8];
String[] modes = {"Moving", "Bounce", "Gravity", "Drag", "ElectroStat", "Spring", "EField", "BField"};

FixedOrb earth;
Orb[] orbs;
int orbCount;

void setup()
{
  size(1000, 1000);
  standardInit();
}

// The following are the initialization functions for each simulation.
void standardInit()
{
  // Essentially the basic initialization, not meant to demonstrate anything in particular.

  ordered = false;
  layeredDrag = false;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }

  NUM_ORBS = 10;
  makeOrbs(ordered);
  earth = new FixedOrb(width / 2, height * 1000, 5, 200000);
}

void gravitySimInit()
{
  // Gravity simulation initialization. Designed to demonstrate the classic three body problem.
  ordered = false;
  layeredDrag = false;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[GRAVITY] = true;
  toggles[BOUNCE] = true;

  NUM_ORBS = 3;
  makeOrbs(ordered);
  earth = null;
  for (int i = 0; i < orbs.length; i++)
  {
    orbs[i].charge = 0;
    orbs[i].c = 0;
  }
}

void electroStatSimInit()
{
  // Electrostatic force demonstration. Designed to demonstrate Coulomb's law, interaction between +, -, and neutral charges.

  ordered = true;
  layeredDrag = false;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[ELECTROSTAT] = true;
  toggles[BOUNCE] = true;

  NUM_ORBS = 5;
  makeOrbs(ordered);
  earth = null;

  orbs[0].charge = (int)(random(3)) - 1;
  orbs[1].charge = (int)(random(3)) - 1;
  orbs[2].charge = (int)(random(3)) - 1;
  orbs[3].charge = (int)(random(3)) - 1;
  orbs[4].charge = (int)(random(3)) - 1;

  orbs[0].bsize = 25;
  orbs[1].bsize = 25;
  orbs[2].bsize = 25;
  orbs[3].bsize = 25;
  orbs[4].bsize = 25;
}

void dragSimInit()
{
  // Drag force simulation. Three different layers: air, water, honey.

  ordered = false;
  layeredDrag = true;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[DRAGF] = true;
  toggles[BOUNCE] = true;

  NUM_ORBS = 3;
  makeOrbs(ordered);
  earth = null;

  for (int i = 0; i < orbs.length; i++)
  {
    orbs[i].charge = 0;
    orbs[i].c = 0;
  }

  orbs[0].bsize = 25;
  orbs[1].bsize = 25;
  orbs[2].bsize = 25;

  orbs[0].center = new PVector(orbs[0].bsize + 10, height / 6);
  orbs[1].center = new PVector(orbs[1].bsize + 10, height / 2);
  orbs[2].center = new PVector(orbs[2].bsize + 10, 5 * height / 6);

  orbs[0].velocity = new PVector(25, 0);
  orbs[1].velocity = new PVector(25, 0);
  orbs[2].velocity = new PVector(25, 0);

  orbs[0].mass = 50;
  orbs[1].mass = 50;
  orbs[2].mass = 50;
}

void springSimInit()
{
  ordered = true;
  layeredDrag = false;
  
  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[SPRING] = true;
  toggles[GRAVITY] = true;
  
  NUM_ORBS = 2;
  makeOrbs(ordered);
  earth = new FixedOrb(width / 2, height * 1000, 5, 200000);
  
  orbs = new Orb[NUM_ORBS];
  
  orbs[0] = new FixedOrb(width/2, height / 2, 0.00001, 0);
  orbs[1] = new Orb();
  
  while(orbs[1].center.x > width/4 && orbs[1].center.x < 3 * width/4)
  {
    orbs[1].center.x = random(0, width);
  }
  
  orbs[1].mass = 50;
  orbs[1].bsize = 25;
}

void draw()
{
  background(255);
  displayMode();

  // for the drag simulation, off otherwise
  if (layeredDrag)
  {
    fill(#04ADE2);
    rect(0, height/3, width, height/3);
    fill(#EBA937);
    rect(0, 2 * height/3, width, height/3);
  }

  // println(ELECTRIC_FIELD_ANGLE);

  //draw the orbs and springs
  for (int o=0; o < orbCount; o++) {
    orbs[o].display();
  }

  for (int o=0; o < orbCount - 1; o++) {
    if (toggles[SPRING])
    {
      drawSpring(orbs[o], orbs[o+1]);
    }
  }

  if (toggles[MOVING]) {
    if (toggles[SPRING])
    {
      applySprings();
    }

    for (int o=0; o < orbCount; o++) {
      if (toggles[GRAVITY])
      {
        if (earth != null)
        {
          orbs[o].applyForce(orbs[o].getGravity(earth, G_CONSTANT));
        }
        for (int i = 0; i < orbCount; i++)
        {
          if (i == o)
          {
            continue;
          }
          orbs[o].applyForce(orbs[o].getGravity(orbs[i], G_CONSTANT));
        }
      }

      if (toggles[DRAGF] && layeredDrag)
      {
        if (orbs[o].center.y < height/3)
        {
          orbs[o].applyForce(orbs[o].getDragForce(airDensity, dragAir));
        } else if (orbs[o].center.y >  height/3 && orbs[o].center.y < 2 * height/3)
        {
          orbs[o].applyForce(orbs[o].getDragForce(waterDensity, dragWater));
        } else
        {
          orbs[o].applyForce(orbs[o].getDragForce(honeyDensity, dragHoney));
        }
      } else if (toggles[DRAGF] && !layeredDrag)
      {
        orbs[o].applyForce(orbs[o].getDragForce(airDensity, dragAir));
      }

      if (toggles[ELECTROSTAT])
      {
        for (int i = 0; i < orbCount; i++)
        {
          if (i == o)
          {
            continue;
          }
          orbs[o].applyForce(orbs[o].getElectroStat(orbs[i], K_CONSTANT));
        }
      }
      if (toggles[EFIELD])
      {
        orbs[o].applyForce(orbs[o].getElectricFieldForce(ELECTRIC_FIELD));
      }
      if (toggles[BFIELD])
      {
        orbs[o].applyForce(orbs[o].getMagneticFieldForce(MAGNETIC_FIELD));
      }
    }//gravity, drag, estat, etc

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
        orbs[i].center = new PVector(orbs[i-1].center.x + width/NUM_ORBS, height/2);
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
  if (key == 'e') {
    toggles[ELECTROSTAT]   = !toggles[ELECTROSTAT];
  }
  if (key == 's') {
    toggles[SPRING]   = !toggles[SPRING];
  }
  if (key == 'f') {
    toggles[EFIELD]   = !toggles[EFIELD];
  }
  if (key == 'm') {
    toggles[BFIELD]   = !toggles[BFIELD];
  }
  if (key == ']')
  {
    ELECTRIC_FIELD_ANGLE -= 0.01;
  }
  if (key == '[')
  {
    ELECTRIC_FIELD_ANGLE += 0.01;
  }
  if (key == '1')
  {
    standardInit();
  }
  if (key == '2')
  {
    gravitySimInit();
  }
  if (key == '3')
  {
    electroStatSimInit();
  }
  if (key == '4')
  {
    dragSimInit();
  }
  if (key == '5')
  {
    springSimInit();
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
