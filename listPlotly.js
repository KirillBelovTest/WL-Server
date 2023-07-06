let dataFilesUl = document.getElementById("data-files")

let dataFiles = getDataFiles();

for (const file of dataFiles) {
    let li = document.createElement("li"); 
    li.innerHTML = "<a href=\"#" + file + "\">" + file + "</a>";
    li.onclick = () => listPlotly(file);
    dataFilesUl.appendChild(li);
}

function listPlotly(file){
    let listPlotlyDiv = document.getElementById("list-plotly"); 
    let data = getDataFilePoints(file); 
    
    let layout = {
        autosize: false,
        width: 500,
        height: 300,
        margin: {
          l: 50,
          r: 50,
          b: 40,
          t: 40,
          pad: 4
        }
      };

    Plotly.newPlot(listPlotlyDiv, [data], layout);
}

function httpGet(theUrl)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", theUrl, false ); 
    xmlHttp.send( null );
    return xmlHttp.responseText;
}

function currentEndpoint(){
    let protocol = window.location.protocol;
    let host = window.location.host;
    let port = window.location.port;
    let endpoint = protocol + '//' + host;
    return endpoint;
}

function getDataFiles(){
    return JSON.parse(httpGet(currentEndpoint() + "/api/getDataFiles?format=JSON"));
}

function getDataFilePoints(file){
    return JSON.parse(httpGet(currentEndpoint() + "/api/getDataFilePoints?file=" + file + "&format=JSON"));
}