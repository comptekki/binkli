-module(main_handler).

-export([init/2]).

-include("binkli.hrl").

%%

init(Req, Opts) ->
  app_front_end(Req, Opts).

%%

app_front_end(Req, Opts) ->
    Host = cowboy_req:host(Req),
    PortInt  = cowboy_req:port(Req),
    Port = list_to_binary(integer_to_list(PortInt)),
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:local_time(),
    Date = lists:flatten(io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w",[Year,Month,Day,Hour,Minute,Second])),
    io:format("~ndate: ~p -> host: ~p : ~p~n", [Date, Host, Port]),

    Req2 = cowboy_req:reply(
	     200,
	     #{ <<"content-type">> => <<"text/html">> },

<<"<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='utf-8'>
<title>BinKli</title>

<meta Http-Equiv='Cache-Control' Content='no-cache'>
<meta Http-Equiv='Pragma' Content='no-cache'>
<meta Http-Equiv='Expires' Content='0'>
<META HTTP-EQUIV='EXPIRES' CONTENT='Mon, 30 Apr 2012 00:00:01 GMT'>

<link rel='icon' href='/static/favicon.ico' type='image/x-icon' />
<link rel=\"stylesheet\" href=\"", ?JQUERYUICSS, "?0\" type=\"text/css\" media=\"screen\" />
<link rel=\"stylesheet\" href=\"", ?CSS, "?0\" type=\"text/css\" media=\"screen\" />
<script type='text/javascript' src='", ?JQUERY, "'></script>
<script type='text/javascript' src='", ?JQUERYUI, "'></script>

<script>

$(document).ready(function(){

  if ('MozWebSocket' in window) {
	WebSocket = MozWebSocket;
  }

  if (!window.WebSocket){
	alert('WebSocket not supported by this browser')
  } else {  //The user has WebSockets

// websocket code from: http://net.tutsplus.com/tutorials/javascript-ajax/start-using-html5-websockets-today/

  var host=
'",
Host/binary,
"';
  var port='",
Port/binary,
"';

  var socket = 0;
  var ws_str = '';

  function wsconnect() {
        socket = new WebSocket(ws_str);
		message(true, socket.readyState);

		socket.onopen = function(){
		//	console.log('onopen called');
			send('client-connected');
			message(true, socket.readyState);
                }


    socket.onmessage = function(m){
//	console.log('onmessage called');

	if (m.data) {
          console.log('m.data: ',m.data);
          com=m.data.split(':');
	  console.log('com: ',com);

          if (com.length > 1) {
            console.log('com.indexOf: ',com[1].indexOf('playstart'));
            if(com[1].indexOf('playstart'>-1)) {
              $('#head').html('Click Binary 1 (BinKli)');
              mkbuts();
	      $('#dialog').html('<br>Click each 1!<br>'+correct+' out of 5 correct!');
            }
          }
	}
	else message(true,m.data)
    } // end socket.onmessage

    socket.onclose = function() {
//	console.log('onclose called')
        message(true,'Socket status: 3 (Closed)');
        setTimeout(function(){wsconnect()}, 5000);
    }

    socket.onerror = function(e) {
	message(true,'Socket Status: '+e.data);
    }

  } // end function wsconnect()

//console.log('host :', host, ' port: ', port);
  
   if(window.location.protocol == 'https:')
     ws_str='wss://'+host+':'+port+'/websocket';
   else 
     ws_str='ws://'+host+':'+port+'/websocket';


    try{
        wsconnect();
    } catch(exception) {
        message(true,'Error: '+exception)
    }

    function getnow() {
        var jsnow = new Date();
        var month=jsnow.getMonth()+1;
        var day=jsnow.getDate();
        var hour=jsnow.getHours();
        var mins=jsnow.getMinutes();
        var seconds=jsnow.getSeconds();

        (month<10)?month='0'+month:month;
        (day<10)?day='0'+day:day;
        (hour<10)?hour='0'+hour:hour;
        (mins<10)?mins='0'+mins:mins;
        (seconds<10)?seconds='0'+seconds:seconds;

        return jsnow.getFullYear()+'/'+month+'/'+day+' '+hour+':'+mins+':'+seconds;
    }

    function message(sepcol,msg){        
        now = getnow();
	if (isNaN(msg)) {
          if (sepcol){
            console.log('in message....');
          }
        }
    }

	function send(msg){
//		console.log('send called');
		if(msg == null || msg.length == 0){
			message(true,'No data....');
			return
		}
		try{
			socket.send(msg)
		} catch(exception){
			message(true,'Error: '+exception)
		}
	}


	function socket_status(readyState){
		if (readyState == 0)
			return 'Socket status: ' + socket.readyState +' (Connecting)'
		else if (readyState == 1)
			return 'Socket status: ' + socket.readyState + ' (Open)'
		else if (readyState == 2)
			return 'Socket status: ' + socket.readyState + ' (Closing)'
		else if (readyState == 3)
			return 'Socket status: ' + socket.readyState +' (Closed)'
	}

	function startTimer() {
	  aTimer = setInterval(function () {
        sets = sets + 1;
        attempts = 0;

        if (sets === 6) {
          $('#dialog').html('<br>'+correct+' out of 5 correct!');
          $('#dialog2').html('');
          $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

          $('#b1').attr('disabled', true);
          $('#b2').attr('disabled', true);
          $('#b3').attr('disabled', true);
          $('#b4').attr('disabled', true);

          reset()
        } else {
          mkbuts()
        }
      }, 2000);  // end timer fun
	}

	function resetTimer(){
	  clearInterval(aTimer);
	  startTimer();
	}

    $(document).on('click', '#play', function(){ 
      $('#dialog3').html('');
      startTimer();
      send('0:com:play');
    });

    $(document).on('click', '#b1', function(){
//console.log('bc: '+bc+' - not bc: '+(!bc));
      resetTimer();
      if (bc > 0) {
        attempts = attempts + 1;
        if ($('#b1').html() === '1') {
          guess_right = guess_right + 1;
          $('#dialog2').html('Good job!');
          $('#b1').attr('disabled', true)
        } else {
          $('#dialog2').html('Nope, try again!');
          sets = sets + 1;
          attempts = 0;

          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!');
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

            reset()
          } else {
            mkbuts()
          }

          return
        }
        bc = bc - 1;
        if (!bc) {
          if (attempts === guess_right) {
              attempts = 0;
              guess_right = 0;
              correct = correct + 1;
	      $('#dialog').html('<br>Click each 1!<br>'+correct+' out of 5 correct!')
          }

          sets = sets + 1;
        
          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!');
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');
            correct = 0;
            reset()
          } else {
            mkbuts()
          }
        }
      }
    });

    $(document).on('click', '#b2', function(){
//console.log('bc: '+bc+' - not bc: '+(!bc));
      resetTimer();
      if (bc > 0) {
        attempts = attempts + 1;
        if ($('#b2').html() === '1') {
          guess_right = guess_right + 1;
          $('#dialog2').html('Good job!');
          $('#b2').attr('disabled', true)
        } else {
          $('#dialog2').html('Nope, try again!');
          sets = sets + 1;
          attempts = 0;

          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!')
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

            reset()
          } else {
            mkbuts()
          }

          return
        }
        bc = bc - 1;
        if (!bc) {
          if (attempts === guess_right) {
              attempts = 0;
              guess_right = 0;
              correct = correct + 1;
	      $('#dialog').html('<br>Click each 1!<br>'+correct+' out of 5 correct!')
          }

          sets = sets + 1;

          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!')
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

            reset()
          } else {
            mkbuts()
          }
        }
      }
    });

    $(document).on('click', '#b3', function(){
//console.log('bc: '+bc+' - not bc: '+(!bc));
      resetTimer();
      if (bc > 0) {
        attempts = attempts + 1;
        if ($('#b3').html() === '1') {
          guess_right = guess_right + 1;
          $('#dialog2').html('Good job!');
          $('#b3').attr('disabled', true)
        } else {
          $('#dialog2').html('Nope, try again!');
          sets = sets + 1;
          attempts = 0;

          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!')
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

            reset()
          } else {
            mkbuts()
          }

          return
        }
        bc = bc - 1;
        if (!bc) {
          if (attempts === guess_right) {
              attempts = 0;
              guess_right = 0;
              correct = correct + 1;
	      $('#dialog').html('<br>Click each 1!<br>'+correct+' out of 5 correct!')
          }

          sets = sets + 1;

          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!')
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

            reset()
          } else {
            mkbuts()
          }
        }
      }
    });

    $(document).on('click', '#b4', function(){
//console.log('bc: '+bc+' - not bc: '+(!bc));
      resetTimer();
      if (bc > 0) {
        attempts = attempts + 1;
        if ($('#b4').html() === '1') {
          guess_right = guess_right + 1;
          $('#dialog2').html('Good job!');
          $('#b4').attr('disabled', true)
        } else {
          $('#dialog2').html('Nope, try again!');
          sets = sets + 1;
          attempts = 0;

          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!')
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');

            reset()
          } else {
            mkbuts()
          }

          return
        }
        bc = bc - 1;
        if (!bc) {
          if (attempts === guess_right) {
              attempts = 0;
              guess_right = 0;
              correct = correct + 1;
	      $('#dialog').html('<br>Click each 1!<br>'+correct+' out of 5 correct!')
          }

          sets = sets + 1;
       
          if (sets === 6) {
            $('#dialog').html('<br>'+correct+' out of 5 correct!')
            $('#dialog2').html('');
            $('#dialog3').html('<button id=\\'play\\' class=\\'ui-button ui-widget ui-corner-all\\'>Play</button>');
            correct = 0;
            reset()
          } else {
            mkbuts()
          }
        }
      }
    });

  $( function() {
    $( 'button, input, a' ).on( 'click', function( event ) {
      event.preventDefault();
    } );
  } );

    var sets = 1;
    var correct = 0;
    var attempts = 0;
    var guess_right = 0;
    var bc = 0;
    var b1 = 0;
    var b2 = 0;
    var b3 = 0;
    var b4 = 0;
    aTimer = 0;

    function reset(){
      correct = 0;
      sets=1;
      attempts = 0;
      guess_right = 0;
      bc = 0;
      b1 = 0;
      b2 = 0;
      b3 = 0;
      b4 = 0;
      clearInterval(aTimer);
    }

    function mkbuts(){
      bc = 0;

      b1 = Math.round(Math.random());
      if (b1) {bc = bc + 1}

      b2 = Math.round(Math.random());
      if (b2) {bc = bc + 1}

      b3 = Math.round(Math.random());
      if (b3) {bc = bc + 1}

      b4 = Math.round(Math.random())
      if (b4) {bc = bc + 1}

      $('#buttons').html('Try #'+sets+'<br><button id=b1 class=\\'ui-button ui-widget ui-corner-all\\'>' + b1 + '</button> <button id=b2 class=\\'ui-button ui-widget ui-corner-all\\'>' + b2 + '</button> <button id=b3 class=\\'ui-button ui-widget ui-corner-all\\'>' + b3 + '</button> <button id=b4 class=\\'ui-button ui-widget ui-corner-all\\'>' + b4 + '</button>');

      if (bc === 0) mkbuts()
    }

}//End else - has websockets
});

</script>
</head>

<body bgcolor='#333333' style='color:yellow;'>

<div id=board>
<div id=head>Welcome to BinKli.<br>Click the Play button to start the game!<br><br>
You will be given 5 sets to guess from.<br>
Click all number 1 buttons to continue to a new set.<br>
(Example: If there are 3 1's, you get 3 tries to guess.  2 1's you get 2 tries to guess)<br> You have 2 seconds to respond for each try!</div><br>
<div id=buttons></div>
<div id=dialog></div>
<div id=dialog2></div>
<div id=dialog3><button id='play' class='ui-button ui-widget ui-corner-all'>Play</button></div>
</div>

</body>
</html">>, Req),
	{ok, Req2, Opts}. %% main page


