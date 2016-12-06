var logged=false;
$(document).ready(function(){
var loadingGif="http://www.multistructuresng.com/images/ring.gif";
$(document.body).prepend("<div class='loading' style='display:none; opacity:0.3'><img src='"+loadingGif+"' height='200px' width='200px'></img></div>");
if(!logged){
$(".login").css("display", "none");
$(".logot").css("display", "initial");
}else{
$(".login").css("display", "initial");
$(".logot").css("display", "none");
}

$("#formPass").submit(function(event){
loginRequest();
event.preventDefault();
resetCaptcha();
});
$("#formReg").submit(function(event){
	registerRequest();
	event.preventDefault();
resetCaptcha();
	});
});


var registerCaptchaResponse="";
var loginCaptchaResponse="";

function captchalogincallback(response){
	loginCaptchaResponse=response;
}

function captcharegistercallback(response){
	registerCaptchaResponse=response;
}

function loginRequest(){
//display loading
displayLoading();
(!usingCaptcha) ? websocket.send("Login: "+$("#U").val()+":"+$("#P").val()) : websocket.send("Login: "+$("#U").val()+":"+$("#P").val()+":"+loginCaptchaResponse);
//alert("Login: "+$("#U").val()+":"+$("#P").val());
}
function registerRequest(){
	displayLoading();
	websocket.send("Register: "+$("#U2").val()+":"+$("#P2").val()+
			":"+$("#P3").val()+":"+$("#N").val()+":"+$("#E").val()+
			":"+registerCaptchaResponse);
	
}
function badLogin(){
Alert("Invalid Login");
}
function goodLogin(){
//Alert("YAY");

logged=true;
$(".login").css("display", "initial");
$(".logot").css("display", "none");
retrieve();
$("#U").val("");
$("#P").val("");
}
