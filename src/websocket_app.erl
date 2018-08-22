%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(websocket_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.
start(_Type, _Args) ->
	io:format("hi how lets go\n"),

	%% initial the world process
	%gen_server:start_link({local,w_serv},world_worker,[],[]),


	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, websocket, "/static/firstGame/index.html"}},
			{"/websocket", ws_handler, []},
			{"/static/[...]", cowboy_static, {priv_dir, websocket, "static"}}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
		env => #{dispatch => Dispatch}
	}),
	websocket_sup:start_link().

stop(_State) ->
	ok.
