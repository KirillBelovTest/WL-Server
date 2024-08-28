(* ::Package:: *)

BeginPackage["KirillBelov`WolframWebServer`WebKernel`", {
	"KirillBelov`Objects`", 
	"KirillBelov`CSockets`", 
	"KirillBelov`TCPServer`", 
	"KirillBelov`WebSocketHandler`"
}]; 


WebKernel::usage = 
"WebKernel[port] remote web socket kernel representation."; 


Begin["`Private`"]; 


CreateType[WebKernel, {"Link", "Port", "CallbackPort"}]; 


WebKernel[port_?IntegerQ, callbackPort_?IntegerQ] := 
Module[{link}, 
	link = LinkLaunch[First[$CommandLine] <> " -wstp"]; 
	waitForWrite[link, $webKernelTimeout]; 
	LinkWrite[link, kernelInitPacket[port, callbackPort]]; 
	waitForWrite[link, $webKernelTimeout]; 
	WebKernel["Link" -> link, "Port" -> port, "CallbackPort" -> callbackPort]
]; 


WebKernel /: Close[kernel_WebKernel] := 
LinkClose[kernel]; 


WebKernel::notready = 
"kernel not ready."; 


$webKernelTimeout = 60; 


kernelInitPacket[port_Integer, callbackPort_Integer] = 
Unevaluated[EnterExpressionPacket[
	Get["KirillBelov`CSockets`"]; 
	Get["KirillBelov`TCPServer`"]; 
	Get["KirillBelov`WebSocketHandler`"]; 
	
	Function[{tcp, ws, connection}, 
		tcp["CompleteHandler", "WebSocket"] = WebSocketPacketQ -> WebSocketLength; 
		tcp["MessageHandler", "WebSocket"] = WebSocketPacketQ -> ws; 

		ws["MessageHandler", "Evaluate"] = Function[True] -> Function[{client, data}, 
            WriteString[client, ExportByteArray[ImportByteArray[data, "WL"], "ExpressionJSON"]]
        ]; 

		SocketListen[KirllBelov`CSockets`CSocketOpen[port], Function[tcp@#]]
	][TCPServer[], WebSocketHandler[], WebSocketConnect[callbackPort]]
]]; 


waitForReady[link_LinkObject, timeout_Integer: 60] := 
TimeConstrained[While[!LinkReadyQ[link], Pause[0.001]], timeout, Message[WebKernel::notready]; $Failed]


waitForWrite[link_LinkObject, timeout_Integer: 60] := (
	waitForReady[link, timeout]; 
	While[Head[LinkRead[link]] =!= InputNamePacket, Null]; 
);



End[]; 


EndPackage[]; 
