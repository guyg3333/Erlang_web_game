-module(ws_handler).


-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).



init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

websocket_init(State) ->
 	io:fwrite("connection establish !~n", []),
	erlang:start_timer(1000, self(), <<"Hello!">>),
	{ok, State}.


websocket_handle({text, Json}, State) ->
	Map = jiffy:decode(Json, [return_maps]),
   	 X_val = maps:get(<<"x_val">>, Map),
   	 Y_val = maps:get(<<"y_val">>, Map),
  	 Reply = #{x_val =>X_val, y_val =>Y_val},
         io:format("\n~p\n",[{X_val,Y_val}]),
   	 {reply, {text, jiffy:encode(Reply)}, State}.



websocket_info({timeout, _Ref, Msg}, State) ->
	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, State};


websocket_info(_Info, State) ->
	{ok, State}.
