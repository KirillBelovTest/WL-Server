window.WSPHttpQuery = (command, promise, type = "String") => {
    var http = new XMLHttpRequest();
    var url = 'http://'+window.location.hostname+':'+window.location.port+'/utils/query.wsp';
    var params = 'command='+encodeURI(command)+'&type='+type;
  
    console.log(params);
    http.open('GET', url+"?"+params, true);
  
    //Send the proper header information along with the request
    http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    if (type == "ExpressionJSON" || type == "JSON") {
      http.onreadystatechange = function() {//Call a function when the state changes.
        if(http.readyState == 4 && http.status == 200) {
          console.log("RESP: " + http.responseText);
          // http.responseText will be anything that the server return
          promise(JSON.parse(http.responseText));
          document.getElementById('logoFlames').style = "display: none";
          document.getElementById('bigFlames').style = "opacity: 0";
          
        }
      };
    } else {
      http.onreadystatechange = function() {//Call a function when the state changes.
        if(http.readyState == 4 && http.status == 200) {
          console.log("RESP: " + http.responseText);
      
          // http.responseText will be anything that the server return
          promise(http.responseText);
          document.getElementById('logoFlames').style = "display: none";
          document.getElementById('bigFlames').style = "opacity: 0";
        }
      };
    }

    document.getElementById('logoFlames').style = "display: block";
    document.getElementById('bigFlames').style = "opacity: 0.1";
    http.send(null);
  }

  window.WSPHttpBigQuery = (command, promise, type = "String") => {

  var url = 'http://'+window.location.hostname+':'+window.location.port+'/utils/post.wsp';

  const formData = new FormData();
  formData.append('command', command);


  const request = new XMLHttpRequest();

  request.onreadystatechange = ()=>{
    if (request.readyState === 4) {
      console.log(request.responseText);

        if (request.responseText == 'Ok!') {
          promise.resolve();
        } else {
          promise.reject();
        }
    }    
    }

  request.open("POST", url);
  request.send(formData);
  }