function press_button() 
{
	document.getElementById("button_up").style.visibility="hidden";
	$.ajax({type: "POST",
	    data: "",
	    dataType: "text",
	    cache: false,
	    url: "/press_button",
	    success: function(r) {
	    },
	    error: function(s, xhr, status, e) {
		console.log("POST failed: " + s.responseText);
	    }
	   });
}

function release_button() 
{
	document.getElementById("button_up").style.visibility="visible";
	$.ajax({type: "POST",
	    data: "",
	    dataType: "text",
	    cache: false,
	    url: "/release_button",
	    success: function(r) {
	    },
	    error: function(s, xhr, status, e) {
		console.log("POST failed: " + s.responseText);
	    }
	   });
}



document.ontouchmove = function(event){
   		event.preventDefault();
	}

document.ontouchstart = function(event){
   		event.preventDefault();
	}


