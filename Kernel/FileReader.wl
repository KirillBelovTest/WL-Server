(* :Package: *)

BeginPackage["KirillBelov`WolframWebServer`FileReader`"]; 


ImportFile::usage = 
"ImportFile[request, settings] imports file.
ImportFile[settings] returns pure func.";  


Begin["`Private`"]; 


ImportFile[request_Association, settings_Association] := 
Module[{file}, 
    file = getFilePath[request, settings]; 

]; 


ImportFile[settings_Association] := 
ImportFile[#, settings]&; 


getFilePath[request_Association, settings_Association] := 
Module[{file, files}, 
    file = FileNameSplit[StringTrim[request["Path"], "/"]]; 
    files = Map[FileNameJoin[Flatten[{#, file}]]&, settings["Directories"]]; 
    SelectFirst[files, FileExistsQ]
]; 


End[]; 


EndPackage[]; 
