class FixedOrb extends Orb
{
  /**
   Constructs an object of class FixedOrb at a given position with a given size and mass.
   Used for setting explicit parameters of the object.
   */
  FixedOrb(float x, float y, float s, float m)
  {
    super(x, y, s, m, 0);
    c = color(255, 0, 0);
  }

  /**
   Constructs an object of class FixedOrb at a random position with a random size and mass.
   Sets default parameters of the object.
   */
  FixedOrb()
  {
    super();
    c = color(255, 0, 0);
  }

  /**
   Overloads the superclass Orb's move method such that when move() is called on this object, nothing happens.
   */
  void move(boolean bounce)
  {
    //do nothing
  }
}//fixedOrb
