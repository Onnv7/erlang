-module(hello_ws_handler).
-behaviour(cowboy_websocket).

-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2, terminate/3]).

init(Req, State) ->
    {cowboy_websocket, Req, State}.

websocket_init(State) ->
    Pid = self(),
    chat_room:arrive(Pid),
    io:fwrite("WebSocket websocket_init, Pid: ~w~n", [Pid]),
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    SenderPid = self(),
    chat_room:broadcast(SenderPid, Msg),
    {ok, State}.

websocket_info({broadcast, Msg}, State) ->
    io:fwrite("websocket_info: Broadcasting message ~w~n", [Msg]),
    {reply, {text, Msg}, State}.

terminate(_Reason, _Req, _State) ->
    Pid = self(),
    chat_room:leave(Pid),
    ok.