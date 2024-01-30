#!/usr/bin/env wolframscript
(* ::Package:: *)

PacletDirectoryLoad[Directory[]]; 


Get["KirillBelov`WolframWebServer`"]; 


server = CreateWebServer[8080, 
	"PublicDirectory" -> "public", 
	"APIContext" -> "api`"
]; 


Begin["api`"]; 


test[] := "hello!"; 


add[x_Integer, y_Integer] := x + y; 


End[]; 


While[True, Pause[0.01]]
