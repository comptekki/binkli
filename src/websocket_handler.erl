-module(websocket_handler).

-export([init/2]).

-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([send_msg/2]).

-export([terminate/3]).

-include("binkli.hrl").

%%

init(Req, State) ->
	io:format("~n~nhost ws connect ok....~n"),
	Opts = #{ idle_timeout => 31200000 },
	{cowboy_websocket, Req, State, Opts}.

%%

websocket_init(State) ->
    case lists:member(hanwebs, registered()) of
	true -> 
	    case lists:member(hanwebs2, registered()) of
		true -> 
		    case lists:member(hanwebs3, registered()) of
			true -> 
			    register(hanwebs4, self()),
			    ok;
			false ->
			    register(hanwebs3, self())
		    end,
		    ok;
		false ->
		    register(hanwebs2, self())
	    end,
	    ok;
	false ->
	    register(hanwebs, self())
    end,
    {ok, State, hibernate}.

%%


websocket_handle({text, <<"close">>}, State) ->
    {stop, State};
websocket_handle({text, <<"client-connected">>}, State) ->
    {reply, {text, <<"client-connected">> }, State, hibernate};
websocket_handle({text, Msg}, State) ->

    Ldatacrt = binary:split(Msg,<<"^">>,[global]),

    Ldata = 
	case erlang:length(Ldatacrt) > 1 of
	    true ->
		[C1, C2, C3] = Ldatacrt,
		[B1, B2, B3] = binary:split(C1,<<":">>,[global]),
		[B1,B2,<<B3/binary,"^",C2/binary,"^",C3/binary>>];
	    _  ->
%io:format("~n bin split ~n"),
		binary:split(Msg,<<":">>,[global])
	end,

    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:local_time(),
    Date = lists:flatten(io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w",[Year,Month,Day,Hour,Minute,Second])),

    [Box,Com,Args]=Ldata,
    io:format("~ndate: ~p -> done - sent com ~p - args: ~p ~n",[Date, Com, Args]),
%    Rec_Node=binary_to_atom(<<Box/binary>>,latin1),
    Data3 =
	case Com of
	    <<"com">> ->
		rec_com ! {Box,Com,Args},
	        send_msg(?SERVERS, <<"com - ",Args/binary," - from ", (pid())/binary>>),
	    	io:format("ldata: ~p~n",[Ldata]),
		Data2= <<"done - com -> ",Args/binary,"  <- sent to: ",Box/binary>>,
		io:format("~ndate: ~p -> done - sent com ~p - data2: ~p ~n",[Date, Box, Data2]),
		Data2;
	    _ ->					
		send_msg(?SERVERS, <<"unsupported command from ", (pid())/binary>>),
		<<"unsupported command">>
	end,
    {reply, {text, Data3}, State, hibernate};
websocket_handle(_Data, State) ->
    {ok, State}.

%%

send_msg([Server|Rest], Msg) ->
    msg_to_consoles(Server, ?CONSOLES, Msg),
    send_msg(Rest, Msg);
send_msg([], _Msg) ->
    [].

%%

msg_to_consoles(Server, [Console|Rest], Msg) ->
    {Console, Server} ! Msg,
    msg_to_consoles(Server, Rest, Msg);
msg_to_consoles(_Server, [], _Msg) ->
    [].

%%

pid() ->
    Apid = self(),
    case whereis(hanwebs) =:= Apid of
	true -> 
	    <<"cons1">>;
	_ ->
	    case whereis(hanwebs2) =:= Apid of
		true ->
		    <<"cons2">>; 
		_ ->
		    case whereis(hanwebs3) =:= Apid of
			true -> 
			    <<"cons3">>; 
			_ ->
			    <<"cons4">> 
		    end
	    end
    end.	

%%

websocket_info(PreMsg, State) ->
    Msg=
	case PreMsg of
	    {Msg2,_PID}-> Msg2;
	    _ -> PreMsg
	end,
    Msg3 = 
	case is_binary(Msg) of
	    true ->
		Msg;
	    false -> 
		case Msg of
		    {'EXIT', _, normal} ->
			<<>>;
		    _ ->
			list_to_binary(Msg)
		end				 
	end,
    {reply, {text, Msg3}, State, hibernate}.

%%


terminate(Reason, _Opts, _State) ->
    io:format("~nTerminate Reason: ~p~n", [Reason]),
    ok.

