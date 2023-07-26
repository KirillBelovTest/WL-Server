PathToFunc[path_] := Symbol[FileNameSplit[path][[-1]]]


getDate = APIFunction[{}, DateString[]]