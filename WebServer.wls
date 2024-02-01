#!/usr/bin/env wolframscript
(* ::Package:: *)

PacletDirectoryLoad[Directory[]]; 


Get["KirillBelov`WolframWebServer`"]; 


server = CreateWebServer[8080]; 


test[] := "hello!"; 


add[x_Integer, y_Integer] := x + y; 


While[True, Pause[0.01]]
