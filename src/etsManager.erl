%%%-------------------------------------------------------------------
%%% @author daviddab
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Aug 2018 4:38 AM
%%%-------------------------------------------------------------------
-module(etsManager).
-author("daviddab").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1 ,
  handle_call/3 ,
  handle_cast/2 ,
  handle_info/2 ,
  terminate/2 ,
  code_change/3]).

-define(SERVER , ?MODULE).
-include_lib("stdlib/include/ms_transform.hrl").
-record(state , {}).
-record(table,{t_id,t_name,p_name,p_id}).

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
  {ok , Pid :: pid()} | ignore | {error , Reason :: term()}).
start_link() ->
  gen_server:start_link({local , ?SERVER} , ?MODULE , [] , []).

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
  {ok , State :: #state{}} | {ok , State :: #state{} , timeout() | hibernate} |
  {stop , Reason :: term()} | ignore).
init([]) ->
  %create ets for each area manager
  io:format("hello from ~p~n",[?MODULE]),
  ets:new(myTable,[set,{keypos,#table.t_id},named_table]),
  T_id_1 = ets:new(area1t,[bag,named_table,{heir, self(), []}]),
  T_id_2 = ets:new(area2t,[bag,named_table,{heir, self(), []}]),
  T_id_3 = ets:new(area3t,[bag,named_table,{heir, self(), []}]),
  T_id_4 = ets:new(area4t,[bag,named_table,{heir, self(), []}]),
  % insert record to myTable
  ets:insert(myTable,[#table{t_id = T_id_1,t_name = area1t,p_name = area1, p_id = undefined},
    #table{t_id = T_id_2,t_name = area2t,p_name = area2, p_id = undefined},
    #table{t_id = T_id_3,t_name = area3t,p_name = area3, p_id = undefined},
    #table{t_id = T_id_4,t_name = area4t,p_name = area4, p_id = undefined}]),
  {ok , #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term() , From :: {pid() , Tag :: term()} ,
    State :: #state{}) ->
  {reply , Reply :: term() , NewState :: #state{}} |
  {reply , Reply :: term() , NewState :: #state{} , timeout() | hibernate} |
  {noreply , NewState :: #state{}} |
  {noreply , NewState :: #state{} , timeout() | hibernate} |
  {stop , Reason :: term() , Reply :: term() , NewState :: #state{}} |
  {stop , Reason :: term() , NewState :: #state{}}).

handle_call({etsReq,MyName} , _From , State) ->
  [Record] = ets:select(myTable,ets:fun2ms(fun(Result = #table{p_name = Name}) when Name == MyName -> Result end)),
  io:format("~p received ets request from: ~p record ~p~n",[?MODULE,MyName,Record]),
  P_id = Record#table.p_id,
  io:format("Pid is ~p ~n",[P_id]),
  case P_id of
         undefined ->
            T_id=Record#table.t_id, % get relevant table id
%            ets:insert(myTable,Record#table{p_id = global:whereis_name(MyName)}),
%            ets:give_away(T_id,global:whereis_name(MyName)),
           ets:insert(myTable,Record#table{p_id = whereis(MyName)}),
           ets:give_away(T_id,whereis(MyName),[]),
            {reply , ok , State};
          _ ->
            {reply , have_already_owner , State}
  end;


handle_call(_Request , _From , State) ->
  io:format("~p received request: ~p~n",[?MODULE,_Request]),
  {reply , ok , State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term() , State :: #state{}) ->
  {noreply , NewState :: #state{}} |
  {noreply , NewState :: #state{} , timeout() | hibernate} |
  {stop , Reason :: term() , NewState :: #state{}}).
handle_cast(_Request , State) ->
  {noreply , State}.

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
-spec(handle_info(Info :: timeout() | term() , State :: #state{}) ->
  {noreply , NewState :: #state{}} |
  {noreply , NewState :: #state{} , timeout() | hibernate} |
  {stop , Reason :: term() , NewState :: #state{}}).
handle_info({'ETS-TRANSFER', TableId, _OldOwner, _HeirData} , State) ->
  [Record] = ets:select(myTable,ets:fun2ms(fun(Result = #table{t_id = ID}) when ID == TableId -> Result end)),
  ets:insert(myTable,Record#table{p_id = undefined}),
  {noreply , State};

handle_info(_Info , State) ->
  {noreply , State}.

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
-spec(terminate(Reason :: (normal | shutdown | {shutdown , term()} | term()) ,
    State :: #state{}) -> term()).
terminate(_Reason , _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down , term()} , State :: #state{} ,
    Extra :: term()) ->
  {ok , NewState :: #state{}} | {error , Reason :: term()}).
code_change(_OldVsn , State , _Extra) ->
  {ok , State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
