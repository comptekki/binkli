-module(binklicl).

-export([start/0, rec_com/0]).

start() ->
    io:format("~nbinklicl start reg~n~n"),
    io:format("~nGo to:~n~n http://localhost:8080/binkli ~n~nin your browser to run the game~n~n"),
    register(rec_com, spawn(binklicl, rec_com, [])).

rec_com() ->
    Servers = ['ecom@localhost'],
    Clients = [hanwebs, hanwebs2, hanwebs3, hanwebs4],
    receive
        finished ->
            io:format("finished~n", []);
        {Box, Com, Args} ->
            io:format("~nrec mesg~n", []),
            process_msg(Servers, Clients, Box, Com, Args),
            rec_com()
    end.

send_msg([Server|Rest], WEBCLIENTS, Msg) ->
    msg_to_webclientsm(Server, WEBCLIENTS, Msg),
    send_msg(Rest, WEBCLIENTS, Msg);
send_msg([], _, _Msg) ->
    [].

msg_to_webclientsm(Server, [WebClient|Rest], Msg) ->
    {WebClient, Server} ! Msg,
    msg_to_webclientsm(Server, Rest, Msg);
msg_to_webclientsm(_Server, [], _Msg) ->
    [].

process_msg(SERVERS, WEBCLIENTS, Box, Com, Args) ->

    io:format("~nbinklicl -> Box: ~p -> Com: ~p -> args: ~p -> pid: ~p~n",[Box, Com, Args, self()]),

    case Com of
	<<"com">> ->
	    send_msg(SERVERS, WEBCLIENTS, <<Box/binary,":com <- ",Args/binary>>),
	    case Args of
		<<"play">> ->
		    send_msg(SERVERS, WEBCLIENTS, <<Box/binary,":playstart">>);
		Unsupported -> Unsupported
	    end;
	_ ->
	    send_msg(SERVERS, WEBCLIENTS, <<"Unknown command: '",Com/binary,"'">>)
    end.

