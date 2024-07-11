-module(default_handler).

-export([init/2]).
-export([allowed_methods/2]).

init(Req1, Opts) ->
	Req2 = cowboy_req:set_resp_header(<<"Location">>, <<"/binkli">>, Req1),
	{ok, Req} = cowboy_req:reply(307, #{}, <<>>, Req2),
	{ok, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"GET">>], Req, State}.
