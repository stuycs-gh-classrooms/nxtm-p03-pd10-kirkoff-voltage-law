class Orb
{
  // instance variables
  PVector center;
  PVector velocity;
  PVector acceleration;
  float bsize;
  float mass;
  float charge;
  color c;

  ArrayList<PVector> trace = new ArrayList(50);

  float currentFluidDensity;


  /**
   Constructs an object of class Orb at a random position with a random size and mass.
   Sets default parameters of the object.
   */
  Orb()
  {
    bsize = random(10, MAX_SIZE);
    float x = random(bsize/2, width-bsize/2);
    float y = random(bsize/2, height-bsize/2);
    charge = random(-0.1, 0.1);
    center = new PVector(x, y);
    mass = random(10, 100);
    // mass = 5 * bsize;
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }


  /**
   Constructs an object of class Orb at a given position with a given size and mass.
   Used for setting explicit parameters of the object.
   */
  Orb(float x, float y, float s, float m, float q)
  {
    bsize = s;
    mass = m;
    charge = q;
    center = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }


  void move(boolean bounce) // Changes the Orb's position and calculates bounces, applies acceleration and velocity, and resets acceleration after every frame to prevent infinite acceleration
  {
    drawTrace(20);
    if (bounce) {
      xBounce();
      yBounce();
    }

    velocity.add(acceleration);
    center.add(velocity);

    collide();

    acceleration.mult(0);

    if (bounce)
    {
      center.x = constrain(center.x, bsize/2 - 5, width - bsize/2 + 5);
      center.y = constrain(center.y, bsize/2 - 5, height - bsize/2 + 5);
    }
  }//move

  void drawTrace(int traceLength) // Create a temporary trail that follows the Orb, begins deleting the first point upon reaching the max number of "traced" points
  {
    PVector newCircle = new PVector(center.x, center.y);
    trace.add(newCircle);
    fill(0);


    for (int i = 0; i < trace.size(); i++)
    {
      circle(trace.get(i).x, trace.get(i).y, 3);
    }
    if (trace.size() > traceLength)
    {
      for (int i = 0; i < trace.size() - 1; i++)
      {
        if (trace.get(i+1) != null)
        {
          trace.set(i, trace.get(i+1));
        } else
        {
          trace.set(i+1, null);
        }
      }
    }
  }


  void applyForce(PVector force) // Applies a given force to the Orb using F=ma formula and applies acceleration depending on the force and mass of the Orb.
  {
    PVector scaleForce = force.copy();
    scaleForce.div(mass);
    acceleration.add(scaleForce);
  }


  PVector getDragForce(float fluidDensity, float cd) // Calculates a theoretical drag force being applied on an object using a drag coefficient and velocity as parameters. Returns a PVector force
  {
    float area = PI * (bsize/2) * (bsize/2); // Cross-sectional area

    float dragMag = -0.5 * velocity.mag() * velocity.mag() * cd * fluidDensity * area;

    PVector dragForce = velocity.copy();
    if (dragForce.mag() != 0)
    {
      dragForce.normalize();
    }
    dragForce.mult(dragMag);

    if (dragForce.mag() > velocity.mag() * mass)
    {
      PVector v = velocity.copy();
      dragForce = v.mult(-mass);
    }
    return dragForce;
  }


  PVector getGravity(Orb other, float G) // Calculates the force of gravity between two Orbs using a gravitational coefficient as a parameter. Returns a PVector force
  {
    float strength = G * mass*other.mass;

    // Avoid division by 0
    float r = max(center.dist(other.center), MIN_SIZE);

    strength = strength/ pow(r, 2);
    PVector force = other.center.copy();
    force.sub(center);
    force.mult(strength);
    return force;
  }

  PVector getElectroStat(Orb other, float k) // Calculates the electrostatic force between two Orbs using the k constant as a parameter. Returns a PVector force
  {

    /*
     This subtraction appears reversed such that you can get the correct directions for the vectors.
     You can check it yourself: In this scenario, the force vector starts out pointing away from the other orb.
     This means that with two positive or two negative charges, the sign remains unchanged and you get repulsion (this lines up with reality)
     With a + and a -, the sign is flipped and you get attraction.
     */
    PVector force = center.copy();

    force.sub(other.center);

    float r = max(center.dist(other.center), MIN_SIZE);

    force.normalize();

    float strength = (k * charge * other.charge)/pow(r, 2);

    force.mult(strength);

    return force;
  }

  PVector getElectricFieldForce(PVector field) // Calculates the force applied on an Orb by an electric field using an electric field coefficient as a parameter. Returns a PVector force
  {
    PVector force = (field.copy()).mult(charge);

    return force;
  }

  PVector getMagneticFieldForce(float b) // Calculates the force applied on an Orb by a magnetic field using a magnetic field coefficient as a parameter. Returns a PVector force
  {
    PVector force = new PVector(-charge * velocity.y * b, charge * velocity.x * b);

    return force;
  }

  void collide()
  {
    // NOTE: Assumes elastic collisions. Inelastic collision calculations are WEIRD.

    // Finds the nearest Orb
    Orb nearestOrb = new Orb(Float.MAX_VALUE, Float.MAX_VALUE, 0, 0, 0);

    for (int i = 0; i < orbs.length; i++)
    {
      if (orbs[i] != null && center.dist(orbs[i].center) < center.dist(nearestOrb.center) && orbs[i] != this)
      {
        nearestOrb = orbs[i];
      }
    }


    // Checks for overlapping of two Orbs and corrects if needed
    if (collisionCheck(nearestOrb))
    {
      float overlap = bsize/2 + nearestOrb.bsize/2 - center.dist(nearestOrb.center);

      if (overlap > 0)
      {
        PVector direction = new PVector(-(nearestOrb.center.x - center.x), -(nearestOrb.center.y - center.y));
        direction.normalize();

        direction.mult(overlap/2);

        center.add(direction);

        nearestOrb.center.sub(direction);
      }
    }


    // Checks for collisions and applies the collision formula depending on the result
    float velAngle = atan2(velocity.y, velocity.x); // for some dumbass reason the y-cors and x-cors in atan2 are flipped.
    float velAngleOther = atan2(nearestOrb.velocity.y, nearestOrb.velocity.x);
    float contactAngle = atan2(nearestOrb.center.y - center.y, nearestOrb.center.x - center.x);

    float velocityX;
    float velocityY;

    float otherVelX;
    float otherVelY;

    if (collisionCheck(nearestOrb))
    {
      velocityX = (((velocity.mag() * cos(velAngle - contactAngle) * (mass - nearestOrb.mass)) + (2 * nearestOrb.mass * nearestOrb.velocity.mag() * cos(velAngleOther - contactAngle)))/(mass + nearestOrb.mass)) * cos(contactAngle) + velocity.mag() * sin(velAngle - contactAngle) * cos(contactAngle + PI/2);
      velocityY = (((velocity.mag() * cos(velAngle - contactAngle) * (mass - nearestOrb.mass)) + (2 * nearestOrb.mass * nearestOrb.velocity.mag() * cos(velAngleOther - contactAngle)))/(mass + nearestOrb.mass)) * sin(contactAngle) + velocity.mag() * sin(velAngle - contactAngle) * sin(contactAngle + PI/2);

      otherVelX = (((nearestOrb.velocity.mag() * cos(velAngleOther - (contactAngle + PI)) * (nearestOrb.mass - mass)) + (2 * mass * velocity.mag() * cos(velAngle - (contactAngle + PI))))/(mass + nearestOrb.mass)) * cos(contactAngle + PI) + nearestOrb.velocity.mag() * sin(velAngleOther - (contactAngle + PI)) * cos(contactAngle + (3 * PI/2));
      otherVelY = (((nearestOrb.velocity.mag() * cos(velAngleOther - (contactAngle + PI)) * (nearestOrb.mass - mass)) + (2 * mass * velocity.mag() * cos(velAngle - (contactAngle + PI))))/(mass + nearestOrb.mass)) * sin(contactAngle + PI) + nearestOrb.velocity.mag() * sin(velAngleOther - (contactAngle + PI)) * sin(contactAngle + (3 * PI/2));


      nearestOrb.velocity = new PVector(otherVelX, otherVelY);
      velocity = new PVector(velocityX, velocityY);
    }
  }

  /**
   getSpring()
   
   This should calculate the force felt on the calling object by
   a spring between the calling object and other.
   
   The resulting force should pull the calling object towards
   other if the spring is extended past springLength and should
   push the calling object away from o if the spring is compressed
   to be less than springLength.
   
   F = kx (ABhat)
   k: Spring constant
   x: displacement, the difference of the distance
   between A and B and the length of the spring.
   (ABhat): The normalized vector from A to B
   */
  PVector getSpring(Orb other, int springLength, float springK)
  {
    PVector direction = new PVector(other.center.x - center.x, other.center.y - center.y);

    direction.normalize();
    float displacement = center.dist(other.center) - springLength;

    float mag = springK * displacement;

    direction.mult(mag);

    return direction;
  }//getSpring


  boolean yBounce() // Checks if the Orb has touched or somehow gone past the top and bottom boundaries of the window. Returns a boolean
  {
    if (center.y > height - bsize/2) {
      velocity.y *= -1;
      center.y = height - bsize/2;

      return true;
    }//bottom bounce
    else if (center.y < bsize/2) {
      velocity.y*= -1;
      center.y = bsize/2;
      return true;
    }
    return false;
  }//yBounce


  boolean xBounce() // Checks if the Orb has touched or somehow gone past the left and right boundaries of the window. Returns a boolean
  {
    if (center.x > width - bsize/2) {
      center.x = width - bsize/2;
      velocity.x *= -1;
      return true;
    } else if (center.x < bsize/2) {
      center.x = bsize/2;
      velocity.x *= -1;
      return true;
    }
    return false;
  }//xbounce


  boolean collisionCheck(Orb other) // Checks if two Orbs overlap. Returns a boolean
  {
    return ( this.center.dist(other.center)
      <= (this.bsize/2 + other.bsize/2) );
  }//collisionCheck


  void setColor() // Changes the color of an Orb
  {
    color c0 = color(0, 255, 255);
    color c1 = color(0);
    c = lerpColor(c0, c1, (mass-MIN_SIZE)/(MAX_MASS-MIN_SIZE)); // Calculates a color between the two specified colors, whose "closeness" to each color is determined by the third parameter.
  }//setColor


  // visual behavior
  void display()
  {
    noStroke();
    fill(c);
    circle(center.x, center.y, bsize);
    fill(0);
    //text(mass, center.x, center.y);


    textAlign(CENTER, CENTER);
    textSize(bsize);
    fill(255);
    if (charge > 0)
    {
      text("+", center.x, center.y);
    } else if (charge < 0)
    {
      text("-", center.x, center.y - 3);
    }
  }//display
}//Ball
