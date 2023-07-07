#!/usr/bin/env wolframscript
(* ::Package:: *)

(*Default Initialization*)


(*PacletInstall["KirillBelov/Internal"]*)
(*PacletInstall["KirillBelov/Objets"]*)
(*PacletInstall["KirillBelov/TCPServer"]*)


Get["KirillBelov`Internal`"]
Get["KirillBelov`Objects`"]
Get["KirillBelov`TCPServer`"]


tcp = TCPServer[]


listener = SocketListen[8000, tcp@#&]


tcp["CompleteHandler", "Ping"] = pingQ -> pingLength
tcp["MessageHandler", "Ping"] = pingQ -> pong


pingQ[client_SocketObject, message_ByteArray] :=
(*Return:True|False*)
Echo[ByteArrayToString[message] == "ping", "pingQ"]


pingLength[client_SocketObject, message_ByteArray] :=
(*Return:_Integer*)
Echo[Length[message], "pingLength"]


pong[cleint_SocketObject, message_ByteArray] := (
    Echo[message, "ping"];
    (*Return:ByteArray[]*)
    Echo[StringToByteArray["pong"], "pong"]
)


socket = SocketConnect[8000]
BinaryWrite[socket, StringToByteArray["ping"]]
result = SocketReadMessage[socket]
ByteArrayToString[result]
Close[socket]


tcp["CompleteHandler"] = <||>
tcp["MessageHandler"] = <||>


(*PacletInstall["KirillBelov/HTTPHandler"]*)


Get["KirillBelov`HTTPHandler`"]
Get["KirillBelov`HTTPHandler`Extensions`"]


http = HTTPHandler[]


AddHTTPHandler[tcp, http]


http["MessageHandler", "GETFile"] = 
    GetFileRequestQ[{"html", "js", "css", "svg", "png", "jpg"}] -> ImportFileAsText


plotQ[request_Association] := And[
    request["Method"] == "GET", 
    request["Path"] == "/plot", 
    SubsetQ[{"func", "from", "to"}, Keys[request["Query"]]]
]


plot[request_Association] := Module[{func, from, to, graphics}, 
    With[{
		func = ToExpression[request["Query", "func"]], 
    	from = ToExpression[request["Query", "from"]], 
    	to = ToExpression[request["Query", "to"]]
	}, 
    	graphics = Plot[func[x], {x, from, to}]; 
	]; 

    (*Return: _String*)
    ExportString[graphics, "SVG"]
]


http["MessageHandler", "Plot"] = plotQ -> plot


AssocMatchQ[<|"Method" -> "GET"|>][<|"Method" -> "GET", "Query" -> <||>|>] (* => True *)


AssocMatchQ[<|"Path" -> __ ~~ ".html"|>][<|"Path" -> "/page.html"|>] (* => True *)


plot[request_Association] := 
APIFunction[
    {"func" -> "String", "from" -> "Number", "to" -> "Number"}, 
    ExportString[Plot[Evaluate[ToExpression[#func]][x], {x, #from, #to}], "PNG"]&
][request["Query"]]


apiQ := AssocMatchQ[<|"Path" -> "/api/" ~~ __|>]


argType[arg_String] := 
Which[
    StringMatchQ[arg, NumberString], "Number", 
    True, "String"
]


api[request_Association] := 
Module[{format, result}, 
    format = If[KeyExistsQ[request["Query"], "format"], request["Query", "format"], "String"]; 
    With[{
        func = ToExpression[StringSplit[request["Path"], "/"][[-1]]], 
        args = Normal[Map[argType, Delete[request["Query"], "format"]]]
    }, 
        result = If[Length[args] > 0, 
            APIFunction[args, func][request["Query"]], 
            func[]
        ]; 

        (*Return: _String*)
        ExportString[result, format]
    ]
]


http["MessageHandler", "API"] = apiQ -> api


bessel = Function[BesselJ[#n, N[#z]]]


Export["sin.dat", Table[{x, Sin[x]}, {x, -5, 5, 0.25}], "Table"]
Export["cos.dat", Table[{x, Cos[x]}, {x, -5, 5, 0.25}], "Table"]


getDataFiles = Function[
    FileNames["*.dat"]
]


getDataFilePoints = Function[
    Thread[{"x", "y"} -> Transpose[Import[#file, "Table"]]]
]


(*PacletInstall["JerryI/WSP"]*)


Get["JerryI`WSP`"]
Get["KirillBelov`HTTPHandler`WSPAdapter`"]


http["MessageHandler", "WSP"] = GetFileRequestQ[{"wsp"}] -> HypertextProcess


http["MessageHandler", "Index"] = 
    AssocMatchQ[<|"Path" -> "/"|>] -> Function[HypertextProcess[#, "index.wsp"]]


While[True, Pause[0.001]]
