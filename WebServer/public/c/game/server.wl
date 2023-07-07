aimAngle = 0;
MoveAim[xy_] := Switch[xy[[1]], "dragged", aimAngle = -ArcTan@@(xy[[2]]), "dragended", fire[Norm[xy//Last]]];

fire[power_] := With[{tag = Symbol[RandomWord[]<>ToString[RandomInteger[200]]], bullet = Symbol[RandomWord[]<>ToString[RandomInteger[200]]], vel =  Symbol[RandomWord[]<>ToString[RandomInteger[200]]], a = aimAngle},
  tag = {0.2{Cos[a], -Sin[a]}};
  bullet = 0.2{Cos[a], -Sin[a]};
  vel = -180 Degree;

  trace[tag//Unevaluated, "time"] = 0;
  
  With[{holder = {Opacity[0.2], RandomReal[{0,1}, 3] // RGBColor, Line[tag // Hold], 
      
      Translate[MiddlewareHandler[Rotate[{Opacity[1], PointSize[0.05], Brown, Point[{0,0}], Line[{{0,0},{0,0.2}}]}, Hold[vel]],
    "end"->Function[x, trace[tag//Unevaluated, bullet//Unevaluated, vel//Unevaluated, a, power, trace[tag//Unevaluated, "time"]]; ], "Threshold"->0.5 ], Hold[bullet]]  
  }},
  
    Placed[holder, FindMetaMarker["field"]//First] // Hold // FrontSubmit
  ];

]

ClearAll[trace];

trace[tag_, bullet_, vel_, aimAngle_, power_, tMax_] := Module[{},
  If[- tMax power Sin[aimAngle]  - tMax tMax < -0.5,  Return[]];

  
  tag = Table[ {(t power + 0.2) Cos[aimAngle], (- t power - 0.2) Sin[aimAngle] - t t}, {t, 0, tMax, 0.2}];
  bullet = {(tMax power + 0.2) Cos[aimAngle], (- tMax power - 0.2) Sin[aimAngle] - tMax tMax};
  vel = ArcTan@@{( power) Cos[aimAngle], (-  power ) Sin[aimAngle] - 2 tMax} + 1.570 + RandomReal[{-0.1,0.1}];

  trace[tag//Unevaluated, "time"] = tMax + 0.1;
]
