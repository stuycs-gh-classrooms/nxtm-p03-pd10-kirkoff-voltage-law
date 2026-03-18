class FixedOrb extends Orb
{

  /**
   This constructor constructs an object of class FixedOrb at a given position with a given size and mass.
   This is used if you want to be deliberate in the parameters of the object.
   */
  FixedOrb(float x, float y, float s, float m)
  {
    super(x, y, s, m);
    c = color(255, 0, 0);
  }

  /**
   This constructor constructs an object of class FixedOrb at a random position with a random size and mass.
   This is used if you do not want to be deliberate in the parameters of the object.
   */
  FixedOrb()
  {
    super();
    c = color(255, 0, 0);
  }

  /**
   This method is to overwrite the superclass Orb's move method such that when move() is called on this object, nothing happens.
   */
  void move(boolean bounce)
  {
    //do nothing
  }
}//fixedOrb
