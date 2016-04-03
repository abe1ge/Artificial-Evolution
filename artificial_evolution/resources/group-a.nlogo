;;imports

extensions [ table sock2 ]
__includes [ "sxl-utils.nls" ]

;;animals


;turtles-own [ID name speed total_energy eats ]

patches-own [regrowth-time]

;;set up globals
globals
[
  grid-x-inc                      ;; the amount of patches in between two roads in the x direction
  grid-y-inc                      ;; the amount of patches in between two roads in the y direction
  road                            ;; agentset containing the patches that are roads
  road-color
]

;================================================================================================================================================================
; Setup Procedures
;================================================================================================================================================================



;; Initialize the display by giving the global and patch variables initial values.
;; be created per road patch. Set up the plots.
to setup
  clear-all

  setup-globals
  setup-patches

  setup-rabbits

  reset-ticks
end

;=========================================================================
; Globals and Patches
;=========================================================================

;; Initialize the global variables to appropriate values
to setup-globals

  set grid-x-inc world-width  / grid-size-x
  set grid-y-inc world-height / grid-size-y

end


;; Make the patches have appropriate colors, set up the roads
to setup-patches
  ask patches
  [
    set pcolor green
    set regrowth-time 0
    set road-color white
  ]


  ;; initialize the global variables that hold patch agentsets
  set road patches with
    [(floor((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0) or
      (floor((pycor + max-pycor) mod grid-y-inc) = 0)]


  ask road [ set pcolor road-color ]

end
;=========================================================================
; Turtles
;=========================================================================

breed [rabbits rabbit]

rabbits-own [id energy age max-age speed energy-given eats]

to setup-rabbits1 [#id #speed #color]
  create-rabbits 1
  [
    set id #id
    set eats (list "grass")
    set color #color
    setxy random-xcor random-ycor
    set shape "default"
    set max-age 150
    set age 0
    set energy 150
    set speed #speed
  ]
end


to setup-rabbits
  create-rabbits num-of-rabbits
  ask rabbits
  [
    set eats (list "grass")
    set color blue
    setxy random-xcor random-ycor
    set shape "default"
    set max-age 275
    set age 0
    set energy random 150
    set speed 0.3

  ]
end



;================================================================================================================================================================
; Runtime Procedures
;================================================================================================================================================================

to go
  if not any? turtles [ stop ]        ;; stop when no turtles

  show-turtle-details
  show-patches-details

  move-turtles
  move-rabbits


  regrow-grass

  tick
end




to regrow-grass
  ask patches [
    if pcolor = brown and regrowth-time > 0
      [
       set regrowth-time regrowth-time - 1
      ]
    if pcolor = brown and regrowth-time < 1
      [
        set pcolor green
      ]
  ]
end


to move-turtles
  ask turtles
  [
    set energy energy - (speed * 2)
    eat-food

    set age age + 1

  ]
end

to move-rabbits
  ask rabbits
  [
    wiggle
    car-crash
    forward speed
   ; attracted-road
    ;; first input is probability to reproduce
    ;; second input is energy required to give birth
  ;  reproduce 50  3
  ]
end


;================================================================================================================================================================
; Actions that can be taken by turtle
;================================================================================================================================================================

;; to reproduce
;; a is the probability to reproduce
;; be is the energy level required to reproduce
;; c is the number of offspring to hatch
to reproduce [ a c]
  ;;set be (be / 100 * birth-energy%)
  ask turtle-set self [
    if energy > birth-energy% [
      set energy energy - birth-energy%
      if random-float 100 < a
      [
        hatch c [rt random-float 360 fd 1 set age 0 set energy random 100]
      ]
    ]
  ]
end

to attracted-road
  ask self
  [
    if random 100 < road-attraction and count (neighbors with [pcolor = road-color]) >= 2
    [
      face nearest-of road
    ]
  ]
end

to car-crash
  ask self [
    if [pcolor] of patch-here = road-color
    [
      if random 100 < death-probability
      [
        output-print (word "Clojure Sent: ""id: "id " speed: " speed " color: "color)
        output-print (word id ":" speed ":"color)
      exec.repl2 (word "\""id ":" speed ":"color"\"")
      die
      ]
    ]
  ]
end

to eat-food
  ask self[

    if member? "grass" eats and pcolor = green
    [
      set pcolor brown
      set regrowth-time ( 5 + random regrow-grass% )
      set energy energy + energy-from-grass
    ]
  ]
end


;================================================================================================================================================================
; Repl
;================================================================================================================================================================

to exec.repl
  let cmd-str sock2:read
  output-print (word "received: " cmd-str)
  if ((word cmd-str) != "<null>")
  [
  run cmd-str
  tick
  ]
end


to exec.repl2 [message]
;  let message "hello-from-net-logo"
  output-print (word "sending: " message)
  sock2:write message
  output-print (word "sent: " message)

end

to finrepl [#num]
  loop [
   if (#num = 0)
   [stop]
   set #num (#num - 1)
   exec.repl
  ]
end


;================================================================================================================================================================
; Extra
;================================================================================================================================================================

to show-turtle-details
    ask turtles[
    if show-energy? and not show-age?
    [set label speed]

    if show-age? and not show-energy?
    [set label age]

    if not show-age? and not show-energy?
    [set label ""]
  ]
end


to show-patches-details
  ask patches[
    ifelse show-regrowth-time?
    [set plabel round regrowth-time]
    [set plabel ""]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
239
10
942
716
38
37
9.0
1
12
1
1
1
0
1
1
1
-38
38
-37
37
0
0
1
ticks
30.0

SLIDER
7
45
99
78
grid-size-y
grid-size-y
1
9
3
1
1
NIL
HORIZONTAL

SLIDER
7
10
99
43
grid-size-x
grid-size-x
1
9
3
1
1
NIL
HORIZONTAL

BUTTON
100
10
162
43
Setup
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
165
10
228
43
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
7
79
40
217
num-of-rabbits
num-of-rabbits
0
500
33
1
1
NIL
VERTICAL

MONITOR
102
47
162
92
turtles
count turtles
17
1
11

MONITOR
164
48
229
93
 patches
count patches with [pcolor = green]
17
1
11

SWITCH
101
95
227
128
show-energy?
show-energy?
0
1
-1000

PLOT
4
439
234
646
population
Time
pop
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10649926 true "" "plot count rabbits"

SLIDER
5
403
128
436
energy-from-grass
energy-from-grass
1.5
8.2
3.2
0.1
1
NIL
HORIZONTAL

SLIDER
129
403
233
436
birth-energy%
birth-energy%
45
100
79
1
1
NIL
HORIZONTAL

SWITCH
100
134
226
167
show-age?
show-age?
1
1
-1000

SLIDER
44
81
77
216
regrow-grass%
regrow-grass%
0
100
15
1
1
NIL
VERTICAL

TEXTBOX
116
219
266
303
Black - Dead\nRed - Foxes\n
11
0.0
1

SWITCH
102
170
225
203
show-regrowth-time?
show-regrowth-time?
1
1
-1000

SLIDER
8
366
180
399
death-probability
death-probability
0
100
91
1
1
NIL
HORIZONTAL

SLIDER
8
326
180
359
road-attraction
road-attraction
0
35
33
1
1
NIL
HORIZONTAL

INPUTBOX
952
12
1019
72
port-num
2223
1
0
Number

BUTTON
954
83
1029
116
connect
print (word \"connecting on \" port-num)\nsock2:connect-local port-num\nprint \"socket connected\"
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
958
139
1041
172
NIL
exec.repl
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
957
187
1281
524
11

@#$#@#$#@
## WHAT IS IT?

This is a model of traffic moving in a city grid. It allows you to control traffic lights and global variables, such as the speed limit and the number of cars, and explore traffic dynamics.

Try to develop strategies to improve traffic and to understand the different ways to measure the quality of traffic.

## HOW IT WORKS

Each time step, the cars attempt to move forward at their current speed.  If their current speed is less than the speed limit and there is no car directly in front of them, they accelerate.  If there is a slower car in front of them, they match the speed of the slower car and deccelerate.  If there is a red light or a stopped car in front of them, they stop.

There are two different ways the lights can change.  First, the user can change any light at any time by making the light current, and then clicking CHANGE LIGHT.  Second, lights can change automatically, once per cycle.  Initially, all lights will automatically change at the beginning of each cycle.

## HOW TO USE IT

Change the traffic grid (using the sliders GRID-SIZE-X and GRID-SIZE-Y) to make the desired number of lights.  Change any other of the settings that you would like to change.  Press the SETUP button.

At this time, you may configure the lights however you like, with any combination of auto/manual and any phase. Changes to the state of the current light are made using the CURRENT-AUTO?, CURRENT-PHASE and CHANGE LIGHT controls.  You may select the current intersection using the SELECT INTERSECTION control.  See below for details.

Start the simulation by pressing the GO button.  You may continue to make changes to the lights while the simulation is running.

### Buttons

SETUP - generates a new traffic grid based on the current GRID-SIZE-X and GRID-SIZE-Y and NUM-CARS number of cars.  This also clears all the plots. All lights are set to auto, and all phases are set to 0.
GO - runs the simulation indefinitely
CHANGE LIGHT - changes the direction traffic may flow through the current light. A light can be changed manually even if it is operating in auto mode.
SELECT INTERSECTION - allows you to select a new "current" light. When this button is depressed, click in the intersection which you would like to make current. When you've selected an intersection, the "current" label will move to the new intersection and this button will automatically pop up.

### Sliders

SPEED-LIMIT - sets the maximum speed for the cars
NUM-CARS - the number of cars in the simulation (you must press the SETUP button to see the change)
TICKS-PER-CYCLE - sets the number of ticks that will elapse for each cycle.  This has no effect on manual lights.  This allows you to increase or decrease the granularity with which lights can automatically change.
GRID-SIZE-X - sets the number of vertical roads there are (you must press the SETUP button to see the change)
GRID-SIZE-Y - sets the number of horizontal roads there are (you must press the SETUP button to see the change)
CURRENT-PHASE - controls when the current light changes, if it is in auto mode. The slider value represents the percentage of the way through each cycle at which the light should change. So, if the TICKS-PER-CYCLE is 20 and CURRENT-PHASE is 75%, the current light will switch at tick 15 of each cycle.

### Switches

POWER? - toggles the presence of traffic lights
CURRENT-AUTO? - toggles the current light between automatic mode, where it changes once per cycle (according to CURRENT-PHASE), and manual, in which you directly control it with CHANGE LIGHT.

### Plots

STOPPED CARS - displays the number of stopped cars over time
AVERAGE SPEED OF CARS - displays the average speed of cars over time
AVERAGE WAIT TIME OF CARS - displays the average time cars are stopped over time

## THINGS TO NOTICE

When cars have stopped at a traffic light, and then they start moving again, the traffic jam will move backwards even though the cars are moving forwards.  Why is this?

When POWER? is turned off and there are quite a few cars on the roads, "gridlock" usually occurs after a while.  In fact, gridlock can be so severe that traffic stops completely.  Why is it that no car can move forward and break the gridlock?  Could this happen in the real world?

Gridlock can occur when the power is turned on, as well.  What kinds of situations can lead to gridlock?

## THINGS TO TRY

Try changing the speed limit for the cars.  How does this affect the overall efficiency of the traffic flow?  Are fewer cars stopping for a shorter amount of time?  Is the average speed of the cars higher or lower than before?

Try changing the number of cars on the roads.  Does this affect the efficiency of the traffic flow?

How about changing the speed of the simulation?  Does this affect the efficiency of the traffic flow?

Try running this simulation with all lights automatic.  Is it harder to make the traffic move well using this scheme than controlling one light manually?  Why?

Try running this simulation with all lights automatic.  Try to find a way of setting the phases of the traffic lights so that the average speed of the cars is the highest.  Now try to minimize the number of stopped cars.  Now try to decrease the average wait time of the cars.  Is there any correlation between these different metrics?

## EXTENDING THE MODEL

Currently, the maximum speed limit (found in the SPEED-LIMIT slider) for the cars is 1.0.  This is due to the fact that the cars must look ahead the speed that they are traveling to see if there are cars ahead of them.  If there aren't, they speed up.  If there are, they slow down.  Looking ahead for a value greater than 1 is a little bit tricky.  Try implementing the correct behavior for speeds greater than 1.

When a car reaches the edge of the world, it reappears on the other side.  What if it disappeared, and if new cars entered the city at random locations and intervals?

## NETLOGO FEATURES

This model uses two forever buttons which may be active simultaneously, to allow the user to select a new current intersection while the model is running.

It also uses a chooser to allow the user to choose between several different possible plots, or to display all of them at once.

## RELATED MODELS

Traffic Basic simulates the flow of a single lane of traffic in one direction
Traffic 2 Lanes adds a second lane of traffic
Traffic Intersection simulates a single intersection

The HubNet activity Gridlock has very similar functionality but allows a group of users to control the cars in a participatory fashion.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (2003).  NetLogo Traffic Grid model.  http://ccl.northwestern.edu/netlogo/models/TrafficGrid.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2003 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.

<!-- 2003 -->
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
true
0
Polygon -7500403 true true 180 15 164 21 144 39 135 60 132 74 106 87 84 97 63 115 50 141 50 165 60 225 150 285 165 285 225 285 225 15 180 15
Circle -16777216 true false 180 30 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 80 138 78 168 135 166 135 91 105 106 96 111 89 120
Circle -7500403 true true 195 195 58
Circle -7500403 true true 195 47 58

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

rabbit
false
0
Polygon -7500403 true true 61 150 76 180 91 195 103 214 91 240 76 255 61 270 76 270 106 255 132 209 151 210 181 210 211 240 196 255 181 255 166 247 151 255 166 270 211 270 241 255 240 210 270 225 285 165 256 135 226 105 166 90 91 105
Polygon -7500403 true true 75 164 94 104 70 82 45 89 19 104 4 149 19 164 37 162 59 153
Polygon -7500403 true true 64 98 96 87 138 26 130 15 97 36 54 86
Polygon -7500403 true true 49 89 57 47 78 4 89 20 70 88
Circle -16777216 true false 37 103 16
Line -16777216 false 44 150 104 150
Line -16777216 false 39 158 84 175
Line -16777216 false 29 159 57 195
Polygon -5825686 true false 0 150 15 165 15 150
Polygon -5825686 true false 76 90 97 47 130 32
Line -16777216 false 180 210 165 180
Line -16777216 false 165 180 180 165
Line -16777216 false 180 165 225 165
Line -16777216 false 180 210 210 240

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>count vultures</metric>
    <metric>count foxes</metric>
    <metric>count badgers</metric>
    <metric>count rabbits</metric>
    <metric>count death</metric>
    <enumeratedValueSet variable="num-of-turtles">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-age?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-grass%">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy%">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="main-variabls" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <metric>count rabbits</metric>
    <enumeratedValueSet variable="grid-size-y">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-regrowth-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="8.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy%">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-rabbits">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-age?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-grass%">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="main-virabels" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5000"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="regrow-grass%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-rabbits">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-energy%">
      <value value="78"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-regrowth-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-probability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-y">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="8.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grid-size-x">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-age?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
