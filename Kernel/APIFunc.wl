(* ::Package:: *)

(*internal package*)


BeginPackage["KirillBelov`WolframWebServer`APIFunc`", {
	"KirillBelov`WolframWebServer`PatternInfo`"
}]; 


APIFunc::usage = 
"APIFunc[func, assoc] extracts func and args from query."; 


Begin["`Private`"]; 


signatureInfo[func_Symbol] := 
Map[Cases[#, arg_ :> PatternInfo[arg], {2}]&] @ 
DownValues[func][[All, 1]]; 


parametersMatchQ[params_List, args_Association] := 
Module[{argNames, argValues, requaredParameters, optionalParameters, valueParameters}, 
	requaredParameters = Map[ToLowerCase] @ Select[params, #Default === None && #Name =!= None&][[All, "Name"]]; 
	optionalParameters = Map[ToLowerCase] @ Select[params, #Default =!= None && #Name =!= None&][[All, "Name"]]; 
	valueParameters = Select[params, #Name === None && #Value =!= None&][[All, "Value"]]; 
	argNames = Map[StringReplace[#, "_" -> ""]&] @ Map[ToLowerCase] @ Keys[args]; 
	argValues = Values[args]; 
	
	Or[
		Sort[argValues] === Sort[valueParameters], 
		And[
			SubsetQ[argNames, requaredParameters], 
			SubsetQ[optionalParameters, Complement[argNames, requaredParameters]]
		]
	]
]; 


selectSignaure[func_Symbol, args_Association] := 
SelectFirst[parametersMatchQ[#, args]&] @ signatureInfo[func]; 


stringConverterPattern = {String, _} | {_, StringQ}; 


convert[stringConverterPattern][arg_] := ToString[arg]; 


integerConverterPattern = {Integer, _} | {_, IntegerQ}; 


convert[integerConverterPattern][arg_] := Round[ToExpression[arg]]; 


realConveterPattern = {Real, _}; 


convert[realConveterPattern][arg_] := N[ToExpression[arg]]; 


numberConveterPattern = {_, NumericQ} | {_, NumberQ}; 


convert[numberConveterPattern][arg_] := ToExpression[arg]; 


dateConveterPattern = {DateObject, _} | {_, DateObjectQ}; 


convert[dateConveterPattern][arg_] := DateObject[arg]; 


symbolConveterPattern = {Symbol, _}; 


convert[symbolConveterPattern][arg_] := Symbol[arg]; 


convert[{_, _}][arg_] := arg; 


argGet[assoc_Association, key_String] := 
First @ Values @ KeySelect[
	assoc, 
    StringMatchQ[
		StringReplace[key, "_" -> ""], 
    	StringReplace[#, "_" -> ""], 
		IgnoreCase -> True]&
];


argExistsQ[assoc_Association, key_String] := 
MemberQ[
	(StringReplace[#, "_" -> ""] & @* ToLowerCase) /@ Keys[assoc], 
	(StringReplace[#, "_" -> ""] & @* ToLowerCase)[key]
]


APIFunc[func_Symbol, assoc_Association] := 
Module[{params = selectSignaure[func, assoc], values}, 
	values = Table[
		If[argExistsQ[assoc, p["Name"]], 
			convert[{p["Type"], p["Test"]}][argGet[assoc, p["Name"]]], 
			Nothing
		], 
		{p, params}
	]; 
	func @@ values
]; 


End[]; 


EndPackage[]; 
