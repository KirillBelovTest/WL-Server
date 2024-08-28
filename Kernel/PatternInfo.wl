(* :Package: *)

BeginPackage["KirillBelov`WolframWebServer`PatternInfo`"]; 


PatternInfo::usage = 
"PatternInfo[pattern] returns information about the pattern as association."; 


Begin["`Private`"]; 


(*x_ | x_Type*)
PatternInfo[Verbatim[Pattern][name_Symbol, Verbatim[Blank][type_Symbol: None]]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> None, 
	"Test" -> None, 
	"Value" -> None
|>; 


(*x: _?test | x: _Type?test*)
PatternInfo[Verbatim[Pattern][name_Symbol, Verbatim[PatternTest][Verbatim[Blank][type_Symbol: None], test_]]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> None, 
	"Test" -> test, 
	"Value" -> None
|>; 


(*x_: default | x_Type: default*)
PatternInfo[Verbatim[Optional][Verbatim[Pattern][name_Symbol, Verbatim[Blank][type_Symbol: None]], defaultValue_]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> defaultValue, 
	"Test" -> None, 
	"Value" -> None
|>; 


(*x_?test | x_Type?test*)
PatternInfo[Verbatim[PatternTest][Verbatim[Pattern][name_Symbol, Verbatim[Blank][type_Symbol: None]], testFunc_]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> None, 
	"Test" -> testFunc, 
	"Value" -> None
|>; 


(*x: _?test: default | x: _Type?test: default*)
PatternInfo[Verbatim[Optional][Verbatim[Pattern][name_Symbol, Verbatim[PatternTest][Verbatim[Blank][type_Symbol: None], testFunc_]], defaultValue_]] := 
<|
	"Name" -> SymbolName[Unevaluated[name]], 
	"Type" -> type, 
	"Default" -> defaultValue, 
	"Test" -> testFunc, 
	"Value" -> None
|>; 


(*expr*)
PatternInfo[value_?AtomQ] := 
<|
	"Name" -> None, 
	"Type" -> Head[value], 
	"Default" -> None, 
	"Test" -> None, 
	"Value" -> value
|>; 


End[]; 


EndPackage[]; 
