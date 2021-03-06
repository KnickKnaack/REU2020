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

  ;; used for finsing nearset neighbor to possibly deflect if closer than deflectionDistance
  nearest-neighbor

  ;; paramater for minimum distance of deflection between turtles

    ;;the maximum number of steps a robot can take before it turns
  maxStepCount

    ;;is the robot searching?
  searching?

    ;;is the robot returning?
  returning?

  inCollision?

  hasIce?

  hasMetal?

  hasRock?

]


  ;

  ;;patches need to know:
  patches-own [
     ;;base color before adding rocks
     baseColor
    ]

  ;;global variables
globals[
 collisions
 rocksCollected
 iceChance
 metalChance
 rockChance
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

  set collisions 0
  set rocksCollected 0
  set iceChance Ice_InitialPercentChance / 100
  set metalChance Metal_InitialPercentChance / 100
  set rockChance Rock_InitialPercentChance / 100

  ;setup calls these three sub procedures.
  ask patches [ set baseColor pcolor]
  make-robots
  make-resources
  make-base
end

;This sub procedure has been completed for you.
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
to make-resources

   if distribution = "cross" or distribution = "random + cross" or distribution = "large clusters + cross"
   or distribution = "clusters + cross" or distribution = "random + clusters + cross"
   or distribution = "random + clusters + large clusters + cross"[make-cross]

   if distribution = "random" or distribution = "random + cross" or distribution = "random + clusters"
   or distribution = "random + large clusters" or distribution = "random + clusters + cross"
   or distribution = "random + clusters + large clusters + cross" or distribution = "random + clusters + large clusters" [make-random make-random-i make-random-m]

   if distribution = "clusters" or distribution = "clusters + cross" or distribution = "random + clusters"
   or distribution = "clusters + large clusters" or distribution = "random + clusters + cross"
   or distribution = "random + clusters + large clusters + cross" or distribution = "random + clusters + large clusters" [make-clusters make-clusters-i make-clusters-m]


   if distribution = "large clusters" or distribution = "large clusters + cross"
   or distribution = "random + large clusters"  or distribution = "clusters + large clusters"
   or distribution = "random + clusters + large clusters + cross" or distribution = "random + clusters + large clusters" [make-large-clusters make-large-clusters-i make-large-clusters-m]

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

      set inCollision? false

      set hasIce? false

      set hasMetal? false

      set hasRock? false

      ;; all face a certain direction
      facexy 0 1

      ;;turn a distributed amount of degrees
      left spread * robotCount

      ;;move forward in accordance with the amount of robots so that they do not collide
      fd numberOfSpiralRobots * 1.1
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

to make-random-i
   let targetPatches singleRocks
     while [targetPatches > 0][
       ask one-of patches[
         if pcolor != yellow and pcolor != blue and pcolor != orange - 1[
           set pcolor blue
           set targetPatches targetPatches - 1
         ]
       ]
     ]
end

to make-random-m
   let targetPatches singleRocks
     while [targetPatches > 0][
       ask one-of patches[
         if pcolor != yellow and pcolor != blue and pcolor != orange - 1[
           set pcolor orange - 1
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

to make-clusters-i
   let targetClusters clusterRocks
     while [targetClusters > 0][
       ask one-of patches[
           if pcolor != yellow and [pcolor] of neighbors4 != yellow and
      pcolor != blue and [pcolor] of neighbors4 != blue and
      pcolor != orange - 1 and [pcolor] of neighbors4 != orange - 1 [

           set pcolor blue
           ask neighbors4[ set pcolor blue ]
           set targetClusters targetClusters - 1
         ]
       ]
     ]
end

to make-clusters-m
   let targetClusters clusterRocks
     while [targetClusters > 0][
       ask one-of patches[
           if pcolor != yellow and [pcolor] of neighbors4 != yellow and
      pcolor != blue and [pcolor] of neighbors4 != blue and
      pcolor != orange - 1 and [pcolor] of neighbors4 != orange - 1 [

           set pcolor orange - 1
           ask neighbors4[ set pcolor orange - 1 ]
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
       if pcolor != yellow and [pcolor] of (patches in-radius 3) != yellow and
      pcolor != blue and [pcolor] of patches in-radius 3 != blue and
      pcolor != orange - 1 and [pcolor] of patches in-radius 3 != (orange - 1) [
         set pcolor yellow
         ask patches in-radius 3 [set pcolor yellow]
         set targetLargeClusters targetLargeClusters - 1
       ]
     ]
     ]
end

to make-large-clusters-i
   let targetLargeClusters largeClusterRocks
   while [targetLargeClusters > 0][
     ask one-of patches[
      if pcolor != yellow and [pcolor] of (patches in-radius 3) != yellow and
      pcolor != blue and [pcolor] of patches in-radius 3 != blue and
      pcolor != orange - 1 and [pcolor] of patches in-radius 3 != (orange - 1) [

         set pcolor blue
         ask patches in-radius 3 [set pcolor blue]
         set targetLargeClusters targetLargeClusters - 1
       ]
     ]
     ]
end

to make-large-clusters-m
   let targetLargeClusters largeClusterRocks
   while [targetLargeClusters > 0][
     ask one-of patches[
      if pcolor != yellow and [pcolor] of (patches in-radius 3) != yellow and
      pcolor != blue and [pcolor] of patches in-radius 3 != blue and
      pcolor != orange - 1 and [pcolor] of patches in-radius 3 != (orange - 1) [

         set pcolor orange - 1
         ask patches in-radius 3 [set pcolor orange - 1]
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

  ;; We can use 'turtles' to ask *all* agents to do something.
  ;; Ask the turtles
  ask spiral-robots [

    find-nearest-neigbor



    ifelse (returning?) [
      ifelse ( (distance nearest-neighbor <= waitDistance) and ([returning?] of nearest-neighbor) and (distancexy 0 0 > ([distancexy 0 0] of nearest-neighbor)) ) [

      ]
      [spiral]
    ]


    [
      ifelse ( (distance nearest-neighbor <= deflectionDistance))
      [bubble-deflect] ;; intended behavior: if agent detects a collision, it will deflect from the heading of the nearest neighbor
                       ;; need to change parameters of both functions in line above to destinguish what is cosidered a 'collision' vs possible collision (that will be deflected)
      [spiral]
    ]






    ;; Use an ifelse statement.
    ;;If the pen-down? switch is on, put the pen down



    ifelse pen-down?
    [pen-down]

    ;;Else take the pen up.
    [pen-up]
  ]

  check-collisions

   tick ;;tick must be called from observer context, move into main procedure.
end


;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;    check-collisions     ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-collisions

  ask turtles [

    if (inCollision? and (distance nearest-neighbor > collisionDistance)) [
      set inCollision? false
    ]

    if (not inCollision? and (distance nearest-neighbor <= collisionDistance)) [
      set collisions collisions + 0.5
      set inCollision? true
    ]

  ]
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
      look-for-resources

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

 to look-for-resources
   ;;Ask the 8 patches around the robot (neighbors)
  ask neighbors [
     ;;if the patch color is yellow,
     if (random-float 1 < rockChance) [
    if pcolor = yellow [

     ;;  Change the patch color back to its original color.
      set pcolor baseColor

      set rocksCollected rocksCollected + 1

       ;; The robot asks itself to:
      ask myself [

         ;; Turn off searching?,
        set searching? false

         ;; Turn on returning?,
        set returning? true

        set hasRock? true

         ;; and set its shape to the one holding the rock.
        set shape "robot with rock"
      ]
    ]
    ]

    ;; ice nodes
    if (random-float 1 < iceChance) [
    if pcolor = blue [

     ;;  Change the patch color back to its original color.
      set pcolor baseColor

       ;; The robot asks itself to:
      ask myself [

         ;; Turn off searching?,
        set searching? false

         ;; Turn on returning?,
        set returning? true

        set hasIce? true

         ;; and set its shape to the one holding the rock.
        set shape "robot with rock"
      ]
    ]
    ]


    ;; metal nodes
    if (random-float 1 < metalChance) [
    if pcolor = orange - 1 [

     ;;  Change the patch color back to its original color.
      set pcolor baseColor

       ;; The robot asks itself to:
      ask myself [

         ;; Turn off searching?,
        set searching? false

         ;; Turn on returning?,
        set returning? true

        set hasMetal? true

         ;; and set its shape to the one holding the rock.
        set shape "robot with rock"
      ]
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

    change-priorities

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
 ;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;  change-priorities   ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;


to change-priorities
  ;;robots with ice
  ifelse (hasIce?) [
    set iceChance iceChance - (Ice_PercentDegradePerCollection / 100)
    set metalChance metalChance + (Metal_PercentIncreasePerOtherCollection / 100)
    set rockChance rockChance + (Rock_PercentIncreasePerOtherCollection / 100)

    set hasIce? false
  ]

  ;;robots with meatal
  [ifelse (hasmetal?) [
    set iceChance iceChance + (Ice_PercentIncreasePerOtherCollection / 100)
    set metalChance metalChance - (Metal_PercentDegradePerCollection / 100)
    set rockChance rockChance + (Rock_PercentIncreasePerOtherCollection / 100)

    set hasIce? false
  ]

  ;;robots with rock
  [if (hasRock?) [
    set iceChance iceChance + (Ice_PercentIncreasePerOtherCollection / 100)
    set metalChance metalChance + (Metal_PercentIncreasePerOtherCollection / 100)
    set rockChance rockChance - (Rock_PercentDegradePerCollection / 100)

    set hasIce? false
  ]]]

end


;------------------------------------------------------------------------------------
 ;;;;;;;;;;;;;;;;;;;;;;
 ;; bubble-deflect   ;;
 ;;;;;;;;;;;;;;;;;;;;;;


;; "bubble" because we're constantly keeping track of the nearest neighbor within the deflection radius of each agent
;; to allow for time to react and deflect before a collision is counted

to bubble-deflect
  turn-a(nearest-neighbor) max-deflection-turn
  fd 1
end

;------------------------------------------------------------------------------------

;; HELPER FUNCTIONS ;;

;; best to set max-turn to within the range of 125-155 degrees [right/away] which works best with spiral search
to turn-a [neighbor max-turn]
  set heading towards neighbor
  rt max-turn
end


to find-nearest-neigbor
  ;; max of the nearest two turtles (one of them is itself)
  set nearest-neighbor min-one-of other turtles [distance myself]
end
@#$#@#$#@
GRAPHICS-WINDOW
235
13
748
527
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-50
50
-50
50
1
1
1
ticks
5.0

BUTTON
13
10
80
44
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
89
11
207
45
robot-control
robot-control
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
15
60
129
105
rocks remaining
count patches with [pcolor = yellow]
17
1
11

CHOOSER
17
148
225
193
distribution
distribution
"cross" "random" "clusters" "large clusters" "random + cross" "clusters + cross" "clusters + large clusters" "large clusters + cross" "random + clusters" "random + clusters + large clusters" "random + large clusters" "random + clusters + cross" "random + clusters + large clusters + cross"
9

SLIDER
17
199
189
232
singleRocks
singleRocks
0
100
5.0
5
1
NIL
HORIZONTAL

SLIDER
17
237
189
270
clusterRocks
clusterRocks
0
50
10.0
5
1
NIL
HORIZONTAL

SLIDER
15
347
188
380
numberOfSpiralRobots
numberOfSpiralRobots
0
10
6.0
1
1
NIL
HORIZONTAL

SWITCH
17
109
129
142
pen-down?
pen-down?
1
1
-1000

SLIDER
16
390
188
423
turnAngle
turnAngle
0
90
15.0
1
1
NIL
HORIZONTAL

TEXTBOX
15
330
165
348
sliders for spiral-robots
11
0.0
1

SLIDER
17
282
189
315
largeClusterRocks
largeClusterRocks
0
20
2.0
1
1
NIL
HORIZONTAL

SLIDER
16
536
251
569
max-deflection-turn
max-deflection-turn
45
180
120.0
5
1
Degrees
HORIZONTAL

SLIDER
12
579
184
612
collisionDistance
collisionDistance
0
15
6.0
1
1
NIL
HORIZONTAL

MONITOR
12
632
72
677
NIL
collisions
17
1
11

SLIDER
16
494
188
527
deflectionDistance
deflectionDistance
0
15
12.0
1
1
NIL
HORIZONTAL

TEXTBOX
27
478
177
496
Collision Avoidance
11
0.0
1

SLIDER
12
691
184
724
waitDistance
waitDistance
5
20
17.0
1
1
NIL
HORIZONTAL

MONITOR
93
634
186
679
NIL
rocksCollected
17
1
11

SLIDER
796
47
984
80
Ice_InitialPercentChance
Ice_InitialPercentChance
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
794
95
995
128
Metal_InitialPercentChance
Metal_InitialPercentChance
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
793
146
990
179
Rock_InitialPercentChance
Rock_InitialPercentChance
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
790
233
1030
266
Ice_PercentDegradePerCollection
Ice_PercentDegradePerCollection
0
10
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
789
280
1041
313
Metal_PercentDegradePerCollection
Metal_PercentDegradePerCollection
0
10
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
789
327
1038
360
Rock_PercentDegradePerCollection
Rock_PercentDegradePerCollection
0
10
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
785
408
1058
441
Ice_PercentIncreasePerOtherCollection
Ice_PercentIncreasePerOtherCollection
0
5
1.01
0.01
1
NIL
HORIZONTAL

SLIDER
785
455
1071
488
Metal_PercentIncreasePerOtherCollection
Metal_PercentIncreasePerOtherCollection
0
10
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
784
502
1066
535
Rock_PercentIncreasePerOtherCollection
Rock_PercentIncreasePerOtherCollection
0
10
0.1
0.1
1
NIL
HORIZONTAL

MONITOR
801
567
879
612
NIL
rockChance
3
1
11

MONITOR
891
565
976
610
NIL
metalChance
3
1
11

MONITOR
983
563
1053
608
NIL
iceChance
3
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

robot
true
1
Polygon -16777216 true false 75 60 105 15 135 15 90 75 75 60
Polygon -16777216 true false 225 60 195 15 165 15 210 75 225 60
Rectangle -16777216 true false 30 105 75 165
Rectangle -16777216 true false 30 210 75 270
Rectangle -16777216 true false 75 120 225 255
Rectangle -16777216 true false 225 210 270 270
Rectangle -16777216 true false 225 105 270 165
Rectangle -16777216 true false 90 120 210 195
Rectangle -2674135 true true 120 120 180 240
Rectangle -16777216 true false 195 225 210 240
Rectangle -16777216 true false 120 60 180 90
Rectangle -16777216 true false 135 90 165 120
Polygon -2674135 true true 180 75 210 90 210 105 180 90 180 75
Polygon -2674135 true true 120 75 90 90 90 105 120 90 120 75
Rectangle -7500403 true false 75 105 225 120
Line -2674135 true 90 120 90 240
Line -2674135 true 210 120 210 240
Line -2674135 true 135 90 165 90
Line -16777216 false 75 165 225 165
Line -16777216 false 75 180 225 180
Rectangle -7500403 true false 75 240 225 255

robot with rock
true
1
Rectangle -1184463 true false 120 0 180 45
Polygon -16777216 true false 75 60 105 15 135 15 90 75 75 60
Polygon -16777216 true false 225 60 195 15 165 15 210 75 225 60
Rectangle -16777216 true false 30 105 75 165
Rectangle -16777216 true false 30 210 75 270
Rectangle -16777216 true false 75 120 225 255
Rectangle -16777216 true false 225 210 270 270
Rectangle -16777216 true false 225 105 270 165
Rectangle -16777216 true false 90 120 210 195
Rectangle -2674135 true true 120 120 180 240
Rectangle -16777216 true false 120 60 180 90
Rectangle -16777216 true false 135 90 165 120
Polygon -2674135 true true 180 75 210 90 210 105 180 90 180 75
Polygon -2674135 true true 120 75 90 90 90 105 120 90 120 75
Rectangle -7500403 true false 75 105 225 120
Line -2674135 true 75 240 225 240
Line -2674135 true 90 120 90 240
Line -2674135 true 210 120 210 240
Line -2674135 true 135 90 165 90
Line -16777216 false 75 165 225 165
Line -16777216 false 75 180 225 180
Rectangle -7500403 true false 75 240 225 255

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
