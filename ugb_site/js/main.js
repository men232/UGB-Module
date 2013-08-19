// Stolen from ulx and converted to js :)
function convertTime( seconds ){			
	var years = Math.floor( seconds / 31536000 );
	seconds = seconds - ( years * 31536000 );
	var days = Math.floor( seconds / 86400 );
	seconds = seconds - ( days * 86400 );
	var hours = Math.floor( seconds/3600 );
	seconds = seconds - ( hours * 3600 );
	var minutes = Math.floor( seconds/60 );
	seconds = seconds - ( minutes * 60 );
	var curtime = "";
	if( years != 0 ){ curtime = curtime + years + " year" + ( ( years > 1 ) ? "s, " : ", " ) };
	if( days != 0 ) { curtime = curtime + days + " day" + ( ( days > 1 ) ? "s, " : ", " ) };
	curtime = curtime + ( ( hours < 10 ) ? "0" : "" ) + hours + ":";
	curtime = curtime + ( ( minutes < 10 ) ? "0" : "" ) + minutes + ":";
	return curtime + ( ( seconds < 10 ? "0" : "" ) + seconds );
}

// This function need jquery.
function updateBansInfo(){
	var unixTime = Math.round(serverdate.getTime() / 1000);

	$( ban_lents ).html(function(index) {
		if( $( ban_lents[index] ).attr('length') == 0 ){
			return GetPermaBannedHTML();
		};

		var time = $( ban_lents[index] ).attr('length') - unixTime + time_add;

		if ( time <= 0 ){
			return GetUnBannedHTML();
		}else{
			return convertTime(time);
		};
	});
};

// A function to show server timme.
function showServerTime(){
	$( '#servertime' ).text(function(index) {
		return serverdate.toLocaleDateString()+' - '+serverdate.toLocaleTimeString();
	});
};

// Real-Time ban len refresh.
for (var i = 1; i <= ban_count; i++) {
	ban_lents[i] = '#b_len_'+i;
};

updateBansInfo();
showServerTime();

$(window).load(function () {
	setInterval(function(){
		serverdate.setSeconds(serverdate.getSeconds()+1);
		updateBansInfo();
		showServerTime();
	}, 1000);
});