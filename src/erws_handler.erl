-module(erws_handler).
-behaviour(cowboy_http_handler).
-behaviour(cowboy_websocket_handler).
-export([init/3, handle/2, terminate/3]).
-export([
    websocket_init/3, websocket_handle/3,
    websocket_info/3, websocket_terminate/3
]).

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.


handle(Req, State) ->
    lager:error("Request not expected: ~p", [Req]),
    {ok, Req2} = cowboy_http_req:reply(404, [{'Content-Type', <<"text/html">>}]),
    {ok, Req2, State}.


websocket_init(_TransportName, Req, _Opts) ->
    lager:info("init websocket"),
    {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
    lager:error("Got Data: ~p", [Msg]),
    {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };


websocket_handle({binary, Msg}, Req, State) ->
    io:format("Got json data: ~ts~n", [Msg]), 
    {reply, {text, << "whut?">>}, Req, State, hibernate }.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};

websocket_info(_Info, Req, State) ->
    lager:info("websocket info"),
    {ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.

terminate(_Reason, _Req, _State) ->
    ok.

is_not_control_code( C ) when C > 127 -> true;
is_not_control_code( C ) when C < 32; C =:= 127 -> false;
is_not_control_code( _C ) -> true.
 
is_not_control_code_nor_extended_character( C ) when C > 127 -> false;
is_not_control_code_nor_extended_character( C )	-> is_not_control_code( C ).
