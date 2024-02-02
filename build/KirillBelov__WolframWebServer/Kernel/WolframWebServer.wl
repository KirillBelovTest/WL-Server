(* ::Package:: *)

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


Get["KirillBelov`WolframWebServer`APIFunc`"]; 


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
    http["MessageHandler", "Options"] = optionsQ -> options[server]; 
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


optionsQ[request_Association] := 
request["Method"] === "OPTIONS"; 


options[server_WebServer][request_Association] := 
options[server, request]; 


WebServer /: options[server_WebServer, request_Association] := 
<|
    "Code" -> 200, 
    "Message" -> "OK", 
    "Headers" -> <|
        "Date" -> DateString[], 
        "Accept" -> "*/*", 
        "Server" -> "Wolfram Web Server", 
        "Access-Control-Allow-Origin" -> request["Headers", "Origin"], 
        "Access-Control-Allow-Methods" -> "GET, POST, OPTIONS", 
        "Access-Control-Allow-Headers" -> request["Headers", "Access-Control-Request-Headers"], 
        "Access-Control-Max-Age" -> 86400, 
        "Content-Length" -> 0, 
        "Keep-Alive" -> "timeout=2, max=100", 
        "Vary" -> "Accept-Encoding, Origin", 
        "Connection" -> "keep-alive"
    |>, 
    "Body" -> ""
|>


apiRequestQ[request_Association] := 
StringMatchQ[request["Path"], "/api/" ~~ __, IgnoreCase -> True]


getArgs[request_Association] := 
Which[
    request["Method"] === "GET", 
        request["Query"], 
    
    request["Method"] === "POST" && 
    Length[request["Body"]] > 0 && 
    request["Headers", "Content-Type"] === "application/json", 
        request["Query"] ~ Join ~ ImportByteArray[request["Body"], "RawJSON"], 
    
    True, 
        request["Query"]
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
    APIFunc[Symbol[func], args]
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
Import[urlPathToFileName[server["PublicDirectory"], request], "String"]; 


getIndexQ[request_Association] := 
request["Method"] === "GET" && 
request["Path"] === "/"; 


getIndex[server_][request_] := 
getIndex[server, request]; 


WebServer /: getIndex[server_WebServer, request_Association] := 
getFile[server, <|"Path" -> "/index.html"|>]; 


End[]; 


EndPackage[]; 
