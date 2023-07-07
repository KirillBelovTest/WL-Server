(* polyfills from frontend *)
NotebookPromise[uid_, params_][expr_] := With[{},
    WebSocketChannel[Automatic]["Push", Global`PromiseResolve[uid, expr]]
];

NotebookAddTracking[symbol_] := With[{cli = Global`client, name = SymbolName[Unevaluated[symbol]]},
    Print["Add tracking... for "<>name];
    Experimental`ValueFunction[Unevaluated[symbol]] = Function[{y,x}, WebSocketChannel[Automatic]["Push", cli, FrontUpdateSymbol[name, x]]]
]

SetAttributes[NotebookAddTracking, HoldFirst]


NotebookPromiseKernel[uid_, params_][expr_] := With[{cli = Global`client},
    With[{result = expr // ReleaseHold},
        Print["side evaluating on the Kernel"];
        WebSocketChannel[Automatic]["Push", Global`PromiseResolve[uid, result]]
    ]
];

NotebookEmitt[expr_] := ReleaseHold[expr]

(* polyfills from frontend *)
FrontSubmit[expr_] := WebSocketChannel["jsio"]["Publish", expr];