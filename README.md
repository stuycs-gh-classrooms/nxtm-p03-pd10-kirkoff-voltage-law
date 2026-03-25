[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/-jWdCFXs)
## Project 00
### NeXTCS
### Period: 10
## Thinker0: Justin Luo
## Thinker1: Nathaniel Moy
## Thinker2: Jed Sloam
---

This project will be completed in phases. The first phase will be to work on this document. Use github-flavoured markdown. (For more markdown help [click here](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) or [here](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) )

All projects will require the following:
- Researching new forces to implement.
- Method for each new force, returning a `PVector`  -- similar to `getGravity` and `getSpring` (using whatever parameters are necessary).
- A distinct demonstration for each individual force (including gravity and the spring force).
- A visual menu at the top providing information about which simulation is currently active and indicating whether movement is on or off.
- The ability to toggle movement on/off
- The ability to toggle bouncing on/off
- The user should be able to switch _between_ simluations using the number keys as follows:
  - `1`: Gravity
  - `2`: Spring Force
  - `3`: Drag
  - `4`: Custom Force
  - `5`: Combination


## Phase 0: Force Selection, Analysis & Plan
---------- 

#### Custom Force: electrostatic force

### Custom Force Formula
What is the formula for your force? Including descriptions/definitions for the symbols. (You may include a picture of the formula if it is not easily typed.)

ELECTROSTATIC FORCE BETWEEN TWO POINT CHARGES

$F = \frac{kq_1q_2}{r^2}$

### Custom Force Breakdown
- What information that is already present in the `Orb` or `OrbNode` classes does this force use?
  - center pvectors

- Does this force require any new constants, if so what are they and what values will you try initially?
  - k (Coulomb constant), electrostatic constant

- Does this force require any new information to be added to the `Orb` class? If so, what is it and what data type will you use?
  - charge, type int

- Does this force interact with other `Orbs`, or is it applied based on the environment?
  - This force interacts with other Orbs.

- In order to calculate this force, do you need to perform extra intermediary calculations? If so, what?
  - Extra intermediary calculations are not needed.

---

### Custom Force Formula
What is the formula for your force? Including descriptions/definitions for the symbols. (You may include a picture of the formula if it is not easily typed.)

MAGNETIC FORCE OF A POINT IN A MAGNETIC FIELD

$F = q\vec{v} \times \vec{B}$

### Custom Force Breakdown
- What information that is already present in the `Orb` or `OrbNode` classes does this force use?
  - center pvectors
  - velocity
  - charge

- Does this force require any new constants, if so what are they and what values will you try initially?
  - magnetic field strength

- Does this force require any new information to be added to the `Orb` class? If so, what is it and what data type will you use?
  - charge, type int

- Does this force interact with other `Orbs`, or is it applied based on the environment?
  - This force interacts with other Orbs.

- In order to calculate this force, do you need to perform extra intermediary calculations? If so, what?
  - Cross product between two vectors is needed.

---

### Simulation 1: Gravity
Describe how you will attempt to simulate orbital motion.

Using the formula $\frac{Gm_1m_2}{r^2}$ to represent gravity and with a sufficient tangential speed to a fixed mass, a given mass can enter into orbit.

--- 

### Simulation 2: Spring
Describe what your spring simulation will look like. Explain how it will be setup, and how it should behave while running.

A simple fixed orb at the center of the screen (0 mass) with an orb hanging from it through a "spring" with another orb hanging from that orb with a "spring". You will get chaos with a double pendulum.

--- 

### Simulation 3: Drag
Describe what your drag simulation will look like. Explain how it will be setup, and how it should behave while running.

There will be three sections, air, water, and honey. The air will have little to no drag as calculated by air resistance. Water and honey will have progressively higher amounts of drag.

--- 

### Simulation 4: Electrostatic force
Describe what your Custom force simulation will look like. Explain how it will be setup, and how it should behave while running.

Arranges multiple charged and neutral orbs in a line. The negatively charged Orbs will be attracted to the positively charged Orbs, and Orbs with the same charge will be repelled from each other. Neutral Orbs will not be affected.

--- 


--- 

### Simulation 5: Electric field force
Describe what your electric field simulation will look like. Explain how it will be setup, and how it should behave while running.

Have an electric field pointing vertically. Positive orbs will be attracted towards the top of the window, negative orbs will be attracted towards the bottom of the window.

--- 


--- 

### Simulation 6: Magnetic field force
Describe what your magnetic field simulation will look like. Explain how it will be setup, and how it should behave while running.

Place three orbs arranged at the left side of the screen with a base velocity that is pointing to the right of the window. The uppermost Orb is negatively charged, the middle Orb is neutral, and the bottommost Orb is positively charged. The uppermost Orb will initially curve up, the neutral Orb will not curve at all, and the bottommost Orb will initially curve down.

--- 

### Simulation 7: Combination
Describe what your combination simulation will look like. Explain how it will be setup, and how it should behave while running.

Randomly arranged balls across the screen with the two halves of the screen separated for the drag force. In addition, collisions!

<img width="710" height="113" alt="image" src="https://github.com/user-attachments/assets/3ebf4db4-a0b6-4e06-a232-fb9e3dc67546" />


