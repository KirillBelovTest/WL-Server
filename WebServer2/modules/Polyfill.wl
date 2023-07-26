(* polyfills from frontend *)
$DefaultSerializer = ExportByteArray[#, "ExpressionJSON"]&

jsio = WebSocketChannel[]
jsio@"Serializer" = $DefaultSerializer

NotebookPromise[uid_, params_][expr_] := With[{cli = Global`client},
    WebSocketSend[cli, Global`PromiseResolve[uid, expr] // $DefaultSerializer]
];

NotebookAddTracking[symbol_] := With[{cli = Global`client, name = SymbolName[Unevaluated[symbol]]},
    Print["Add tracking... for "<>name];
    Experimental`ValueFunction[Unevaluated[symbol]] = Function[{y,x}, WebSocketSend[cli, FrontUpdateSymbol[name, x] // $DefaultSerializer]]
]

SetAttributes[NotebookAddTracking, HoldFirst]


NotebookPromiseKernel[uid_, params_][expr_] := With[{cli = Global`client},
    With[{result = expr // ReleaseHold},
        Print["side evaluating on the Kernel"];
        WebSocketSend[cli, Global`PromiseResolve[uid, result] // $DefaultSerializer]
    ]
];

NotebookEmitt[expr_] := ReleaseHold[expr]

(* polyfills from frontend *)
FrontSubmit[expr_] := WebSocketSend[jsio, expr];