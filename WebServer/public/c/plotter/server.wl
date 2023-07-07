plotData = {{0,0}};

EventBind["DroppedFile", Function[file,
    plotData = Drop[ImportString[file["data"] // BaseDecode // ByteArrayToString, "TSV"], 3];
]]