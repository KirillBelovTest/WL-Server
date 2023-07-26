#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[FileNameJoin[{Directory[], "WebServer"}]]


Get["KirillBelov`Internal`"]
Get["KirillBelov`Objects`"]
Get["KirillBelov`TCPServer`"]
Get["KirillBelov`HTTPHandler`"]
Get["KirillBelov`HTTPHandler`Extensions`"]


tcp = TCPServer[]
http = HTTPHandler[]
AddHTTPHandler[tcp, http]
listener = SocketListen[8000, tcp@#&]


http["MessageHandler", "GETFile"] = GetFileRequestQ[{"html", "js", "css", "svg", "png", "jpg", "dat", "txt"}] -> ImportFile
http["MessageHandler", "WSP"] = GetFileRequestQ[{"wsp"}] -> HypertextProcess
http["MessageHandler", "Index"] = AssocMatchQ[<|"Path" -> "/"|>] -> Function[HypertextProcess[#, "index.wsp"]]


While[True, Pause[0.001]]
