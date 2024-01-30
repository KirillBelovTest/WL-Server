(* :Package: *)

Once[PacletInstall["KirillBelov/Internal"]]; 
Once[PacletInstall["KirillBelov/Objects"]]; 
Once[PacletInstall["KirillBelov/CSockets"]]; 
Once[PacletInstall["KirillBelov/TCPServer"]]; 
Once[PacletInstall["KirillBelov/HTTPHandler"]]; 
Once[PacletInstall["KirillBelov/WebSocketHandler"]]; 
Once[PacletInstall["JerryI/WLX"]]; 
Once[PacletInstall["JerryI/WSP"]]; 


BeginPackage["KirillBelov`WolframWebServer`", {
    "KirillBelov`Internal`", 
    "KirillBelov`Objects`", 
    "KirillBelov`CSockets`", 
    "KirillBelov`TCPServer`", 
    "KirillBelov`HTTPHandler`", 
    "KirillBelov`HTTPHandler`Extensions`", 
    "KirillBelov`WebSocketHandler`", 
    "KirillBelov`WebSocketHandler`Extensions`", 
    "JerryI`WLX`", 
    "JerryI`WSP`"
}]; 


Get["KirillBelov`WolframWebServer`FuncResolver`"]; 


CreateWebServer::usage = 
"CreateWebServer[port] creates web server that works on specific port."; 


WebServer::usage = 
"WebServer[] pre-configured web server."; 


Begin["`Private`"]; 


CreateType[WebServer, TCPServer, {
    "Port", 
    "Socket", 
    "Listener", 
    "HTTP", 
    "PublicDirectory" -> "public", 
    "APIContext" -> "Global`"
}]; 


CreateWebServer[port_Integer, opts: OptionsPattern[{WebServer}]] := 
start[WebServer["Port" -> port, opts]]; 


WebServer /: start[server_WebServer] := 
With[{
    http = HTTPHandler[], 
    port = server["Port"]
}, 
    configure[server, http]; 

    server["HTTP"] = http; 
    server["CompleteHandler", "HTTP"] = HTTPPacketQ -> HTTPPacketLength;
    server["MessageHandler", "HTTP"] = HTTPPacketQ -> http; 
    server["Socket"] = CSocketOpen[port]; 
    server["Listener"] = SocketListen[server["Socket"], server@#&]; 
    
    Return[server]
]; 


(*
    1. Get HTML
    2. Get folders
    3. Get WSP
    4. Get WLX
    5. Get resources css/js/png/svg/jpg/..
    6. Post files and data
    7. Func API
*)


configure[server_WebServer, http_HTTPHandler] ^:= (
    http["MessageHandler", "GETFile"] = getFileQ -> getFile[server]; 
    http["MessageHandler", "GETIndex"] = getIndexQ -> getIndex[server]; 
    http["MessageHandler", "API"] = apiRequestQ -> apiFunc[server]; 
    http["MessageHandler", "POSTAction"] = postActionQ -> postAction[server]; 
); 


(*request: <|
    "Path" -> "/path", 
    "Query" -> <|"name" -> "name", "id" -> 1|>, 
    "Method" -> "GET", 
    "Headers" -> <|
        "Content-Type" -> "application/json", 
        "Connection" -> "keep-alive"
    |>, 
    "Body" -> ByteArray[<>]
|>*)


apiRequestQ[request_Association] := 
StringMatchQ[request["Path"], "/api/" ~~ __, IgnoreCase -> True]


getArgs[request_Association] := 
Which[
    request["Method"] === "GET", 
        request["Query"], 
    
    request["Method"] === "POST" && 
    Length[request["Body"]] > 0, 
        request["Query"] ~ Join ~ ImportByteArray[request["Body"], "RawJSON"]
]; 


apiFunc[server_][request_] := 
apiFunc[server, request]; 


WebServer /: apiFunc[server_WebServer, request_Association] := 
With[{
    func = server["APIContext"] <> 
        StringRiffle[StringSplit[
            StringTrim[StringTrim[request["Path"], "/"], "api/"], 
        "/"], "`"], 
    args = getArgs[request]
}, 
    Echo[request, "Request"]; 
    Echo[func, "Call"]; 
    Echo[args, "Args"];
    Echo[request, "Request"]; 
    callFunc[Symbol[func], args]
]; 


$supportedExtensions = {
    "txt", "html", "css", "js", "svg", "jpg", "png", "wsp", "wlx", "wl"
}; 


getFileQ[request_Association] := 
request["Method"] === "GET" && 
StringMatchQ[request["Path"], "/" ~~ __ ~~ "." ~~ $supportedExtensions, IgnoreCase -> True]; 


urlPathToFileName[publicDirectory_String, request_Association] := 
FileNameJoin[Join[{Directory[], publicDirectory}, StringSplit[StringTrim[request["Path"], "/"], "/"]]]; 


getFile[server_][request_] := 
getFile[server, request]; 


WebServer /: getFile[server_WebServer, request_Association] := 
Import[urlPathToFileName[publicDirectory_String, request], "String"]; 


getIndexQ[request_Association] := 
request["Method"] === "GET" && 
request["Path"] === "/"; 


getIndex[server_][request_] := 
getIndex[server, request]; 


WebServer /: getIndex[server_WebServer, request_Association] := 
getFile[server, <|"Path" -> "/index.html"|>]; 


End[]; 


EndPackage[]; 
