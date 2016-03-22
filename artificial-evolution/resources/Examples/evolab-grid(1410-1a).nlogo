
__includes [ "sxl-utils.nls" ]

extensions [table]


;========================================
; GLOBALS
;========================================


globals
[ *sensors*             ;; sensor map
  *effectors*           ;; effector map
  *rules-per-genome*    ;; number of rules per genome
  *bits-per-rule*       ;; number of bits in a rule
  *sight-distance*      ;; distance of sensor operation
  *gene-alphabet*       ;; list of possible genes
  move-cost
  f-mean
  world-radius          ;; radius of the world & turtle positions
]


to globals.setup
  set *sensors*
      table:from-list
      [["00"  "target-fwd"   ]
       ["01"  "target-left"  ]
       ["10"  "target-right" ]
       ["11"  "true"        ]
       ]
 
  set *effectors*
      table:from-list
      [["000"  "move-fwd"   ]
       ["001"  "turn-right" ]
       ["010"  "turn-left"  ]
       ["011"  "turn-180"   ]
       ["100"  "turn-right" ]
       ["101"  "turn-left"  ]
       ["110"  "turn-right" ]
       ["111"  "turn-left"  ]]
      
  ;_ key globals ________
  set *rules-per-genome*  6
  set *bits-per-rule*     5
  set *gene-alphabet*     [0 1]
  set *sight-distance*    (max-pxcor + max-pycor)
  set move-cost           1
  set world-radius        (max-pxcor + max-pycor) / 2
end



;========================================
; SETUP & GO
;========================================


to setup
  clear-all
  globals.setup
  foods.setup
  bugs.setup
  reset-ticks
end


to go
  repeat breed-cycle
  [ ask bugs
    [ bug.run
    ]
    foods.move
    tick
  ]
  do-plots
  if show-info? [ print "____ breed ______" ]
  set f-mean (mean [$fitness] of bugs)
  repeat num-to-breed
  [ incremental-breed
  ]
  ask bugs
  [ set $fitness 0
  ]
end



;========================================
; BUGS - these evolve
;========================================



breed [bugs bug]        ;; the evolving breed

bugs-own
[ ;; evolving breeds need the following variables
  $genome     ;; the genome
  $rules      ;; rules in string form (for diagnostics/debugging)
  $phenome    ;; the rule task or other phenotype
  $fitness    ;; rolling fitness value
  $tmp        ;; working variable
]

to bugs.setup
  let #genome-size (*rules-per-genome* * *bits-per-rule*)
  create-bugs *num-bugs*
  [ set $genome    (genome.make-rnd-genome #genome-size [0 1])
    set $rules     genome.make-rules $genome
    set $phenome   (runresult $rules)  ; ie: compile the rules
    set $fitness   0
    set $tmp       0
    setxy random-xcor random-ycor
    move-to patch-here
    set heading one-of [0 90 180 270]
    set color red
    set size 2.5
  ]
;  ask bugs
;  [ set heading (random 360)
;  ]
end


to bug.run
  ;print (word "running " who)
  ;print $rules
  ;print $phenome
  carefully [run $phenome] []
  ;print (word "scoring " who)
  if any? foods in-radius 1
  [ set $fitness ($fitness + 1)
    
    ask foods in-radius 1
    [ ;; relocate
      setxy random-xcor random-ycor
    ]

  ]
end


to-report square [#x]
  report (#x * #x)
end



;========================================
; FOOD - not evolving
;========================================


breed [foods food]  


to foods.setup
  create-foods num-foods
  [ set color green
    set shape "circle"
    set size 1.5
    setxy random-xcor random-ycor
    move-to patch-here
  ]
end


to foods.move
  ask foods
  [ wiggle
    fd 0.5
  ]
end



;;==============================
;; genome creation
;;==============================

to-report genome.make-rnd-genome [#size #genes]
  ;; genes must be a list of allowed genes, eg: [0 1]
  let #g ""
  repeat (#size)
  [ set #g (word #g (one-of #genes))
  ]
  report #g
end


;;==============================
;; rule translation
;;==============================


to-report genome.make-rules [#genome]
  let #gbits 0
  let #rule-txt "(task ["
  ;;let #rule-txt "["
  let #n 0
  repeat (*rules-per-genome*)
  [ set #gbits (genome.grab-nth-chunk #genome #n *bits-per-rule*)
    set #rule-txt (word #rule-txt (genome.bits-to-rule #gbits))
    set #n (#n + 1)
  ]
  ;; need to close the task declaration
  report (word #rule-txt "report false])")
  ;;report (word #rule-txt "report false]")
end


to-report genome.bits-to-rule [#bits]
  report (word "if (sensor." table:get *sensors* (substring #bits 0 2) ")"
               " [ effector."  table:get *effectors* (substring #bits 2 5)
               "   report false ]"
               )
end





;;==============================
;; genetic operators
;;==============================

to-report genome.cross-over [#genome-a #genome-b #xprob]
  let #res ""
  let #tmp []
  let #n 0
  repeat (length #genome-a)
  [ if (trigger #xprob)
    [ ;; swap genomes a & b
      set #tmp #genome-a
      set #genome-a #genome-b
      set #genome-b #tmp
    ]
    set #res (word #res (item #n #genome-a))
    set #n (#n + 1)
  ]
  report #res
end


to-report genome.mutate [#genome #genes #mprob]
  ;; genes must be a list of allowed genes, eg: [0 1]
  let #res #genome
  let #n 0
  repeat (length #genome)
  [ if (trigger #mprob)
    [ set #res (replace-item #n #res (word (one-of #genes)))
    ]
    set #n (#n + 1)
  ]
  report #res
end
  
    
;; translation
;; if <C> [ <A> report true ]

to-report genome.grab-nth-chunk [#genome #n #chunk-size]
  report substring #genome (#n * #chunk-size) ((#n + 1) * #chunk-size)
end


;;==============================
;; sensors
;;==============================

to-report sensor.target-fwd
  report sensor.obj-fwd foods
end

to-report sensor.target-left
  report sensor.obj-side foods -90
end
  
to-report sensor.target-right
  report sensor.obj-side foods 90
end


to-report sensor.true
  report true
end

to-report sensor.false
  report false
end

;__ sensor support _____________

to-report sensor.obj-fwd [#obj-ebreed]
  let alpha abs(heading - (towards nearest-of foods))
  report (alpha <= 45)
end

to-report sensor.obj-side [#obj-ebreed #angle]
  right #angle
  let #res sensor.obj-fwd #obj-ebreed
  left #angle
  report #res
end



;;==============================
;; effectors
;;==============================

to effector.move-fwd
  fd 1
 ; move-to patch-here
end

to effector.turn-right
  right 90
end

to effector.turn-left
  left 90
end

to effector.turn-180
  right 180
end

to effector.nop
  ;; do nuffin
end



;;==============================
;; breeding
;;==============================

to incremental-breed
  let #bug min-one-of bugs [$fitness]
  
  ask #bug
  [ let #p1 one-of other bugs with [$fitness >= f-mean]
    let #p2 one-of other bugs with [$fitness >= f-mean]
    if show-info? [ print (word "breed replacing " (profile #bug) " from {" (profile #p1) ", " (profile #p2) "}")]
    let #g (genome.cross-over ([$genome] of #p1) ([$genome] of #p2) *cross-prob*)
    set $genome (genome.mutate #g *gene-alphabet* *mutate-prob*)
    set $rules     genome.make-rules $genome
    set $phenome   (runresult $rules)  ; ie: compile the rules
    set $fitness mean [$fitness] of bugs
  ]
end

to-report profile [#b]
  report (word #b "/" ([round $fitness] of #b))
end


;;==============================
;; utils
;;==============================

;to-report valof [#var]
;  report runresult #var
;end


;;==============================
;; plotting
;;==============================

to do-plots
  ;; do plots for rabbits
  let #breed "rabbit"
  let #best-bug max-one-of bugs [$fitness]
  set-current-plot "fitness"
  set-current-plot-pen "best"
  plot [$fitness] of #best-bug
  set-current-plot-pen "average"
  plot mean [$fitness] of bugs
end

;;==============================
;; test results
;;==============================

;
;observer> show genome.grab-nth-chunk "1111222233334444" 1 4
;observer: "2222"
;
;observer> show genome.grab-nth-chunk "1111222233334444" 2 4
;observer: "3333"
;
;observer> show genome.mutate "----------" ["X" "Y"] 3
;observer: "YY-Y-YY---"
;
;observer> show genome.mutate "----------" ["X" "Y"] 3
;observer: "------YX-X"
;
;observer> show genome.cross-over "----------" "XXXXXXXXXX"  3
;observer: "XX--XXX--X"
;
;observer> show genome.cross-over "----------" "XXXXXXXXXX"  3
;observer: "-XX----XXX"
;
;observer> show genome.make-rnd-genome 20 ["o" "x" "T"]
;observer: "ooTxTxoTxxTxToxoTToo"
;
;observer> show genome.make-rnd-genome 20 ["o" "x" "T"]
;observer: "xxTxxxxxTTTTxoTTooxT"
;
;;early trial
;observer> show genome.make-rules (genome.make-rnd-genome 20 [0 1])
;observer: "if (sensor.pred-right) [ effector.move-fwd report true] 
;           if (sensor.true) [ effector.turn-left report true]
;           if (sensor.false) [ effector.move-fwd report true] 
;           if (sensor.pred-left) [ effector.turn-left report true] "
;     
;;current
;observer> show genome.make-rules (genome.make-rnd-genome 20 [0 1])
;ifelse (sensor.target-right) [ effector.move-fwd ] 
;[ ifelse (sensor.pred-fwd) [ effector.turn-left ] 
;  [ ifelse (sensor.pred-left) [ effector.turn-right ] 
;    [ ifelse (sensor.target-fwd) [ effector.turn-left ] 
;      [ effector.nop ]]]]
@#$#@#$#@
GRAPHICS-WINDOW
234
10
697
494
75
75
3.0
1
10
1
1
1
0
1
1
1
-75
75
-75
75
0
0
1
ticks
30.0

SLIDER
11
54
183
87
*num-bugs*
*num-bugs*
0
200
50
1
1
NIL
HORIZONTAL

SLIDER
12
132
184
165
*cross-prob*
*cross-prob*
0
100
25
1
1
NIL
HORIZONTAL

SLIDER
11
173
183
206
*mutate-prob*
*mutate-prob*
0
100
10
1
1
NIL
HORIZONTAL

BUTTON
12
11
75
44
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
86
12
149
45
once
go
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
160
13
223
46
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
210
185
243
breed-cycle
breed-cycle
1
200
200
1
1
NIL
HORIZONTAL

SLIDER
14
249
186
282
num-to-breed
num-to-breed
1
100
10
1
1
NIL
HORIZONTAL

SLIDER
9
91
181
124
num-foods
num-foods
10
200
70
10
1
NIL
HORIZONTAL

PLOT
14
290
224
440
fitness
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
"average" 1.0 0 -16777216 true "" ""
"best" 1.0 0 -2674135 true "" ""

SWITCH
15
445
131
478
show-info?
show-info?
1
1
-1000

@#$#@#$#@
## INFM

under development
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

thick ring
true
0
Circle -7500403 false true -1 -1 301
Circle -7500403 false true 15 15 270
Circle -7500403 false true 30 30 240

thin ring
true
0
Circle -7500403 false true -1 -1 301

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
NetLogo 5.0.2
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
