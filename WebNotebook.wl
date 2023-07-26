(* ::Package:: *)

(* ::Section:: *)
(*Begin package*)


BeginPackage["$PublisherID`WebNotebook`", 
	{"KirillBelov`Objects`"}
];


(* ::Section:: *)
(*Names*)


WebNotebook::usage = 
"WebNotebook[id] web notebook representation.";


WebNotebookAddCell::usage = 
"WebNotebookAddCell[nb, cell]"; 


WebNotebookRemoveCell::usage = 
"WebNotebookRemoveCell[nb, cell]"; 


WebCell::usage = 
"WebCell[type, content, lang] web cell representation.";


(* ::Section:: *)
(*Begin private*)


$WebNotebooks = <||>; 


(* ::Section:: *)
(*Notebook*)


Begin["`Private`"];


CreateType[WebNotebook, initWebNotebook, {
	"Id", 
	"Name", 
	"File", 
	"Evaluator" -> evaluate, 
	"Channel" -> WebSocketChannel, 
	"Cells" -> <||>
}]; 


WebNotebook[name_String] := 
WebNotebook["Name" -> name]


WebNotebookAddCell[nb_WebNotebook, cellId_String, cell_WebCell] := (
	cell["Notebook"] = nb; 
	nb["Cells", cellId] = cell; 
); 


WebNotebookAddCell[nb_WebNotebook, cell_WebCell] := 
WebNotebookAddCell[nb, cell["Id"], cell]; 


WebNotebookAddCell[nb_WebNotebook] := 
WebNotebookAddCell[nb, WebCell[]]; 


(* ::Section:: *)
(*Cell*)


CreateType[WebCell, initWebCell, {
	"Id", 
	"Language", 
	"Type", 
	"Input", 
	"Output", 
	"Previous", 
	"Next", 
	"Content", 
	"Notebook"
}]; 


(* ::Section:: *)
(*Internal*)


initWebNotebook[nb_WebNotebook] := (
	nb["Id"] = CreateUUID["WEBNOTEBOOK-"]; 
	nb["File"] = FileNameJoin[{Directory[], 
		If[nb["Name"] == Automatic, 
			nb["Id"], 
		(*Else*)
			nb["Name"]
		] 
	}]; 
); 


initWebCell[cell_WebCell] := (
	cell["Id"] = CreateUUID["WEBCELL-"]; 
); 


publishCell[cell_WebCell] := 



(* ::Section:: *)
(*End*)


End[]; 


(* ::Section:: *)
(*End package*)


EndPackage[]; 
