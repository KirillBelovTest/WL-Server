(* :Package: *)

BeginPackage["KirillBelov`WolframWebServer`Options`"]; 


HTTPOptionsQ::usage = 
"HTTPOptionsQ[request] checks HTTP OPTIONS method."; 


HTTPOptions::usage = 
"HTTPOptions[server, request] hndle HTTP OPTIONS method."; 

Begin["`Private`"]


HTTPOptionsQ[request_Association] := 
StringMatchQ[request["Method"], "OPTIONS", IgnoreCase -> True]; 


HTTPOptions[server_][request_Association] := 
HTTPOptions[server, request]; 


HTTPOptions[server_, request_Association] := 
{}; 


End[]; 


EndPackage[]; 
