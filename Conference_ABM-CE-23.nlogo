breed [stayers stayer]
breed [leavers leaver]
patches-own [patch-type]
stayers-own [confidence]
leavers-own [confidence resting]


to setup

  clear-all
  set-patch-size 10
  resize-world 0 50 0 50 ; Adjust the world size as per your requirement
  create-chairs-1
  create-chairs-2
  create-coffee
  create-stayers2
  create-leavers2
  assign-confidence
  reset-ticks
end


;;Setup Environment,  create agents and position them in chair area

to create-chairs-1
  let chair-width 1
  let chair-height 7
  let left-edge (min-pxcor + chair-width) / 2
  let right-edge (max-pxcor - chair-width) / 2
  let top-edge (max-pycor - chair-height) / 2
  let bottom-edge (min-pycor + chair-height) / 2

  ask patches with [
    pxcor >= left-edge and pxcor <= right-edge and
    pycor >= bottom-edge and pycor <= top-edge
  ] [
    set patch-type "chair"
    set pcolor grey
  ]
end

to create-chairs-2
  let chair-width 20
  let chair-height 1
  let left-edge (((min-pxcor + chair-width) / 2) + room2-y )
  let right-edge (((max-pxcor - chair-width) / 2) + room2-y )
  let top-edge (((max-pycor - chair-height) / 2) + room2-x )
  let bottom-edge (((min-pycor + chair-height) / 2) + room2-x )

  ask patches with [
    pxcor >= left-edge and pxcor <= right-edge and
    pycor >= bottom-edge and pycor <= top-edge
  ] [
    set patch-type "chair"
    set pcolor grey
  ]
end

to create-coffee
  ask patches with [patch-type != "chair"] [
    set patch-type "coffee"
    set pcolor brown
  ]
end

to create-stayers2
  create-stayers ( ( 1 - frac-leavers ) * num-scholars ) [
    setxy random-xcor random-ycor ; Set the turtles' positions randomly
    set color green ; Set the turtles' color to green
    set shape "person student"
    set size 2
    move-to-chair
  ]
end

to create-leavers2
  create-leavers (  frac-leavers * num-scholars ) [
    setxy random-xcor random-ycor ; Set the turtles' positions randomly
    set color green ; Set the turtles' color to green
    set shape "person student"
    set size 2
    set resting 0
    move-to-chair
  ]
end


;;Initialize confidence and define movement procedures


to assign-confidence
  ask stayers [
    set confidence 0 ; Set the confidence property to 0 for stayers
  ]
  ask leavers [
    set confidence random 101 ; Set the confidence property to a random number between 0 and 100 for leavers
]
end

to move-to-chair
  let target-patch one-of patches with [patch-type = "chair" and not any? turtles-here]
  if target-patch != nobody [
    move-to target-patch
  ]
 end

to move-to-coffee

  let target-patch one-of patches with [patch-type = "coffee" and not any? turtles-here]
  if target-patch != nobody [
    move-to target-patch
              ]
end





;; GO procedure

to go
  ask leavers [
    indicate-willingness
  ]


tick

assess-vicinity
ask leavers [

    make-decision
  ]

  tick

  if ticks = break-time [
    stop
  ]
end




;; 1. Indicate Wilingness

to indicate-willingness



        if confidence < fear [
      set color green
  ]
    if  confidence > fear [

    set color yellow

    ]

end




;; 2. Asess the vicinity

to assess-vicinity
  let scholars (turtle-set stayers leavers)

  ask leavers [
    let nearby-scholars other scholars in-radius field-of-view
    let num-nearby-scholars count nearby-scholars
    let num-nearby-stayers count nearby-scholars with [color = green]
    let num-nearby-leavers count nearby-scholars with [color = yellow]



    if ( num-nearby-scholars > 0 ) [
      let frac-stayers-leavers (num-nearby-leavers / num-nearby-scholars)
      if frac-stayers-leavers >= 0.5 [
        set confidence (confidence + confidence-increase-factor)
      ]
      if frac-stayers-leavers < 0.5 [
        set confidence (confidence - confidence-decrease-factor)
      ]
    ]
    if ( num-nearby-scholars = 0 ) [

      set confidence (confidence - confidence-decrease-factor)
    ]

          if confidence < 0 [set confidence 0]
          if confidence > 100 [set confidence 100]

]



end


;; 3. Descision stage



to make-decision
  if resting > 0 [
    set resting (resting - 1)
  ]
  if resting = 0 [
    if patch-type = "chair" [
      if confidence > leave [
        set color black
        move-to-coffee
        set resting 5
      ]
    ]
    if patch-type != "chair" [
      if confidence < fear [
        set color green
        move-to-chair
        set resting 0
      ]
    ]
  ]
end










@#$#@#$#@
GRAPHICS-WINDOW
238
10
756
529
-1
-1
10.0
1
10
1
1
1
0
0
0
1
0
50
0
50
1
1
1
ticks
30.0

BUTTON
8
493
71
526
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
97
494
160
527
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

INPUTBOX
15
315
85
375
num-scholars
50.0
1
0
Number

INPUTBOX
95
380
168
440
break-time
100.0
1
0
Number

SLIDER
15
115
215
148
fear
fear
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
15
155
215
188
leave
leave
0
100
90.0
1
1
NIL
HORIZONTAL

SLIDER
15
210
215
243
confidence-increase-factor
confidence-increase-factor
0
10
3.0
1
1
NIL
HORIZONTAL

PLOT
769
14
969
164
Number of turtles with color
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
"default" 1.0 0 -1191199 true "" "plot count stayers"
"pen-1" 1.0 0 -13840069 true "" "plot count turtles with [ color = green]"
"pen-2" 1.0 0 -1184463 true "" "plot count leavers with [ color = yellow ]"
"pen-3" 1.0 0 -16449023 true "" "plot count leavers with [color = black ] "

INPUTBOX
15
380
87
440
field-of-view
3.0
1
0
Number

SLIDER
15
250
215
283
confidence-decrease-factor
confidence-decrease-factor
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
15
15
215
48
Room2-y
Room2-y
0
30
26.0
1
1
NIL
HORIZONTAL

SLIDER
15
55
215
88
room2-x
room2-x
0
30
20.0
1
1
NIL
HORIZONTAL

SLIDER
95
340
215
373
frac-leavers
frac-leavers
0
1
0.2
0.1
1
NIL
HORIZONTAL

PLOT
771
174
971
324
Number of turtles on area
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
"default" 1.0 0 -9276814 true "" "plot count turtles-on patches with [ pcolor =  grey  ]"
"pen-1" 1.0 0 -8431303 true "" "plot count turtles-on patches with [ pcolor =  brown  ]"

@#$#@#$#@
## WHAT IS IT?

This is a model of the (question) break at conferences. A certain level of confidence is needed to actually leave the room in the question break after a talk. In this model, confidence is accumulated by perceiving the indication of willingness of scholars around them. The indication of willingness can be thought of as unsuspicious actions, like changing the position of the jacket, closing a notebook or packing a bag. Once perceived, these raise the confidence of an agent to leave to the coffee area, once a threshold is surpassed. If only few people indicate their willingness, confidence decreases and scholars that might want to leave end up sitting through another boring session.



## HOW IT WORKS

Some Scholars want to leave ("leavers") the sesssion after a particular talk, others want to stay ("stayers"). These are the two breeds of turtles in this model. 

The environment consits of two "chair" areas which symbolize two conference-rooms (yellow). The rest of the plain represents the coffee area (brown). The dimensions of the second conference room can be adjusted by "room2-x" and "room2-y"sliders. Lastly the number of stayers, leavers and their vield of viem need to be defined.



Two thresholds are defined: 

	-"fear" which stands for structural and cultural differences between conferences. 	E.g.: It is easier to leave a session of people you dont know, than one in which 		scholars are expected to attend by some authority or peer pressure.

	-"leave" defines the least amount of confidence needed to actually leave towards 		the "coffee" area.


Two factors are defined:

	-"confidence-increase-factor"
	-"confidence-decrease-factor"

Both indicate how strongly the confidence increases or decreases respectively, depending on the asessment of the scholars in the vicinity.



All agents are initially endowed with a random value of confidence. The second agent property is "resting" which is initally zero, and hinders (if greater than zero) the movement of the agents. During initialization all scholars are placed on an empty chair area.



After GO agents:

1.Indicate their willingness. 

-Green for unwilling (confidence is below the "fear" threshold)
-yellow for willing (confidence above "fear")



2.Assess their vicinity: "leavers" observe their vicinity, count the total numbers of scholars and the fraction of those indicating their willingness to leave (colored yellow).

If the fraction of yellow colored scholars in all scholars is above 1/2, confidence increases by a factor, as scholars realize that others want to leave too.

If the fraction of yellow colored scholars in all scholars is below 1/2 confidence decreases by a factor, as scholars feel alone in their willingness to leave.

If no scholars are close by, confidence decreases, as scholars feel lonely.


3."leavers" take the descision to move or not to move. 

To move at all, "resting" has to be zero.

To move from a "chair" patch to a "coffee" patch, "confidence" has to be above 			the "leave" threshold. WHile moving, agents are colored black. Once the "coffee" 		patch is reached, resting is set to 5, so for 5 ticks the agents cannot change 			position even when their level of confidence is below "fear".

To move from "coffee" to "chair", confidence has to be below "fear". Agents are 		colored green. Resting is set to 0, as scholars only rest in the "coffee" 			area.



## HOW TO USE IT

1. Choose the dimensions of room 2. (This is not really necessary)
2. Choose the "fear" and "leave" thresholds (0-100).  Fear must be below leave, 		and it is wise to have quite a delta between them.
3. Choose the factors by which confidence decreases or increases (0-10).
4. Choose the number of scholars, the fraction of the breed leavers and their 			field of view. Lastly you can define the length of the break, to determine how 			long the simulation runs.




## THINGS TO NOTICE

How does information about the willingness propagate?
Did all leavers leave the chair area at one point?
After the end of the break, are all scholars back, are some staying at the coffee?

Which combinations of number of scholars and fraction of leavers leads to which outcome? How does the field of view change things?


With low field of view: 

In small groups, attendence is high nearly all scholars return to chairs, regardless of the fraction of leavers.

In large groups, peer pressure forces most scholars back on chairs after some time. But with a high fraction of leavers, groups of scholars remain in the coffee area to mingle.


(suggested things for the user to notice while running the model)

## THINGS TO TRY

First try a small amount of scholars (~20). Compare the evolution and outcome of an experiment with a high and a low fraction of leavers.

Than, repeat the experiment with a larger group of scholars (~100).

Press t6he go button, after the model stopped and observe whether a stable equilibrium emerges, and if scholars remain at the coffee or not.

CHange the thresholds for fear and leave and repeat the experiment.

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

Change "resting" period.

Implement different scholar densities/confidence-increase-factors/confidence distributions in the two chair area.

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

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

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
NetLogo 6.2.0
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
1
@#$#@#$#@
