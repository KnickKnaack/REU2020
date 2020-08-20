 ;----------------------------------------------------------------------------------------------

 ;; Elizabeth E. Esterly
 ;; elizabeth@cs.unm.edu
 ;; The University of New Mexico
 ;; Swarmathon 4: Advanced Deterministic Search
 ;; version 1.0
 ;; Last Revision 01/18/2017
 ;; spiral-robots based on a program by Antonio Griego
 ;; deano505@unm.edu

 ;;Use the bitmap extension.
 extensions[bitmap]


  ;;1) use breed of robots: spiral-robots

breed [spiral-robots sprial-robot]



  ;;2) spiral-robots need to know:
spiral-robots-own[
    ;;counts the current number of steps the robot has taken
  stepCount
  
  ;; radius of each agent's view to dectect other objects/agents
  vision
  
  ;; used for finsing nearset neighbor to possibly deflect if closer than deflectionDistance
  nearest-neighbor
  
  ;; paramater for minimum distance of deflection between turtles 
  deflectionDistance

    ;;the maximum number of steps a robot can take before it turns
  maxStepCount

    ;;is the robot searching?
  searching?

    ;;is the robot returning?
  returning?
  
  
]


  ;

  ;;patches need to know:
  patches-own [
     ;;base color before adding rocks
     baseColor
    ]

  ;;global variables





;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;
 ;;    setup     ;; : MAIN PROCEDURE
 ;;;;;;;;;;;;;;;;;;
 ;------------------------------------------------------------------------------------
;Organize the code into main procedures and sub procedures.
to setup
  ca ;clear all
  cp ;clear patches
  bitmap:copy-to-pcolors bitmap:import "parkingLot.jpg" true
  reset-ticks ;keep track of simulation runtime


  ;setup calls these three sub procedures.
  make-robots
  make-rocks
  make-base
end

;This sub procedure has been completed for you.
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
to make-rocks
   ask patches [ set baseColor pcolor]

   if distribution = "cross" or distribution = "random + cross" or distribution = "large clusters + cross"
   or distribution = "clusters + cross" or distribution = "random + clusters + cross"
   or distribution = "random + clusters + large clusters + cross"[make-cross]

   if distribution = "random" or distribution = "random + cross" or distribution = "random + clusters"
   or distribution = "random + large clusters" or distribution = "random + clusters + cross"
   or distribution = "random + clusters + large clusters + cross" [make-random]

   if distribution = "clusters" or distribution = "clusters + cross" or distribution = "random + clusters"
   or distribution = "clusters + large clusters" or distribution = "random + clusters + cross"
   or distribution = "random + clusters + large clusters + cross" [make-clusters]


   if distribution = "large clusters" or distribution = "large clusters + cross"
   or distribution = "random + large clusters"  or distribution = "clusters + large clusters"
   or distribution = "random + clusters + large clusters + cross" [make-large-clusters]

end

;Fill in the next sub procedure.
;------------------------------------------------------------------------------------
;; Create the number of spiral-robots equal to the value of the numberOfSpiralRobots slider.
;; Set their properties and their variables that you defined previously.
;; The create block for DFS-robots is identical to the code used for creating the
;; robots ins Swarmathon 3.
to make-robots


  let robotCount numberOfSpiralRobots - 1
  let spread 360 / numberOfSpiralRobots
  while [robotCount >= 0] [

    ;;1) Create the number of spiral-robots based on the slider value.
    create-spiral-robots 1[

      ;;Set their size to 5.
      set size 5

      ;;Set their shape to "robot".
      set shape "robot"

      ;;Set their color to a color other than blue.
      set color (green + 4)

      ;;Set maxStepCount to 0.
      set maxStepCount 0

      ;;Set stepCount to 0.
      set stepCount 0

      ;;Set searching? to true.
      set searching? true

      ;;Set returning? to false.
      set returning? false

      ;; all face a certain direction
      facexy 0 1

      ;;turn a distributed amount of degrees
      left spread * robotCount

      ;;move forward in accordance with the amount of robots so that they do not collide
      fd numberOfRobots * 1.1
    ]
   ;;Move to next robots
   set robotCount robotCount - 1
  ]


end

;------------------------------------------------------------------------------------
;;Place rocks in a cross formation.
to make-cross
  ask patches [
    ;;Set up the cross by taking the max coordinate value, doubling it, then only setting a rock if the
    ;;x or y coord is evenly divisible by that value.
    ;;NOTE: This technique assumes a square layout.
    let doublemax max-pxcor * 2
    if pxcor mod doublemax = 0 or pycor mod doublemax = 0 [ set pcolor yellow ]
  ]
end

;------------------------------------------------------------------------------------
;;Place rocks randomly.
to make-random
   let targetPatches singleRocks
     while [targetPatches > 0][
       ask one-of patches[
         if pcolor != yellow[
           set pcolor yellow
           set targetPatches targetPatches - 1
         ]
       ]
     ]
end

;------------------------------------------------------------------------------------
;;Place rocks in clusters.
to make-clusters
   let targetClusters clusterRocks
     while [targetClusters > 0][
       ask one-of patches[
         if pcolor != yellow and [pcolor] of neighbors4 != yellow[
           set pcolor yellow
           ask neighbors4[ set pcolor yellow ]
           set targetClusters targetClusters - 1
         ]
       ]
     ]
end

;------------------------------------------------------------------------------------
;;Place rocks in large clusters.
to make-large-clusters
   let targetLargeClusters largeClusterRocks
   while [targetLargeClusters > 0][
     ask one-of patches[
       if pcolor != yellow and [pcolor] of patches in-radius 3 != yellow[
         set pcolor yellow
         ask patches in-radius 3 [set pcolor yellow]
         set targetLargeClusters targetLargeClusters - 1
       ]
     ]
     ]
end

;------------------------------------------------------------------------------------
;Make a base at the origin.
to make-base
  ask patches[
    if distancexy 0 0 < 4 [set pcolor green]
  ]

end
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;    ROBOT CONTROL    ;; : MAIN PROCEDURE
 ;;;;;;;;;;;;;;;;;;;;;;;;;
 ;------------------------------------------------------------------------------------
 ;;1) Finish the robot-control procedure. The different breeds of robots will perform
 ;; different behaviors.

to robot-control

  ;;ask the spiral-robots to spiral.
  ask spiral-robots[spiral]

  ;; We can use 'turtles' to ask *all* agents to do something.
  ;; Ask the turtles
  ask turtles [
    ;; Use an ifelse statement.
    ;;If the pen-down? switch is on, put the pen down
    
    if inCollision? [bubble-deflect]   ;; intended behavior: if agent detects a collision, it will deflect from the heading of the nearest neighbor
      ;; need to change parameters of both functions in line above to destinguish what is cosidered a 'collision' vs possible collision (that will be deflected)
    
    
    ifelse pen-down?
    [pen-down]

    ;;Else take the pen up.
    [pen-up]
  ]
   tick ;;tick must be called from observer context, move into main procedure.
end


;------------------------------------------------------------------------------------
;:::::::::::::::::::::::::::::   SPIRAL ROBOT BEHAVIOR  :::::::::::::::::::::::::::::
;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;;
 ;;    spiral     ;; : MAIN PROCEDURE
 ;;;;;;;;;;;;;;;;;;;
 ;------------------------------------------------------------------------------------
;;1) Write the spiral procedure.
 to spiral

   ;;If the robots can't move, they've hit the edge. They need to go back to the base and start a new spiral.
   ;;Also reset their variables so they can start over.
  if not can-move? 1 [

   ;;Set returning? to true to get them to go back to the base.
    set returning? true

   ;;Set stepCount and maxStepCount back to 0.
    set stepCount 0
    set maxStepCount 0
  ]
 ;;If they are returning? they should do the return-to-base-spiral procedure.
    if returning? [return-to-base-spiral]

 ;;The following code makes a spiral.
 ;;The robot increases the distance it travels in a line
 ;;before making a left turn.

 ;;if the robot's stepCount is greater than 0,
    ifelse stepCount > 0 [

   ;;if the robot is searching?
    if searching?[

     ;;Go forward 1.
      fd 1

     ;;look-for rocks,
      look-for-rocks

     ;;then reduce stepCount by 1.
      set stepCount stepCount - 1
  ]
  ]
 ;Else, no steps remain.
[
   ;; the robot should turn left based on the value of turnAngle,
    left turnAngle

   ;;increase the maxStepCount by 1,
    set maxStepCount maxStepCount + 1

   ;;then set the value of stepCount to the value of maxStepCount.
    set stepCount maxStepCount
  ]

 end

 ;Fill in the next two sub procedures.
 ;------------------------------------------------------------------------------------
 ;;1) Write look-for-rocks the same way you did for Swarmathon 1 (before site fidelity).

 to look-for-rocks
   ;;Ask the 8 patches around the robot (neighbors)
  ask neighbors [
     ;;if the patch color is yellow,
    if pcolor = yellow [

     ;;  Change the patch color back to its original color.
      set pcolor baseColor

       ;; The robot asks itself to:
      ask myself [

         ;; Turn off searching?,
        set searching? false

         ;; Turn on returning?,
        set returning? true

         ;; and set its shape to the one holding the rock.
        set shape "robot with rock"
      ]
    ]
  ]
 end

 ;------------------------------------------------------------------------------------
 ;;2) Write return-to-base-spiral.
 ;; We want to make a separate procedure for returning for the spiraling robots.
 ;; This is largely a design decision. We could add modify our existing DFS
 ;; return-to-base procedure to make it work for spiral robots, but this way we can keep the
 ;; code for both completely separate, whch makes it easier to read (and troubleshoot!).
 ;; return-to-base-spiral is much like return-to-base from Swarmathon 1,
 ;; but with the condition that the robot sets its heading to one of the cardinal
 ;; directions upon returning home.

 to return-to-base-spiral

   ; If we've reached the origin, we're at the base.
  ifelse pxcor = 0 and pycor = 0 [

     ;;set searching? to true,
    set searching? true

     ;set returning? to false,
    set returning? false

     ;set its shape to the robot without the rock
    set shape "robot"

     ;;choose a cardinal direction for the robot.
    set heading who * 90
  ]
   ;;Else we're not at the origin/base yet--face it.
  [facexy 0 0]
   ;;Go forward 1.
  fd 1
 end

;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;;;;;
 ;;  safety-bubble   ;;
 ;;;;;;;;;;;;;;;;;;;;;;


to safety-bubble
  ;; check if not in collision and if the nearest turtle is within deflection distance
  ask turtles [
    if( not inCollision? and (distance max-one-of (min-n-of 2 turtles [distance myself]) [distance myself] <= deflectionDistance))
    [bubble-deflect] ;;form of collision avoidance
  ]
end


;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;;;;;
 ;; bubble-deflect   ;;
 ;;;;;;;;;;;;;;;;;;;;;;


;; "bubble" because we're constantly keeping track of the nearest neighbor within the 'vision' of each agent
;; to allow for time to react and deflect
;; CON: only cosiders 1 neighbor at a time, not the heading of multiple other turtles per tick(might cause problems for for start of simulation)

to bubble-deflect
  turn-away([heading] of nearest-neighbor) max-deflection-turn 
end

;------------------------------------------------------------------------------------

;; HELPER FUNCTIONS ;;

to turn-away [new-heading max-turn]
  turn-at-most (subtract-headings heading new-heading) max-turn
end

to turn-at-most [turn max-turn]
  ifelse abs turn > 0
  [ifelse turn > 0
    [ rt max-turn ]
    [lt max-turn] ]
  [rt turn]

end

to find-nearest-neigbor
  ;; max of the nearest two turtles (one of them is itself) 
  set nearest-neighbor max-one-of (min-n-of 2 turtles [distance myself]) [distance myself] 
end

