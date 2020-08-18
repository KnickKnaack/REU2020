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


  ;;1) use two breeds of robots: spiral-robots and DFS-robots
  ;add the spiral-robots breed here
breed [spiral-robots sprial-robot]
breed [DFS-robots DFS-robot]

  ;;DFS-robots breed



  ;;2) spiral-robots need to know:
spiral-robots-own[
    ;;counts the current number of steps the robot has taken
  stepCount

    ;;the maximum number of steps a robot can take before it turns
  maxStepCount

    ;;is the robot searching?
  searching?

    ;;is the robot returning?
  returning?
]


  ;;Updated from [Sw3] to be specific to DFS-robots.
  ;;DFS robots need to know:
  DFS-robots-own [
     ;;are they currently working with a list of rock locations? (in the processingList? state)
     processingList?

     ;;are they currently returning to the base? (in the returning? state)
     returning?

     ;;store a list of rocks we have seen
     ;;rockLocations is a list of lists: [ [a b] [c d]...[y z] ]
     rockLocations

     ;;target coordinate x
     locX

     ;;target coordinate y
     locY

     ;;what heading (direction they are facing in degrees) they start with
     initialHeading
    ]

  ;;patches need to know:
  patches-own [
     ;;base color before adding rocks
     baseColor
    ]

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

  ;;1) Create the number of spiral-robots based on the slider value.
  create-spiral-robots numberOfSpiralRobots[

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

    ;;Set their heading to who * 90--who is an integer that represents the robot's number.
    ;;So robots will start at (1 * 90) = 90 degrees, (2 * 90) = 180 degrees...etc.
    ;;This prevents the spirals from overlapping as much.
    set heading who * 90
  ]
  ;;Create the number of DFS-robots based on the slider value.
  create-DFS-robots numberOfDFSRobots[

    ;;Set their size to 5.
    set size 5

    ;;Set their shape to "robot".
    set shape "robot"

    ;;Set their color to blue.
    set color blue

    ;;Set processingList? to false.
    set processingList? false

    ;;Set returning? to false.
    set returning? false

    ;;Set rockLocations to an empty list.
    set rockLocations []

    ;;Set locX and locY to 0.
    set locX 0
    set locY 0

   ;;Set initialHeading to a random degree.
    set initialHeading random 360

    ;;Set the robot's heading to the value of initialHeading.
    set heading initialHeading

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

  ;;ask the DFS-robots to DFS.
  ask DFS-robots[DFS]

  ;;ask the spiral-robots to spiral.
  ask spiral-robots[spiral]

  ;; We can use 'turtles' to ask *all* agents to do something.
  ;; Ask the turtles
  ask turtles [
    ;; Use an ifelse statement.
    ;;If the pen-down? switch is on, put the pen down
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
;:::::::::::::::::::::::::::::    DFS ROBOT BEHAVIOR  :::::::::::::::::::::::::::::::
;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;
 ;;    DFS      ;; : MAIN PROCEDURE
 ;;;;;;;;;;;;;;;;;
 ;------------------------------------------------------------------------------------

to DFS

  ;;Put the exit condition first. Stop when no yellow patches (rocks) remain.
  if count patches with [pcolor = yellow] = 0 [stop]

  ;;All sub procedures called after this (set-direction, do-DFS, process-list) are within the ask robots block.
  ;;So, the procedures act as if they are already in ask robots.
  ;;That means that when you write the sub procedures, you don't need to repeat the ask robots command.

  ;;ask the DFS-robots
  ask DFS-robots[

   ;;If the robot can't move, it must've reached a boundary.
   if not can-move? 1[
     ;;Add the last rock to our list if we're standing on it by calling do-DFS.
     do-DFS

     ;;If there's anything in our list, turn on the processingList? status.
     ifelse not empty? rockLocations
     [set processingList? true]

     ;;else go home to reset our search angle.
     [set returning? true]
   ]

   ;;Main control of the procedure goes here in an ifelse statement.
   ;;Check if we are in the processing list state and not returning. If we are, then process the list.
   ;;(While we are processing, we'll also sometimes be in the returning? state
   ;;at the same time when we're dropping off rocks.
   ;;Robots should only process the list though when they're not dropping off a rock.
      if processingList? and not returning? [process-list]

   ;;If returning mode is on, the robots should return-to-base.
      if returning? [return-to-base]

   ;;Else, if the robots are not processing a list and not returning, they should do DFS.
      if not processingList? and not returning? [do-DFS]

  ]

end

;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;
 ;; process-list ;; : MAIN PROCEDURE
 ;;;;;;;;;;;;;;;;;;
;------------------------------------------------------------------------------------
to process-list

  ;;Control the robots based on the status of their internal list of rocks.
  ;;If the robot's list is not empty:
  ifelse not empty? rockLocations[

  ;;If locX and locY are set to 0, then we just started or we just dropped off a rock.
    if locX = 0 and locY = 0 [

    ;;If they are, then we need a new destination, so reset our target coordinates, locX and locY.
    ;;We'll write the code for that in a sub procedure, so just call the procedure for now.
      reset-target-coords
    ]

    ;;Now move-to-location of locX locY.
    ;;We'll write the code for that in a sub procedure, so just call the procedure for now.
    move-to-location
  ]

  ;;rockLocations is empty. We're done processing the list.
  [set processingList? false]

  ;;Go forward 1 step.
  fd 1

end

;------------------------------------------------------------------------------------
;;Reset the robot's target coordinates when they are still processing the list but
;;have just dropped off a rock and don't know where to go.
;;Recall that rockLocations is a list of lists: [ [a b] [c d]...[y z] ]
to reset-target-coords

  ;;if rockLocations is not empty
  if not empty? rockLocations[

       ;;Grab the first element of rockLocations, a list of 2 coordinates: [a b]
       let loc first rockLocations

       ;;Now set robots-own x to the first element of this [a _]
       set locX first loc

       ;;and robots-own y to the last. [_ b]
       set locY last loc

       ;;and keep everything but the first list of coords (the ones we just used)
       ;;in rockLocations. --> [ [c d]...[y z] ]
       set rockLocations but-first rockLocations
  ]

end
;------------------------------------------------------------------------------------

;;The robot arrived at its locX locY. Pick up the rock and set the robot's mode
;;to returning so it can drop off the rock. Remain in processing state so the robot goes
;;back to processing the list after dropping off the rock.
to move-to-location

  ;;If we've reached our target coordinates locX and locY,
  ifelse (pxcor = locX and pycor = locY)[

       ;; pick up the rock by setting the robot's shape to the one holding the rock,
       set shape "robot with rock"

       ;; and ask the patch-here to return to its base color.
       ask patch-here[ set pcolor baseColor]

       ;; Turn on returning? mode.
       set returning? true
  ]

  ;Else the robot has not arrived yet; face the target location.
  [facexy locX locY]

 end

;------------------------------------------------------------------------------------
 ;;We've used the return-to-base procedure many times.
 ;;This time, we'll make some changes to support list processing.
 to return-to-base

 ;; If we're at the origin, we found the base.
 ifelse pxcor = 0 and pycor = 0[

 ;; Change the robot's shape to the one without the rock.
   set shape "robot"

 ;; We've arrived, so turn off returning? mode.
   set returning? false

 ;; set locX
   set locX 0

 ;; and locY to 0. Robots will return to base if they don't find anything.
   set locY 0

  ;;Use an if statement. A robot can also be here if it has finished processing a list
  ;;of if it didn't find anything at the current angle and was sent back to base.
  ;;If this happened, change its heading so it searches in a different direction.
  ;;It will begin to search +searchAngle degrees from its last heading.
   if not processingList?[
     set initialHeading initialHeading + searchAngle
     set heading initialHeading
   ]
 ]

 ;; Else, we didn't find the origin yet--face the origin.
 [ facexy 0 0 ]

 ;; Go forward 1.
 fd 1

 end

;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;
 ;; do-DFS      ;; : MAIN PROCEDURE
 ;;;;;;;;;;;;;;;;;
 ;------------------------------------------------------------------------------------
;;Write the do-DFS procedure. do-DFS finds rocks and stores them in a list.
to do-DFS

  ;;ask the patch-here
  ask patch-here[

     ;;if its pcolor is yellow,
     if pcolor = yellow[

      ;;make a list of the coords of the rock we're on.
      let location (list pxcor pycor)

          ;;to add those coordinates to the front of their list of rocklocations and remove any duplicates.
         ask myself[ set rockLocations remove-duplicates (fput location rockLocations)]

     ]
  ]

  ;;Go forward 1.
  fd 1

end
