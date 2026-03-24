/** SIMULATION BOOLEANS **/
boolean ordered = false;
boolean layeredDrag = false;
boolean traceOn = true;
boolean springSimOn = false;


int NUM_ORBS = 10;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 0.1;
float K_CONSTANT = 5 * pow(10, 4);

float D_COEF = 0.1; // default drag coefficient, overriden in drag simulation

/** DRAG SIMULATION COEFFICIENT VALUES **/
float dragAir = 0.3;
float dragWater = 0.4;
float dragHoney = 0.6; // honey viscosity is simulated through a higher drag force

/** FLUID DENSITY VALUES **/
float airDensity = 0.001;
float waterDensity = 0.005;
float honeyDensity = 0.01;

/** SPRING VALUES **/
int SPRING_LENGTH = 120;
float  SPRING_K = 0.01;

float ELECTRIC_FIELD_MAGNITUDE = 1000; // units are N/C or V/m
float ELECTRIC_FIELD_ANGLE = -PI/2; // radians
//  REMINDER: If orbs don't move in the intended direction, Processing's y-coordinate system starts from 0 and increases as you move down
PVector ELECTRIC_FIELD = new PVector(ELECTRIC_FIELD_MAGNITUDE * cos(ELECTRIC_FIELD_ANGLE), ELECTRIC_FIELD_MAGNITUDE * sin(ELECTRIC_FIELD_ANGLE));


float MAGNETIC_FIELD = 20; // SI units are teslas (N/Am)

/** SIMULATION TRIGGERS **/
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
  frameRate(120);
  size(1000, 1000);
  standardInit();

  println("Sup mfers! and mr mykolyk ig");
  println("Anyways, here's a list of controls. Any clarification you need will be found in the comments");
  println("If you need further clarification, read the damn code.");
  println("If something doesn't quite work right, adjust the global variables.");
  println("Forcec Controls:");
  println("[ ]: Start/stop");
  println("[g]: gravity on/off");
  println("[b]: bounce on/off");
  println("[d]: drag on/off");
  println("[e]: electrostatic force on/off");
  println("[s]: springs on/off");
  println("[f]: electric field on/off");
  println("[m]: magnetic field on/off");
  println("[ ] ]: Electric field angle rotation counterclockwise.");
  println("[ [ ]: Electric field angle rotation clockwise.");
  println("[T]: Trace on/off");
  println("Simulation Controls:");
  println("[1]: Standard Initialization");
  println("[2]: Gravity Simulation: Three Body Chaos");
  println("[3]: Electrostatic Force Simulation: Coulomb's Law");
  println("[4]: Drag Force Simulation: Air, Water, and Honey (Sorta)");
  println("[5]: Spring Force Simulation: Harmonic Motion (and a little bit of pendulums too)");
  println("[6]: Electric Field Simulation: Quicker than Merge Sort?");
  println("[7]: Magnetic Field Simulation: Look at those patternsqw3uhbkwfiouhyaewoiuhvqefgiuvwrd");
}

/** SIMULATION INITIALIZATION **/
// Resets all currently active toggles and sets active the correct toggles that correspond to the current

// Normal simulation - not meant to demonstrate anything in particular
void standardInit()
{
  ordered = false;
  layeredDrag = false;
  springSimOn = false;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }

  NUM_ORBS = 10;
  makeOrbs(ordered);
  // earth = new FixedOrb(width / 2, height * 1000, 5, 200000);
}


// Gravity simulation - designed to demonstrate the three-body problem in physics (calculating motion of three bodies that are pulling on each other at the same time)
void gravitySimInit()
{
  ordered = false;
  layeredDrag = false;
  springSimOn = false;

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


// Electrostatic simulation - designed to demonstrate Coulomb's law and the interaction between positive (+), negative (-), and neutral (.) charges
void electroStatSimInit()
{
  ordered = true;
  layeredDrag = false;
  springSimOn = false;

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


// Drag simulation - simulates drag force through air, water, and honey
void dragSimInit()
{
  ordered = false;
  layeredDrag = true;
  springSimOn = false;

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


// Spring simulation - based off of spring lab
void springSimInit()
{
  ordered = false;
  layeredDrag = false;
  springSimOn = true;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[SPRING] = true;
  toggles[GRAVITY] = true;

  NUM_ORBS = 3;
  orbCount = NUM_ORBS;
  makeOrbs(ordered);
  earth = new FixedOrb(width / 2, height * 1000, 5, 200000);

  orbs = new Orb[NUM_ORBS];

  orbs[0] = new FixedOrb(width/2, height / 2, 0.00001, 0);
  orbs[1] = new Orb();
  orbs[2] = new Orb();

  while (orbs[1].center.x > width/4 && orbs[1].center.x < 3 * width/4)
  {
    orbs[1].center.x = random(0, width);
  }

  orbs[1].mass = 50;
  orbs[1].bsize = 25;
}


// Electric field simulation - illustrates a parallel plate capacitor's charges
void eFieldSimInit()
{
  ordered = true;
  layeredDrag = false;
  springSimOn = false;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[EFIELD] = true;
  toggles[BOUNCE] = true;

  NUM_ORBS = 20;
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


// Magnetic field simulation
void bFieldSimInit()
{
  ordered = false;
  layeredDrag = false;
  springSimOn = false;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = false;
  }
  toggles[BFIELD] = true;
  toggles[BOUNCE] = true;

  earth = null;
  NUM_ORBS = 3;
  makeOrbs(ordered);

  orbs[0].bsize = 25;
  orbs[1].bsize = 5;
  orbs[2].bsize = 25;

  orbs[0].center = new PVector(orbs[0].bsize/2, height/6);
  orbs[1].center = new PVector(orbs[1].bsize/2, height/2);
  orbs[2].center = new PVector(orbs[2].bsize/2, 5 * height/6);

  orbs[0].velocity = new PVector(10, 0);
  orbs[1].velocity = new PVector(10, 0);
  orbs[2].velocity = new PVector(10, 0);

  orbs[0].charge = -0.01;
  orbs[1].charge = 0;
  orbs[2].charge = 0.01;

  orbs[0].mass = 50;
  orbs[1].mass = 50;
  orbs[2].mass = 50;
}
void combSimInit()
{
  ordered = false;
  layeredDrag = true;
  springSimOn = false;
  earth = null;

  for (int i = 0; i < toggles.length; i++)
  {
    toggles[i] = true;
  }
  NUM_ORBS = 10;
  for (int i = 0; i < 10; i++)
  {
    orbs[i] = new Orb();
  }
}
void draw() // applies forces depending on currently active toggles and simulation
{
  background(255);
  displayMode();


  // Drag simulation boolean check
  if (layeredDrag)
  {
    fill(#04ADE2);
    rect(0, height/3, width, height/3);
    fill(#EBA937);
    rect(0, 2 * height/3, width, height/3);
  }

  // println(ELECTRIC_FIELD_ANGLE);

  // draw the traces
  for (int o=0; o < orbCount; o++) {
    orbs[o].drawTrace(50);
    if (traceOn && springSimOn == false)
    {
      orbs[o].traceDisplay();
    }
  }
  if (traceOn && springSimOn == true)
    {
      orbs[2].traceDisplay();
    }

  // draw the orbs and springs
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
    for (int i = 0; i < orbCount; i++)
    {
      for (int j = 1; j < orbCount; j++)
      {
        orbs[i].collide(orbs[j]);
      }
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
    ELECTRIC_FIELD_ANGLE -= 0.1;
    ELECTRIC_FIELD = new PVector(ELECTRIC_FIELD_MAGNITUDE * cos(ELECTRIC_FIELD_ANGLE), ELECTRIC_FIELD_MAGNITUDE * sin(ELECTRIC_FIELD_ANGLE));
  }
  if (key == '[')
  {
    ELECTRIC_FIELD_ANGLE += 0.1;
    ELECTRIC_FIELD = new PVector(ELECTRIC_FIELD_MAGNITUDE * cos(ELECTRIC_FIELD_ANGLE), ELECTRIC_FIELD_MAGNITUDE * sin(ELECTRIC_FIELD_ANGLE));
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
  if (key == '6')
  {
    eFieldSimInit();
  }
  if (key == '7')
  {
    bFieldSimInit();
  }
  if (key == '8')
  {
    combSimInit();
  }
  if (key == 't')
  {
    traceOn = !traceOn;
  }

  if (key == '-' && orbCount > 0) {
    orbs[orbCount - 1] = null;
    orbCount--;
  }//removal
  if (key == '=' || key == '+') {
    addOrb();
  }//addition
}//keyPressed
