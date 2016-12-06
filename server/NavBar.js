var widgetIDs=[];
$(document).ready(function(){
	var getUrlParameter = function getUrlParameter(sParam) {
	    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
	        sURLVariables = sPageURL.split('&'),
	        sParameterName,
	        i;

	    for (i = 0; i < sURLVariables.length; i++) {
	        sParameterName = sURLVariables[i].split('=');

	        if (sParameterName[0] === sParam) {
	            return sParameterName[1] === undefined ? true : sParameterName[1];
	        }
	    }
	};
	
	if(getUrlParameter("email")=="Verified"){
		alert("Account Successfully Verified");
	}else if(getUrlParameter("email")=="Fail"){
		alert("Account Verrification Failed");
	}
	
	
$("navDropDown").hover(function(){
$(this).parent().find('.btn').addClass("hovered");

}, function(){
$(this).parent().find('.btn').removeClass("hovered");

});
});

function resetCaptcha(){

widgetIDs.forEach(function(entry) {
	grecaptcha.reset(entry);
});
/*document.getElementById("captcha-here").innerHTML="";
 grecaptcha.render('captcha-here', {
          'sitekey' : '6LeRigUTAAAAAFRUJj20feP_CtENCcAh0j39uYFx',
'data-theme':'dark'
        });
*/

$("#captcha-here-login").css({
	padding:0,
	margin:0,
	left:"-20px",
	top:"0px",
	position:"relative"
	});
	$("#captcha-here-login").find("div").first().css({
	display:"block",
	width:"152px",
	height:"39px"
	});
	$("#captcha-here-login").find("div").first().find("div").first().css({
	transform: "scale(0.5, 0.5)"
	});
	$("#captcha-here-login").find("div").first().find("div").first().find("iframe").first().css({
	height:"78px",
	width:"304px",
	position:"relative",
	transform: "translate(-76px, -39px)",
	display:"block",
	padding: "0px",
	margin: "0px"
	});
	$("#captcha-here-login").find("div").first().find("div").first().find("iframe").first().contents().find("body").css({
		transform: "scale(0.5, 0.5) translate(-76px, -39px)"
		});
	
	$("#captcha-here-register").css({
		padding:0,
		margin:0,
		left:"-20px",
		top:"0px",
		position:"relative"
		});
		$("#captcha-here-register").find("div").first().css({
		display:"block",
		width:"152px",
		height:"39px"
		});
		$("#captcha-here-register").find("div").first().find("div").first().css({
		transform: "scale(0.5, 0.5)"
		});
		$("#captcha-here-register").find("div").first().find("div").first().find("iframe").first().css({
		height:"78px",
		width:"304px",
		position:"relative",
		transform: "translate(-76px, -39px)",
		display:"block",
		padding: "0px",
		margin: "0px"
		});

		$("#captcha-here-register").find("div").first().find("div").first().find("iframe").first().contents().find("body").css({
		transform: "scale(0.5, 0.5) translate(-76px, -39px)"
		});
}
