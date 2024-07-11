-module(binkli).
-export([start/0]).

start() ->
	application:start(ranch),
	application:start(cowboy),
	application:start(esysman).
