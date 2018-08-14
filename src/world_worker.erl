%%%-------------------------------------------------------------------
%%% @author guy
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2018 00:26
%%%-------------------------------------------------------------------
-module(world_worker).
-author("guy").


-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->

  %% generate world structure
  %%left and right - set the responseble
  %% pid - set the process id
  %% world_objects - set the world objects
  %% token - list of all the assigend plyer
  io:format("i am init and shit\n"),
  erlang:start_timer(20, self(),[]),
  State = [],
  {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).


  %%exmple of reacive
  handle_call(new_player, _From, State) ->
  %%io:format("\n recive \n"),
    Pid = element(1,_From),
    New_data = #{x_pos => 200 , y_pos => 200 , x_val => 0 , y_val => 0},
    Player_tuple = {Pid,New_data},
    New_state = lists:append(State ,[Player_tuple]),
    %%io:format("\n recive ~p \n",[New_state]),

    {reply, {ok,New_state}, New_state};


%%exmple of reacive
handle_call({move_player,Map}, _From, State) ->
  %%io:format("\r recive \n"),
  Pid = element(1,_From),
  Player_data = proplists:get_value(Pid,State),   %%get the player data
  %%io:format("\r guy ~p\n",[Player_data]),

  X_pos =  maps:get(x_pos,Player_data),
  Y_pos =  maps:get(y_pos,Player_data),
  X_val =  maps:get(x_val,Player_data),
  Y_val =  maps:get(y_val,Player_data),

  New_X_val = X_val + maps:get(<<"x_acl">>, Map),
  New_Y_val = Y_val + maps:get(<<"y_acl">>, Map),
  %%New_X_pos = X_pos + New_X_val,
  %%New_Y_pos = Y_pos + New_Y_val,

  New_Player_data = #{x_pos => X_pos , y_pos => Y_pos , x_val => New_X_val , y_val => New_Y_val },
  New_state = proplists:delete(Pid, State) ++ [{Pid,New_Player_data}],

  %%io:format("\n recive ~p \n",[New_state]),

  {reply, {ok,New_state}, New_state}.



%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).


handle_info({timeout, _Ref,_}, State) ->
  erlang:start_timer(30, self(),[]),
  {ok,New_state} = send_world(State),
  {noreply, New_state};



handle_info(_Info, State) ->
  io:format("Unexpected message: ~p~n",[_Info]),
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%

%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================



send_world([])->
  {ok,[]};

send_world(State)->

  State_with_val = lists:map(fun(Tuple) ->

    Temp = element(2,Tuple),

    {element(1,Tuple) ,#{x_pos => maps:get(x_pos,Temp) + maps:get(x_val,Temp),
      y_pos => maps:get(y_pos,Temp) + maps:get(y_val,Temp),
      x_val => maps:get(x_val,Temp) ,y_val => maps:get(y_val,Temp) + 0.02 }} end,State),


  New_state = floor_colusion(State_with_val),
  State_after_coliad =  colusion_detection(New_state),


  L_pid = lists:map(fun(Tuple) -> element(1,Tuple) end,State_after_coliad),

  send_world(L_pid,State_after_coliad),
  {ok,State_after_coliad}.


send_world([],_)->
  {ok};

send_world(L_pid,State)->

  Player_data = proplists:get_value(hd(L_pid),State),        %%get the player data
  Player_world_list = [Y || Y <- State, element(1,Y) =/= hd(L_pid)],  %%remove player from list

    L_obj = lists:map(fun(Tuple) ->
    Temp = element(2,Tuple),
    #{x_pos => maps:get(x_pos,Temp),y_pos => maps:get(y_pos,Temp)} end,Player_world_list),


  Player_map = #{x_pos => maps:get(x_pos,Player_data) , y_pos => maps:get(y_pos,Player_data),
    other_player => L_obj ,type => <<"world_type">>},

  erlang:send(hd(L_pid),{world_update,Player_map}),
  send_world( tl(L_pid),State).


floor_colusion(State)->

  lists:map(fun(Tuple) ->

    Temp = element(2,Tuple),
    Temp_y = maps:get(y_pos,Temp),

    New_y_val =

    case Temp_y of
      Temp_y when Temp_y >= 900->
        {-maps:get(y_val,Temp)*0.5,900};
      Temp_y when Temp_y =< 0->
        {-maps:get(y_val,Temp)*0.5,0};
          _ ->
            {maps:get(y_val,Temp), maps:get(y_pos,Temp)}
    end,


    {element(1,Tuple) ,#{x_pos => maps:get(x_pos,Temp),
                         y_pos => element(2,New_y_val),
                         x_val => maps:get(x_val,Temp),
                         y_val => element(1,New_y_val) }} end,State).



colusion_detection([])->
  io:format(" coliad - 0 0  \n"),

  [];

colusion_detection(State)->
  io:format(" coliad - 0  \n"),
  colusion_detection(State,tl(State),State).






   colusion_detection([],[],State)->
     io:format(" coliad - 1  \n"),

     State;



   colusion_detection(List,[],State)->
     io:format(" coliad - 2  \n"),

     if length(List) > 1 -> colusion_detection(tl(List),tl(tl(List)),State);
       true -> State
     end;




  colusion_detection(List1,List2,State)->
    io:format(" coliad - 3 3 \n"),

    Temp1 = element(2,hd(List1)),
    Temp2 = element(2,hd(List2)),


    Y1 = maps:get(y_pos,Temp1),
    X1 = maps:get(x_pos,Temp1),
    Y2 = maps:get(y_pos,Temp2),
    X2 = maps:get(x_pos,Temp2),

    New_state =
      if
        abs(Y1-Y2) < 5 andalso abs(X1-X2) < 10 ->

           io:format(" coliad - true  \n"),

          Witout1 = proplists:delete(element(1,hd(List1)), State),
          Witout2 = proplists:delete(element(1,hd(List2)), Witout1),


          X_pos1 =  maps:get(x_pos,Temp1),
          Y_pos1 =  maps:get(y_pos,Temp1),
          X_val1 =  maps:get(x_val,Temp1),
          Y_val1 =  maps:get(y_val,Temp1),


          X_pos2 =  maps:get(x_pos,Temp2),
          Y_pos2 =  maps:get(y_pos,Temp2),
          X_val2 =  maps:get(x_val,Temp2),
          Y_val2 =  maps:get(y_val,Temp2),
          Gap = if
            Y1 < Y2  -> -2;
            true-> 2
             end,


          Map1 = #{x_pos => X_pos1  , y_pos => Y_pos1 + Gap , x_val => X_val2*0.9 , y_val => Y_val2*0.9 },
          Map2 = #{x_pos => X_pos2  , y_pos => Y_pos2 - Gap , x_val => X_val1*0.9 , y_val => Y_val1*0.9 },


        Affter_colliad_1 = {element(1,hd(List1)),Map1},
        Affter_colliad_2 = {element(1,hd(List2)),Map2},

        Witout2 ++ [Affter_colliad_1,Affter_colliad_2];

        true-> State
end,

     colusion_detection(List1,tl(List2),New_state).





