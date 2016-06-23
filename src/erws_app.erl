-module(erws_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  lager:start(),
  Dispatch = cowboy_router:compile([
      {'_', [
        {"/", cowboy_static, {priv_file, erws, "index.html"}},
        {"/websocket", erws_handler, []}
      ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]),
      erws_sup:start_link().

stop(_State) ->
    ok.
