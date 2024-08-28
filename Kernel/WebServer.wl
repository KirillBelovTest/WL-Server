(* :Package: *)

BeginPackage["KirillBelov`WolframWebServer`", {
    "KirillBelov`CSockets`", 
    "KirillBelov`Internal`", 
    "KirillBelov`Objects`", 
    "KirillBelov`TCPServer`", 
    "KirillBelov`HTTPHandler`", 
    "KirillBelov`WebSocketHandler`", 
    "KrillBelov`WolframWebServer`GETFile`", 
    "KrillBelov`WolframWebServer`API`", 
    "KirillBelov`WolframWebServer`WebKernel`"
}]; 


WebServer::usage = 
"WebServer[] pre-configured web server."; 


Begin["`Private`"]; 


CreateType[WebServer, init, {"Port" :> 8000, "Socket", "Listener", "TCP", "HTTP", "WebSocket", "Public" :> {Directory[]}, "APIContext" :> "Global`", "Kernels" -> <||>}]; 


WebServer[port_?IntegerQ, opts: OptionsPattern[{WebServer}]] /; 
Positive[port] := 
WebServer["Port" -> port]; 


WebServer /: init[server_WebServer] := 
With[{
    port = server["Port"], 
    socket = CSocketOpen[server["Port"]], 
    tcp = TCPServer[], 
    http = HTTPHandler[], 
    ws = WebSocketHandler[], 
    ltp = LTPHandler[]
}, 
    server["Socket"] = socket; 
    server["Listener"] = SocketListen[socket, tcp@#&]; 
    server["HTTP"] = http; 
    server["WebSocket"] = ws; 
    server["LTP"] = ltp; 

    AddHTTPHandler[tcp, http]; 
    AddWebSocketHandler[tcp, ws]; 
    AddLTPHandler[tcp, ltp]; 

    configure[server, http]; 
    configure[server, ws]; 
    configure[server, ltp]; 

    Return[server]
]; 


WebServer /: configure[server_WebServer, http_HTTPHandler] := (
    http["Deserializer"] = httpDeserialize; 
    http["Serializer"] = httpSerialize; 
    http["MessageHandler", "API"] = apiRequestQ[server["APIContext"]] -> api[server["APIContext"]]; 
    http["MessageHandler", "GETFile"] = getFileRequestQ[server["Public"]] -> getFile[server["Public"]]; 
); 


WebServer /: configure[server_WebServer, ws_WebSocketHandler] := (
    ws["Deserializer"] = webSocketDeserialize; 
    ws["Serializer"] = webSocketSerialize; 
    ws["MessageHandler", "Evaluate"] = evaluateFrameQ[server["Kernels"]] -> evaluate[server["Kernels"]]; 
    ws["MessageHandler", "Callback"] = callbackFrameQ[server["Kernels"]] -> callback[server["Kernels"]]; 
); 


End[]; 


EndPackage[]; 
