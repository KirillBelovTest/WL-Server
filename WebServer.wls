#!/usr/bin/env wolframscript
(* ::Package:: *)

(*Default Initialization*)


(*PacletInstall["KirillBelov/Internal"]
PacletInstall["KirillBelov/Objects"]
PacletInstall["KirillBelov/TCPServer"]
PacletInstall["KirillBelov/HTTPHandler"]
PacletInstall["KirillBelov/WebSocketHandler"]*)


Get["KirillBelov`Internal`"]
Get["KirillBelov`TCPServer`"]
Get["KirillBelov`HTTPHandler`"]
Get["KirillBelov`HTTPHandler`Extensions`"]
Get["KirillBelov`WebSocketHandler`"]


Get["API.wl"]


tcp = TCPServer[]
http = HTTPHandler[]
ws = WebSocketHandler[]


tcp["CompleteHandler", "HTTP"] = HTTPPacketQ -> HTTPPacketLength
tcp["CompleteHandler", "WebSocket"] = WebSocketPacketQ -> WebSocketPacketLength


tcp["MessageHandler", "HTTP"] = HTTPPacketQ -> http
tcp["MessageHandler", "WebSocket"] = WebSocketPacketQ -> ws


(*HTTP*)


http["MessageHandler", "Index"] = indexQ -> 
http["MessageHandler", "File"] = getFileQ -> ImportFileAsText
http["MessageHandler", "API"] = apiQ -> apiFunc


(*Internal*)


indexQ = AssocMatchQ[<|"Path" -> "/"|>]
getFileQ = GetFileRequestQ[{"html", "css", "js", "png", "jpg", "svg"}]
apiQ = AssocMatchQ[<|"Path" -> "/api/" ~~ __|>]


index = Function[ImportFileAsText["index.html"]]
apiFunc = Function[PathToFunc[#Path][#Query]]



(*WebSocket*)





(*Start*)


listener = SocketListen[8000, tcp@#&]
While[True, Pause[0.001]]
