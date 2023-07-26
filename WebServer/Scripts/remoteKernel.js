document.addEventListener("keypress", sendCode)

getSocket()

function isKeyPressed(event) {
    if (event.key === "Enter" && event.shiftKey && event.target.tagName === "CODE" && event.target.getAttribute("contenteditable")){
        console.log("shift enter was pressed");
        return true
    }
    return false;
}

function getSocket(){
    if (document.socket === undefined){
        let host = document.location.host; 
        let url = "ws:" + "//" + host; 
        document.socket = new WebSocket(url);
        document.socket.onmessage = addOutput;
    }
    return document.socket;
}

function addOutput(event){
    let data = JSON.parse(event.data);
    let input = document.getElementById(data.Id); 
    let output = input.cloneNode(true);
    output.id = uuidv4(); 
    output.innerHTML = interpretate(data.Result);
    input.after(output);
    console.log(output);
}

function sendCode(event){
    if (isKeyPressed(event) && document.socket != undefined){
        event.preventDefault(); 
        document.socket.send(JSON.stringify({code: event.target.innerText, id: event.target.id}));
    }
}

function uuidv4() {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
}

function interpretate(json){
    return new Expression(JSON.parse(json)).evaluate();
}

let System = new Object();

class Expression {
  
    constructor(json) {
      if (typeof(json) == "string" || typeof(json) == "number" || typeof(json) == "boolean"){
        this.type = "atom"; 
        this.value = json
      } else {
        this.type = "expr"; 
        this.head = json[0]; 
        this.parts = json.slice(1).map((x) => new Expression(x));
      }
    }
  
    evaluate(){
      if (this.type == "atom"){
        return this.value; 
      } else {
        if (System[this.head] != undefined){
          let func = System[this.head];
          let args = this.parts.map((x) => x.evaluate()); 
          return func(...args); 
        } else {
          return this;
        }
      }
    }
  }

  System.List = function (...args) {
    return args;
  }

  System.Line = function(...args) {
    let obj = new Object(); 
    obj.type = "line"; 
    obj.points = args;
    return obj;
  }

  System.Graphics = function (...args) {
    let element = document.createElement("canvas");
    element.setAttribute("width", 300);
    element.setAttribute("heght", 200);
    let points = args[0].points;
    let minX = Math.min(...points[0].map((p) => p[0]));
    let maxX = Math.max(...points[0].map((p) => p[0]));
    let minY = Math.min(...points[0].map((p) => p[1]));
    let maxY = Math.max(...points[0].map((p) => p[1]));
    let ctx = element.getContext("2d"); 
    points = [points[0].map((p) => [300 * (p[0] - minX) / (maxX - minX), 200 * (p[1] - minY) / (maxY - minY)])];
    ctx.beginPath();
    ctx.moveTo(points[0][0][0], 200 - points[0][0][1]);
    for (let i = 1; i < points[0].length; i++){
     ctx.lineTo(points[0][i][0], 200 - points[0][i][1]);
    }
    ctx.stroke();
    return element;
  }