
;; this is a simple model showing co-evolution/adaption of two species
;; the only parameter that changes is the active% of rabbits & foxes

__includes [ "sxl-utils.nls" ]



globals
[ 
  rabbit-initial-energy 
]

to setup-globals
  set rabbit-initial-energy 15
end


;-------------------------------------------
; UI procedures
;-------------------------------------------

to setup
  clear-all                           ;; clear the screen
  setup-globals
  ask patches [set pcolor grey]       ;; set the background (patches) to grey
  setup-rabbits
  setup-foxes
  reset-ticks
end


to go
  repeat fox-breed-cycle
  [ move-rabbits
    move-foxes
    tick
  ]
  breed-foxes
end


;-------------------------------------------
; rabbits
;-------------------------------------------

breed [rabbits rabbit]

rabbits-own
[ active%
  danger-dist   ;; distance of predator detection
  energy
]


to setup-rabbits
  create-rabbits num-of-rabbits
  ask rabbits
  [ set shape "rabbit"              ;; set their appearance
    set color white
    setxy random-xcor random-ycor   ;; give them random x,y coordintes...
    set active% (random 10)         ;; and a 0%-10% probability for activity
    set energy rabbit-initial-energy
    set danger-dist   (random 50)
  ]
end

to move-rabbits
  ask rabbits
  [ if (energy <= 0)
    [ ;; rest
      set color yellow
      set energy (energy + 0.3)
      stop
    ]
    let f nearest-of foxes
    if (distance f > danger-dist)          ;;___ relax away from fox
    [ set color green
      set energy (energy + 1)
      stop
    ]
    if (not trigger active%)           ;; rabbit is not active
    [ set color green
      set energy (energy + 1)
      stop
    ]
    set color white
    face f               ;; face the nearest fox
    right 180                           ;; turn around 180 deg (run away)
    wiggle                              ;; randomly turn a bit
    forward 0.5                         ;; move forward 1 step
    set energy (energy - 1)
  ]
end

to clone-a-rabbit
  ask one-of rabbits      ;; ask a rabbit to clone itself...
  [ hatch 1               ;; ...then mutate the activity of the clone
    [ set active%      (randomly-adjust active%)
      set danger-dist  (randomly-adjust danger-dist)
      set energy 5
    ]
  ]
end

to reset-rabbits
  ask rabbits [set active% (random 10)]
end



;-------------------------------------------
; foxes
;-------------------------------------------

breed [foxes fox]
foxes-own   [energy active%]              ;; every fox has an energy value & active%


to setup-foxes
  create-foxes num-of-foxes
  ask foxes
  [ set energy 0
    set color red
    setxy random-xcor random-ycor
    set shape "dog"
    set active% (random 10)
  ]
end



to move-foxes
  ask foxes
  [ if (not trigger active%)
    [ set color brown
      stop
    ]
    set color red
    face nearest-of rabbits            ;; face nearest rabbit
    wiggle                             ;; randomly turn a bit
    forward 0.7                        ;; move forward a step & a half
    
    if any? rabbits-here               ;; if this fox is on a rabbit ...
    [ set energy (energy + 1)          ;; ... eat it & gain energy ...
      ask one-of rabbits-here [die]    ;; ... and the rabbit dies ...
      clone-a-rabbit                   ;; ... and a new one is born
    ]
  ]
end

to breed-foxes
  ask min-one-of foxes [energy]       ;; find weakest fox
  [ die ]                             ;; kill it :o(
  ask one-of foxes
  [ hatch 1
    [ set active% (randomly-adjust active%)
    ]
  ]
  ask foxes
  [ set energy 0 ]                    ;; so everything is fair
  ask rabbits
  [ set energy rabbit-initial-energy ]
end

to reset-foxes
  ask foxes [set active% (random 10)]
end


;----------------------------------------------------
; utils
;----------------------------------------------------



to-report randomly-adjust [#x]
  report (mutate #x 5)
end


@#$#@#$#@
GRAPHICS-WINDOW
288
10
988
731
34
34
10.0
1
10
1
1
1
0
1
1
1
-34
34
-34
34
0
0
1
ticks
30.0

SLIDER
14
125
199
158
num-of-rabbits
num-of-rabbits
10
300
250
10
1
NIL
HORIZONTAL

SLIDER
14
164
199
197
num-of-foxes
num-of-foxes
0
100
30
1
1
NIL
HORIZONTAL

BUTTON
15
82
79
116
NIL
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
91
83
155
117
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
202
201
235
fox-breed-cycle
fox-breed-cycle
1
100
100
1
1
ticks
HORIZONTAL

PLOT
13
395
213
545
active%
NIL
NIL
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"fox" 1.0 0 -2674135 true "" "plot mean [active%] of foxes"
"rabbit" 1.0 0 -7500403 true "" "plot mean [active%] of rabbits"
"pen-2" 1.0 0 -16777216 true "" "plot 100"

TEXTBOX
15
14
227
80
Click \"setup\" then \"go\" to see fox & rabbit speed adapting.\n\nCheck the info tab for other options.
12
0.0
0

BUTTON
13
549
102
582
NIL
reset-rabbits
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
114
550
193
583
NIL
reset-foxes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
13
241
213
391
rabbit dangerdist
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"ave" 1.0 0 -7500403 true "" "plot mean [danger-dist] of rabbits"
"max" 1.0 0 -2674135 true "" "plot max [danger-dist] of rabbits"
"min" 1.0 0 -13345367 true "" "plot min [danger-dist] of rabbits"

MONITOR
214
241
271
286
mean
mean [danger-dist] of rabbits
1
1
11

MONITOR
214
395
271
440
fox
mean [active%] of foxes
1
1
11

MONITOR
214
440
271
485
rabbit
mean [active%] of rabbits
1
1
11

@#$#@#$#@
## BRIEF

This model shows a simple co-evolution adaption over time.

Foxes and rabbits exist in a predator/prey relationship. Foxes chase rabbits & eat the rabbits if they reach them, individual foxes gain energy by eating rabbits and the rabbits die when they are eaten.

Each time a rabbit dies, a new rabbit is created as a modified version of one of the other rabbits that still exist. The modification is occurs as a small random adjustment to the speed of the new rabbit (see below).

Every few cycles (ticks) foxes breed. In this phase, the fox with the lowest 'energy' value is removed and a new fox is created. Like rabbits, the new fox is a modified version of one of the other foxes that still exist. The modification is occurs as a small random adjustment to fox's speed.

This model extends and replaces(?) a similar model, providing an additional facilty to reset either fox or rabbit populations to their starting state so you can examine the difference in performance of learned behaviour.


### speed

The speed of foxes/rabbits is actually a probability that at any tick it will move. The move-forward procedure for both breeds is...

    if ((random 100) <= speed)
    [ fd 1 ]

At the start of the model (during setup), speed is set (uniquely for each individual) to a random value between 0 and initial-rnd-speed.

Each time a new fox/rabbit is cloned its speed is based on its parent's speed but modified by adding a random value between "mutator-lo" and "mutator-hi" (-2 and 2 by default).



### movement

Movement is simple. Foxes find the nearest rabbit & move towards it; rabbits find the nearest fox & move away from it. Both rabbits & foxes wiggle a little, ie: there is a random adjustment made to their direction of movement.




## HOW TO OPERATE THE MODEL

The model has the following controls...

* num-of-rabbits
  the number of rabbits

* num-of-foxes
  the number of foxes

* initial-rnd-speed
  initial speed of individuals (see above)

* fox-breed-cycle
  number of ticks between breeding new foxes

* fox-start-energy
  how many rabbits-worth of energy foxes start with

* fox-energy-gain-from-rabbit
  how much energy a fox gets from eating a rabbit (one rabbits-worth of energy)

* fox-inherits-energy?
  if this is “ON” a cloned fox inherits its parent’s energy, if this is “OFF” clones start with the same energy that 1st generation foxes are initialised with, ie:

    fox-start-energy * fox-energy-gain-from-rabbit



## THINGS TO NOTE

The graph shows the average "speed" of each breed. You would expect this to stabilise at around 100 (since at 100 turtles move each tick) & this will often be the case but surprisingly not always.

Try changing the speed-modification mechanism so there is more chance the speed will reduce than increase (try using mutator lo/hi values between -2 and 1 instead of -2 to +2). Sometimes you will see the fox speed falling of until they are stationary -- why do think this happens?



## RELATED MODELS

check out other models using mazes on the NetLogo pages at www.agent-domain.org


## CREDITS, REFERENCES AND CONTACT DETAILS

Copyright 2013. Simon Lynch. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:

  1  this copyright notice is included.
  2  this model will not be used for profit without permission from Simon Lynch. Contact Simon Lynch for appropriate licenses for commercial use.

To reference this work in publications, please use the model name, Simon Lynch (2013), www.agent-domain.org

For more information contact borismolecule@gmail.com
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

dog
false
0
Polygon -7500403 true true 300 165 300 195 270 210 183 204 180 240 165 270 165 300 120 300 0 240 45 165 75 90 75 45 105 15 135 45 165 45 180 15 225 15 255 30 225 30 210 60 225 90 225 105
Polygon -16777216 true false 0 240 120 300 165 300 165 285 120 285 10 221
Line -16777216 false 210 60 180 45
Line -16777216 false 90 45 90 90
Line -16777216 false 90 90 105 105
Line -16777216 false 105 105 135 60
Line -16777216 false 90 45 135 60
Line -16777216 false 135 60 135 45
Line -16777216 false 181 203 151 203
Line -16777216 false 150 201 105 171
Circle -16777216 true false 171 88 34
Circle -16777216 false false 261 162 30

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

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
