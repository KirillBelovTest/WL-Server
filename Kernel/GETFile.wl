(* ::Package:: *)

BeginPackage["KirillBelov`WolframWebServer`GTEFile`", {
	"JerryI`WLX`"
}]; 


Needs["KirillBelov`WolframWebServer`MIMETypes`"]; 


getFileRequestQ::usage = 
"getFileRequestQ[request] condition for http-request."; 


getFile::usage = 
"getFile[request, public] return file."; 


Begin["`Private`"]; 


getFileRequestQ[public: {__String}][request_Association] := 
getFileRequestQ[request, public]; 


getFileRequestQ[request_Association, public: {__String}] := 
request["Method"] === "GET" && 
fileExistsInDirectoriesQ[urlPathToFileName[request["Path"]], public]; 


getFile[public: {__String}][request_Association] := 
getFile[request, public]; 


getFile[request_Association, public: {__String}] := 
Module[{urlPath, fileName, fullFileName, fileData, fileExt, mimeType}, 
    urlPath = request["Path"]; 
    fileName = urlPathToFileName[urlPath]; 
    fullFileName = firstFileInDirectory[fileName, public]; 
    fileExt = FileExtension[fullFileName]; 
    mimeType = $getMIMEType[fullFileName]; 
    fileData = Import[fullFileName, "String"]; 

    <|
        "Body" -> fileData, 
        "Code" -> 200, 
        "Headers" -> <|
            "Content-Type" -> mimeType, 
            "Content-Length" -> Length[fileData], 
            "Connection"-> "Keep-Alive", 
            "Keep-Alive" -> "timeout=5, max=1000", 
            "Cache-Control" -> "max-age=60480"
        |>
    |>
]; 


(*Internal*)


getMIMEType[file_String] := 
Module[{ext, type}, 
    ext = FileExtension[file]; 
    type = $mimeTypes[ext]; 
	If[!StringQ[type], 
        "application/octet-stream", 
        type
    ]
]; 


urlPathToFileName[urlPath_String] := 
FileNameJoin[FileNameSplit[StringTrim[urlPath, "/"]]]; 


fileExistsInDirectoriesQ[fileName_String, directories: {__String}] := 
AnyTrue[Map[FileNameJoin[{#, fileName}]&, directories], FileExistsQ]; 


firstFileInDirectory[fileName_String, directories: {__String}] := 
SelectFirst[Map[FileNameJoin[{#, fileName}]&, directories], FileExistsQ]; 


End[]; 


EndPackage[]; 
