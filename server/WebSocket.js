var websocket;
var url="wss://bamapp.net:8443/WindowMe/WindowMeClient";
var currentCodeQ="";
var currentCode="";
var startingHTML;
var usingCaptcha=false;
function initializeWebSocket(){
	websocket=new WebSocket(url);
	 websocket.onopen = function(evt) { onOpen(evt) };
    websocket.onclose = function(evt) { onClose(evt) };
    websocket.onmessage = function(evt) { onMessage(evt) };
    

    $(document).ready(function(){
    	startingHTML=document.getElementById("Save").innerHTML;

    	$(".namingHolder").fadeOut(0);
    	
    	$(".naming").submit(function(event){
    		
    		store($("#name").val(),currentCode);
    		event.preventDefault();

    	});
    	
    $("#formCode").submit(function(event){
  
    checkCode(document.getElementById("Code").value);
event.preventDefault();
});
    });
}
function checkCode(code){
websocket.send("Code: "+code);
displayLoading();
currentCodeQ=code;
}
function displayLoading(){
$(".loading").fadeIn();
}
function hideLoading(){
$(".loading").fadeOut();
}
function onOpen(evt){

}

function onClose(evt){


}
function Alert(data){
alert(data);
}
function onMessage(evt){

if(evt.data=="Invalid"){
hideLoading();
Alert("Invalid Code");
}else if(evt.data=="Ready"){
hideLoading();
currentCode=currentCodeQ;
$(".namingHolder").fadeIn(0);
$(".noImage").fadeOut();
$(".Image").fadeIn();
getNewImage();

}
else if(evt.data=="BadCombo"){
//console.log(evt.data);
hideLoading();
badLogin();
}
else if(evt.data=="Success"){
hideLoading();
goodLogin();
}
else if(evt.data=="STORED"||evt.data=="DELETED"){
	retrieve();
	}
else if(evt.data.substring(0,1)=="{"){
	got(evt.data);
	}
else if(evt.data=="NeedCaptcha"){
usingCaptcha=true;
$("#captcha-holder").css({display:"block"});
}else if(evt.data.substring(0,7)=="Message"){
	hideLoading();
	alert(evt.data.substring(8));
}
else{
var data=evt.data;
document.getElementById('Contain').setAttribute('src', 'data:image/png;base64,'+data);
getNewImage();

}

}


function getNewImage(){

websocket.send("ready");

}


function displayNewImage(){


}

function Prompt(message, callback){
callback(prompt(message));

}
function save(){
Prompt("Enter a name please", function(name){store(name, currentCode)})
}




function store(name, id){

	websocket.send("Add: "+name+":"+id);
}
function htmlEncode(value){
	  //create a in-memory div, set it's inner text(which jQuery automatically encodes)
	  //then grab the encoded contents back out.  The div never exists on the page.
	  return value.split(' ').join('q').split("'").join('h');
	}
function remove(id){
	$("#R").removeClass("hovered");

websocket.send("Delete: "+id);

}

function retrieve(){

	websocket.send("List");
}
function addRow(name, id, number){
	var code=htmlEncode(name+number);
	$('#Save').prepend("<a style='padding-right:0;' id='"+code+"abc'> "+name+" <input id='"+code+"' type='button' value='Delete' style='float:right; background-color:red; padding:0; text-align:center; display:inline-block; width:55px; font-size:7pt; top:-10px; height:44px; cursor:pointer; position:relative;'></input></a>");
$("#"+code).click(function(){
	remove(name);
});
$("#"+code+"abc").click(function(){
checkCode(id);
});
}

function got(json){
	//alert("IVE GOT ME A JSON");
	console.log(json);
	
	var nameVisible=$(".namingHolder").is(':visible');
	var jsonParsed=JSON.parse(json);
	$('#Save').html(startingHTML);
	if(!nameVisible){
		$(".namingHolder").fadeOut(0);
	}
	$(".naming").submit(function(event){
		
		store($("#name").val(),currentCode);
		event.preventDefault();

	});
	
	for(var i=0; i<jsonParsed.Array.length; i++){
		
		addRow(jsonParsed.Array[i].Name, jsonParsed.Array[i].ID, i.toString());
		
	}
}

