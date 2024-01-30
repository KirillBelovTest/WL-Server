(* ::Package:: *)

(*internal package*)


BeginPackage["KirillBelov`WolframWebServer`FuncResolver`"]; 


callFunc::usage = 
"callFunc[func, args]"; 


Begin["`Private`"]; 


(*x_ | x_Type*)
patternInfo[Verbatim[Pattern][name_Symbol, Verbatim[Blank][type_Symbol: None]]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> None, 
	"Test" -> None
|>; 


(*x: _?test | x: _Type?test*)
patternInfo[Verbatim[Pattern][name_Symbol, Verbatim[PatternTest][Verbatim[Blank][type_Symbol: None], test_]]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> None, 
	"Test" -> test
|>; 


(*x_: default | x_Type: default*)
patternInfo[Verbatim[Optional][Verbatim[Pattern][name_Symbol, Verbatim[Blank][type_Symbol: None]], defaultValue_]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> defaultValue, 
	"Test" -> None
|>; 


(*x_?test | x_Type?test*)
patternInfo[Verbatim[PatternTest][Verbatim[Pattern][name_Symbol, Verbatim[Blank][type_Symbol: None]], testFunc_]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> None, 
	"Test" -> testFunc
|>; 


(*x: _?test: default | x: _Type?test: default*)
patternInfo[Verbatim[Optional][Verbatim[Pattern][name_Symbol, Verbatim[PatternTest][Verbatim[Blank][type_Symbol: None], testFunc_]], defaultValue_]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> defaultValue, 
	"Test" -> testFunc
|>; 


signatureInfo[func_Symbol] := 
Map[Cases[#, arg_ :> patternInfo[arg], {2}]&] @ 
DownValues[func][[All, 1]]; 


parametersMatchQ[params_List, args_Association] := 
Module[{argNames, requaredParameters, optionalParameters}, 
	requaredParameters = Select[params, #Default === None&][[All, "Name"]]; 
	optionalParameters = Select[params, #Default =!= None&][[All, "Name"]]; 
	argNames = Keys[args]; 
	
	And[
		SubsetQ[argNames, requaredParameters], 
		SubsetQ[optionalParameters, Complement[argNames, requaredParameters]]
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


convert[_, _][arg_] := arg; 


callFunc[func_Symbol, args_Association] := 
Module[{params = selectSignaure[func, args], values = {}}, 
	values = Table[
		If[KeyExistsQ[args, p["Name"]], 
			convert[{p["Type"], p["Test"]}][args[p["Name"]]], 
			Nothing
		], 
		{p, params}
	];
	func @@ values
]; 


End[]; 


EndPackage[]; 