-module(erws_handler).
-behaviour(cowboy_http_handler).
-behaviour(cowboy_websocket_handler).
-export([init/3, handle/2, terminate/3]).
-export([
    websocket_init/3, websocket_handle/3,
    websocket_info/3, websocket_terminate/3
]).

init({tcp, http}, _Req, _Opts) ->
  gen_server:call(erws_forwarder, {register, self()}),
  {upgrade, protocol, cowboy_websocket}.

handle(Req, State) ->
    lager:error("Request not expected: ~p", [Req]),
    {ok, Req2} = cowboy_http_req:reply(404, [{'Content-Type', <<"text/html">>}]),
    {ok, Req2, State}.


websocket_init(TransportName, Req, Opts) ->
    lager:info("init websocket: ~p ~p", [TransportName, Opts]),
    {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
    lager:error("Got Data: ~p", [Msg]),
    {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };

websocket_handle({binary, Msg}, Req, State) ->
    lager:info("Got Data: ~p", [Msg]),
    [ S ! Msg || {S} <- all_other_sockets(self()) ],
    {reply, {text, << "whut?">>}, Req, State, hibernate }.

all_other_sockets(Pid) ->
  Sockets = gen_server:call(erws_forwarder, list),
  WithoutMe = lists:filter(fun ({Socket}) ->
                               Socket =/= Pid
                           end, Sockets),
  WithoutMe.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};

websocket_info(Info, Req, State) ->
    lager:info("info is ~p", [Info]),
    {reply, {text, Info}, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.

terminate(_Reason, _Req, _State) ->
    ok.

is_not_control_code( C ) when C > 127 -> true;
is_not_control_code( C ) when C < 32; C =:= 127 -> false;
is_not_control_code( _C ) -> true.

is_not_control_code_nor_extended_character( C ) when C > 127 -> false;
is_not_control_code_nor_extended_character( C )	-> is_not_control_code( C ).
