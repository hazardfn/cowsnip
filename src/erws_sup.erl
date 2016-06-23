-module(erws_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, { {one_for_one, 5, 10}, child_specs()} }.

child_spec(Module, Id) -> #{
  id       => Id,
  restart  => permanent,
  shutdown => brutal_kill,
  start    => { Module, start_link, [] },
  type     => worker
 }.

child_specs() -> [
                  child_spec(erws_forwarder, erws_forwarder)
                 ].
