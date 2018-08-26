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
-export([start_link/0,start_link/1]).

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

start_link(MyName) ->
  gen_server:start_link({local, MyName}, ?MODULE, [MyName], []).

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
init([MyName]) ->

  %% generate world structure
  %%left and right - set the responseble
  %% pid - set the process id
  %% world_objects - set the world objects
  %% token - list of all the assigend player
  io:format("hello from ~p my pid is:~p~n",[MyName,self()]),
  erlang:start_timer(20, self(),[]),
  State = [],
  gen_server:call(etsManager,{etsReq,MyName}),
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
  handle_call(new_player,{Pid,_}, State) ->
  %%io:format("\n recive \n"),
    New_data = #{x_pos => 200 , y_pos => 200 , x_val => 0 , y_val => 0 , state => <<"alive">>, scoure => 0},
    Player_tuple = {{Pid,player},New_data},
    New_state = lists:append(State ,[Player_tuple]),
    io:format("\n recive ~p \n",[New_state]),

    {reply, ok, New_state};


%%exmple of reacive
handle_call({move_player,Map}, {Pid,_}, State) ->
  %%io:format("\r recive \n"),
  Player_data = proplists:get_value({Pid,player},State),   %%get the player data
  %%io:format("\r guy ~p\n",[Player_data]),

  X_val =  maps:get(x_val,Player_data),
  Y_val =  maps:get(y_val,Player_data),
  X_pos =  maps:get(x_pos,Player_data),
  Y_pos =  maps:get(y_pos,Player_data),
  Player_state =  maps:get(state,Player_data),
  Player_scoure =  maps:get(scoure,Player_data),

  New_X_val = X_val + maps:get(<<"x_acl">>, Map),
  New_Y_val = Y_val + maps:get(<<"y_acl">>, Map),



  New_data = #{x_pos => X_pos ,
               y_pos => Y_pos ,
               x_val => New_X_val ,
               y_val => New_Y_val ,
               state => Player_state,
               scoure => Player_scoure},


  New_state = proplists:delete({Pid,player}, State) ++ [{{Pid,player},New_data}],

  %%io:format("\n recive ~p \n",[New_state]),

  {reply, {ok}, New_state};

  handle_call({bullet,Map},{Pid,_},State)->

    X_pos =  maps:get(<<"x_pos">>,Map),
    Y_pos =  maps:get(<<"y_pos">>,Map),
    X_val =  maps:get(<<"x_val">>,Map),
    Y_val =  maps:get(<<"y_val">>,Map),

    New_Bullet = #{x_pos => X_pos , y_pos => Y_pos , x_val => X_val , y_val => Y_val ,hops => 100 },
    New_state = State ++ [{{Pid,bullet},New_Bullet}],
    io:format("cheak  message: ~p~n",[New_Bullet]),

    {reply, ok, New_state}.

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

handle_info({'ETS-TRANSFER',Tab,_FromPid,_GiftData}, _State)->
  io:format("my pid is:~p received ets from: ~p, and data is: ~p ~n",[self(),_FromPid,_GiftData]),
  New_State= ets:match_object(Tab, {'$0', '$1'}),
  io:format("my pid is:~p new stat is: ~p ~n",[self(),New_State]),
  {noreply, New_State};


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
  io:format("bye~n"),
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

  %first step update the position of etc object base on it velocity
  State_with_val = lists:map(fun(Tuple) ->

    case Tuple of
      {{Pid,bullet} ,Map} ->

       Hop = maps:get(hops,Map)-1,

            if
              Hop > 0 ->

                X_val =  maps:get(x_val,Map),
                Y_val =  maps:get(y_val,Map),


              Up_Map =#{x_pos => maps:get(x_pos,Map) + X_val,
                        y_pos => maps:get(y_pos,Map) + Y_val,
                        x_val => maps:get(x_val,Map) ,y_val => maps:get(y_val,Map),
                        hops => Hop},
                        {{Pid,bullet}, Up_Map};
              true-> []
            end;
      {{Pid,player},Map} ->

        Map_update_x_pos = maps:put(x_pos,maps:get(x_pos,Map) + maps:get(x_val,Map),Map),
        Map_update_y_pos = maps:put(y_pos , maps:get(y_pos,Map) + maps:get(y_val,Map),Map_update_x_pos),
        Map_update_y_val = maps:put(y_val , maps:get(y_val,Map) + 0.02,Map_update_y_pos),


      {{Pid,player}, Map_update_y_val}
    end
                             end,State),



 % second step: check for each player if it coliad with the floor or celing
  New_state = floor_colusion(lists:flatten(State_with_val)),


  % Third step calculate collusions
  State_after_coliad =  colusion_detection(New_state),

  % Fourth step: for each player create it's own List and send





  L_pid = lists:map(fun(Tuple) ->
    case Tuple of
      {{Pid,player},_} -> Pid;
      _Else -> []
    end end,State_after_coliad),

  L_pid_f = lists:flatten(L_pid),

  send_world(L_pid_f,State_after_coliad),
  {ok,State_after_coliad}.


send_world([],_)->

  {ok};

send_world(L_pid,State)->


  Player_data = proplists:get_value({hd(L_pid),player},State),        %%get the player data



  Player_world_list = [] ++ proplists:delete({hd(L_pid),player}, State),  %%remove player from list

  List_of_player = lists:map(fun(Tuple) ->
    case Tuple of
      {{_,player},Map} ->
    #{x_pos => maps:get(x_pos,Map),y_pos => maps:get(y_pos,Map),state => maps:get(state,Map)};
      _Else -> [] end end,Player_world_list),





  List_of_bullets = lists:map(fun(Tuple) ->
    case Tuple of
      {{_,bullet},Map} ->
        #{x_start => maps:get(x_pos,Map),
          x_end   => maps:get(x_pos,Map) + maps:get(x_val,Map),
          y_start => maps:get(y_pos,Map),
          y_end   => maps:get(y_pos,Map) + maps:get(y_val,Map)};

      _Else -> [] end end,Player_world_list),


  Player_map = #{x_pos        =>    maps:get(x_pos,Player_data),
                 y_pos        =>    maps:get(y_pos,Player_data),
                 other_player =>                List_of_player ,
                 bullets      =>                List_of_bullets ,
                 type         =>               <<"world_type">> ,
                 state        =>      maps:get(state,Player_data),
                 scoure       =>     maps:get(scoure,Player_data)},


  erlang:send(hd(L_pid),{world_update,Player_map}),

  send_world( tl(L_pid),State).


floor_colusion(State)->

  lists:map(fun(Tuple) ->

    case Tuple of
      {{Pid,player}, Map} ->

        Y_val = maps:get(y_val,Map),
        Y_pos = maps:get(y_pos,Map),
            if
              Y_pos > 900 ->
                Map_up1 = maps:put(y_val,-Y_val*0.5,Map),
                Map_up2 = maps:put(y_pos,900,Map_up1),
                {{Pid,player} ,Map_up2};

              Y_pos < 0 ->
                Map_up1 = maps:put(y_val,-Y_val*0.5,Map),
                Map_up2 = maps:put(y_pos,0,Map_up1),
                {{Pid,player}, Map_up2};
              true->
                {{Pid,player}, Map}
            end;
      {{Pid,bullet}, Map} ->
        {{Pid,bullet},Map} end end,State).


colusion_detection([])->
  [];

colusion_detection(State)->
  colusion_detection(State,tl(State),State).


colusion_detection([],[],State)->

  State;



colusion_detection(List,[],State)->

  if length(List) > 1 -> colusion_detection(tl(List),tl(tl(List)),State);
       true -> State
  end;




colusion_detection(List1,List2,State)->

  %% Temp1 = element(2,hd(List1)),
  %% Temp2 = element(2,hd(List2)),

  New_state =
    case {hd(List1),hd(List2)} of

      {{{Pid1,player}, Map_1 },{{Pid2,player} ,Map_2}} ->

        Y1 = maps:get(y_pos,Map_1),
        X1 = maps:get(x_pos,Map_1),
        Y2 = maps:get(y_pos,Map_2),
        X2 = maps:get(x_pos,Map_2),


        if
          abs(Y1-Y2) < 25 andalso abs(X1-X2) < 50 ->



            Witout1 = lists:delete({{Pid1,player}, Map_1}, State),
            Witout2 = lists:delete({{Pid2,player}, Map_2 }, Witout1),


            X_pos1 =  maps:get(x_pos,Map_1),
            Y_pos1 =  maps:get(y_pos,Map_1),
            X_val1 =  maps:get(x_val,Map_1),
            Y_val1 =  maps:get(y_val,Map_1),


            X_pos2 =  maps:get(x_pos,Map_2),
            Y_pos2 =  maps:get(y_pos,Map_2),
            X_val2 =  maps:get(x_val,Map_2),
            Y_val2 =  maps:get(y_val,Map_2),
            Gap = if
                    Y1 < Y2  -> -2;
                    true-> 2
                  end,


            Map1 = #{x_pos => X_pos1 ,
              y_pos => Y_pos1 + Gap ,
              x_val => X_val2*0.9 ,
              y_val => Y_val2*0.9 ,
              state => maps:get(state,Map_1),
              scoure => maps:get(scoure,Map_1)},



            Map2 = #{x_pos => X_pos2  ,
              y_pos => Y_pos2 - Gap ,
              x_val => X_val1*0.9 ,
              y_val => Y_val1*0.9 ,
              state =>  maps:get(state,Map_2),
              scoure => maps:get(scoure,Map_2)},


            Affter_colliad_1 = {{Pid1,player},Map1},
            Affter_colliad_2 = {{Pid2,player},Map2},

            [Affter_colliad_1,Affter_colliad_2] ++ Witout2;

          true-> State
        end;

      {{{Pid1,player},Map_1},{{Pid2,bullet},Map_2}} ->

        Y1 = maps:get(y_pos,Map_1),
        X1 = maps:get(x_pos,Map_1),
        Y2_bullet_start = maps:get(y_pos,Map_2),
        X2_bullet_start = maps:get(x_pos,Map_2),

        Y2_bullet_end  = Y2_bullet_start + maps:get(y_val,Map_2)*50,
        X2_bullet_end  = X2_bullet_start + maps:get(x_val,Map_2)*50,


        if
          (X1 > X2_bullet_start) andalso (X1 > X2_bullet_end)-> State;
          (X1 < X2_bullet_start) andalso (X1 < X2_bullet_end)-> State;
          (Y1 < Y2_bullet_start) andalso (Y1 < Y2_bullet_end)-> State;
          (Y1 > Y2_bullet_start) andalso (Y1 > Y2_bullet_end)-> State;
          true ->

            M = (Y2_bullet_start - Y2_bullet_end)/(X2_bullet_start - X2_bullet_end),
            N = (-X2_bullet_start*M +Y2_bullet_start ),

            D = abs((M*X1-Y1+N)/math:sqrt(M*M+1)),

            if (D < 30)  ->


              Map_player_2 = proplists:get_value({Pid2,player},State),
              Witout1 =  proplists:delete({Pid1,player},State),
              Witout2 =  proplists:delete({Pid2,player},Witout1),

              Map_1_you_been_hit  = maps:put(state,<<"dead">>,Map_1),
              Map_2_you_been_kill = maps:put(scoure,maps:get(scoure,Map_player_2)+1,Map_player_2),
              [{{Pid1,player},Map_1_you_been_hit} , {{Pid2,player},Map_2_you_been_kill}] ++ Witout2;

              true->
                State
            end
        end;



      {{{Pid2,bullet},Map_2},{{Pid1,player},Map_1}} ->

        Y1 = maps:get(y_pos,Map_1),
        X1 = maps:get(x_pos,Map_1),
        Y2_bullet_start = maps:get(y_pos,Map_2),
        X2_bullet_start = maps:get(x_pos,Map_2),

        Y2_bullet_end  = Y2_bullet_start + maps:get(y_val,Map_2)*50,
        X2_bullet_end  = X2_bullet_start + maps:get(x_val,Map_2)*50,


        if
          (X1 > X2_bullet_start) andalso (X1 > X2_bullet_end)-> State;
          (X1 < X2_bullet_start) andalso (X1 < X2_bullet_end)-> State;
          (Y1 < Y2_bullet_start) andalso (Y1 < Y2_bullet_end)-> State;
          (Y1 > Y2_bullet_start) andalso (Y1 > Y2_bullet_end)-> State;
          true ->

            M = (Y2_bullet_start - Y2_bullet_end)/(X2_bullet_start - X2_bullet_end),
            N = (-X2_bullet_start*M +Y2_bullet_start ),

            D = abs((M*X1-Y1+N)/math:sqrt(M*M+1)),

            if (D < 30)  ->


              Map_player_2 = proplists:get_value({Pid2,player},State),
              Witout1 =  proplists:delete({Pid1,player},State),
              Witout2 =  proplists:delete({Pid2,player},Witout1),

              Map_1_you_been_hit  = maps:put(state,<<"dead">>,Map_1),
              Map_2_you_been_kill = maps:put(scoure,maps:get(scoure,Map_player_2)+1,Map_player_2),
              [{{Pid1,player},Map_1_you_been_hit} , {{Pid2,player},Map_2_you_been_kill}] ++ Witout2;

              true->
                State
            end
        end;
        _Else-> State
    end,
  colusion_detection(List1,tl(List2),New_state).



