%%%-------------------------------------------------------------------
%%% @author guy
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Aug 2018 11:39
%%%-------------------------------------------------------------------
-module(world_worker_sup).
-author("guy").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([]) ->
  io:format("hello from ~p my pid: ~p ~n",[?MODULE,self()]),
  RestartStrategy = one_for_one,
  MaxRestarts = 10,
  MaxSecondsBetweenRestarts = 10,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  Restart = permanent,
  Shutdown = 2000,
  Type = worker,

  AChild ={area1,
            {world_worker, start_link, [area1]},
            Restart, Shutdown, Type, [world_worker]},
  BChild ={area2,
    {world_worker, start_link, [area2]},
    Restart, Shutdown, Type, [world_worker]},
  CChild ={area3,
    {world_worker, start_link, [area3]},
    Restart, Shutdown, Type, [world_worker]},
  DChild ={area4,
    {world_worker, start_link, [area4]},
    Restart, Shutdown, Type, [world_worker]},


  {ok, {SupFlags, [AChild,BChild,CChild,DChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
