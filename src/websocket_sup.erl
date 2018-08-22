%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(websocket_sup).
-behaviour(supervisor).

%% API.
-export([start_link/0]).

%% supervisor.
-export([init/1]).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% supervisor.

init([]) ->
	Procs = [{world_manager_id,
							{world_manager,start_link,[]},
							permanent,5000,worker,[world_manager]},
					 {world_worker_sup_id,
							{world_worker_sup,start_link,[]},
							permanent,5000,supervisor,[world_worker_sup]}
					],
  io:format("websocket sup ~p ~n",[self()]),
	{ok, {{one_for_one, 10, 10}, Procs}}.
