class Orb
{

  //instance variables
  PVector center;
  PVector velocity;
  PVector acceleration;
  float bsize;
  float mass;
  float charge;
  color c;


  /**
   This constructor constructs an object of class Orb at a random position with a random size and mass.
   This is used if you do not want to be deliberate in the parameters of the object.
   */
  Orb()
  {
    bsize = random(10, MAX_SIZE);
    float x = random(bsize/2, width-bsize/2);
    float y = random(bsize/2, height-bsize/2);
    charge = random(-0.001, 0.001);
    center = new PVector(x, y);
    mass = random(10, 100);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }


  /**
   This constructor constructs an object of class Orb at a given position with a given size and mass.
   This is used if you want to be deliberate in the parameters of the object.
   */
  Orb(float x, float y, float s, float m, float q)
  {
    bsize = s;
    mass = m;
    center = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    setColor();
  }


  /**
   This method is used to change the position of the object. It calculates bounces, applies accelerations and velocities, and resets acceleration after every frame.
   */
  void move(boolean bounce)
  {
    if (bounce) {
      xBounce();
      yBounce();
    }

    velocity.add(acceleration);
    center.add(velocity);
    acceleration.mult(0);
    
    if (bounce)
    {
      center.x = constrain(center.x, bsize/2 - 5, width - bsize/2 + 5);
      center.y = constrain(center.y, bsize/2 - 5, height - bsize/2 + 5);
    }
  }//move


  /**
   This method is used to apply a given force to the object using the relationship F=ma, applying a given acceleration depending on the force and mass.
   */
  void applyForce(PVector force)
  {
    PVector scaleForce = force.copy();
    scaleForce.div(mass);
    acceleration.add(scaleForce);
  }


  /**
   This method calculates a theoretical drag force being applied on an object at a given time with a given drag coefficient and velocity.
   */
  PVector getDragForce(float cd)
  {
    float dragMag = velocity.mag();
    dragMag = -0.5 * dragMag * dragMag * cd;
    PVector dragForce = velocity.copy();
    dragForce.normalize();
    dragForce.mult(dragMag);
    return dragForce;
  }


  /**
   This method calculates the force of gravity between the object and another object of class Orb with the other orb and the gravitational coefficient
   being provided as parameters, returning a PVector that represents a force.
   */
  PVector getGravity(Orb other, float G)
  {
    float strength = G * mass*other.mass;
    
    //dont want to divide by 0!
    float r = max(center.dist(other.center), MIN_SIZE);
    
    strength = strength/ pow(r, 2);
    PVector force = other.center.copy();
    force.sub(center);
    force.mult(strength);
    return force;
  }

  PVector getElectroStat(Orb other, float k)
  {
    
    //This subtraction appears reversed such that you can get the correct directions for the vectors.
    // You can check it yourself: In this scenario, the force vector starts out pointing away from the other orb.
    // This means that with two positive or two negative charges, the sign remains unchanged and you get repulsion (this lines up with reality)
    // With a + and a -, the sign is flipped and you get attraction.
    PVector force = center.copy();
    
    force.sub(other.center);
    
    float r = max(center.dist(other.center), MIN_SIZE);
    
    force.normalize();

    float strength = (k * charge * other.charge)/pow(r, 2);
    
    force.mult(strength);
    
    return force;
  }
  
  PVector getElectricFieldForce(PVector field)
  {
    PVector force = (field.copy()).mult(charge);
    
    return force;
  }
  
  PVector getMagneticFieldForce(float b)
  {
    PVector force = new PVector(-charge * velocity.y * b, charge * velocity.x * b);
    
    return force;
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


  /**
   This method checks whether or not the object overlaps with the top and bottom boundaries of the plane, and returns a boolean accordingly.
   This is used to calculate bounces in the vertical direction.
   */
  boolean yBounce()
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


  /**
   This method checks whether or not the object overlaps with the left and right boundaries of the plane, and returns a boolean accordingly.
   This is used to calculate bounces in the horizontal direction.
   */
  boolean xBounce()
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


  /**
   This method checks whether or not the object overlaps with another orb and returns a boolean accordingly.
   */
  boolean collisionCheck(Orb other)
  {
    return ( this.center.dist(other.center)
      <= (this.bsize/2 + other.bsize/2) );
  }//collisionCheck


  /**
   This method changes the color of the object.
   */
  void setColor()
  {
    color c0 = color(0, 255, 255);
    color c1 = color(0);
    /*
    lerpColor calculates a color between the two specified colors, whose "closeness" to each color inputted is determined by the third parameter.
     */
    c = lerpColor(c0, c1, (mass-MIN_SIZE)/(MAX_MASS-MIN_SIZE));
  }//setColor


  //visual behavior
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
    }
    else if (charge < 0)
    {
      text("-", center.x, center.y - 3);
    }
  }//display
}//Ball
