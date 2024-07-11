-module(binkli_app).
-behaviour(application).

%% API.

-export([start/2, stop/1]).

%% API.

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
      {'_', [
			 {"/binkli", main_handler, []},
			 {"/websocket", websocket_handler, []},
			 {"/static/[...]", cowboy_static, {priv_dir, binkli, "static"}}
		]}
	]),
	{ok, _} = 
		cowboy:start_clear(
		  http,
		  [{port, 8080}],
		  #{
		    env => #{dispatch => Dispatch}
		   }
                ),
	binkli_sup:start_link().

stop(_State) ->
	ok.
