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


tcp["CompleteHandler", "HTTP"] = HTTPPacketQ -> HTTPPacketLength
tcp["MessageHandler", "HTTP"] = HTTPPacketQ -> http


http["MessageHandler", "GETFile"] = GetFileRequestQ[{"html", "js", "css", "svg", "png", "jpg"}] -> ImportFileAsText


While[True, Pause[0.001]]