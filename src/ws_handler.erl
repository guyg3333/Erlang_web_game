-module(ws_handler).


-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).



init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

websocket_init(State) ->
 	io:fwrite("connection establish !~p~n", [State]),
	gen_server:call(w_serv,new_player),
%%	erlang:start_timer(1000, self(), <<"Hello!">>),
	{ok, State}.


websocket_handle({text, Json}, State) ->
	Map = jiffy:decode(Json, [return_maps]),

	Type = maps:get(<<"type">>,Map),
	case Type of
		<<"player">>  ->gen_server:call(w_serv,{move_player,Map});
		<<"bullet">> -> gen_server:call(w_serv,{bullet,Map})
  end,

	{ok, State}.



%%websocket_info({timeout, _Ref, Msg}, State) ->
%%	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
%%	{reply, {text, Msg}, State};


websocket_info({world_update,Reply}, State) ->
	%%io:format(" message - ws: ~p~n",[Reply]),
	{reply,{text,jiffy:encode(Reply)}, State};

websocket_info(_Info, State) ->
	io:format("Unexpected message - ws: ~p~n",[_Info]),
	{ok, State}.

