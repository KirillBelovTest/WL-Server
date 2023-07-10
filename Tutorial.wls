#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[FileNameJoin[{Directory[], "Tutorial"}]]


Get["KirillBelov`Internal`"]
Get["KirillBelov`Objects`"]
Get["KirillBelov`TCPServer`"]
Get["KirillBelov`HTTPHandler`"]
Get["KirillBelov`HTTPHandler`Extensions`"]


tcp = TCPServer[]


listener = SocketListen[8000, tcp@#&]


http = HTTPHandler[]


AddHTTPHandler[tcp, http]


http["MessageHandler", "GETFile"] = GetFileRequestQ[{"html", "js", "css", "svg", "png", "jpg"}] -> ImportFileAsText
http["MessageHandler", "WSP"] = GetFileRequestQ[{"wsp"}] -> HypertextProcess
http["MessageHandler", "Index"] = AssocMatchQ[<|"Path" -> "/"|>] -> Function[HypertextProcess[#, "index.wsp"]]


While[True, Pause[0.001]]
