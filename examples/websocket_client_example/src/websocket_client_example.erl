%
% SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
%

%%
%% Connects to a public echo server over TLS and exchanges a message a second.
%%
%% `verify => crt_bundle' is the point of the example as much as the echo is: it
%% checks the server certificate against ESP-IDF's bundled roots, so a run that
%% prints replies has exercised DNS, TCP, TLS with a real trust store, the
%% WebSocket handshake, framing, and delivery into an Erlang process.
%%
-module(websocket_client_example).

-export([start/0]).

-define(URL, "wss://echo.websocket.org/").

start() ->
    ok = start_network(maps:get(sta, config:get())),

    {ok, WS} = websocket_client:open(#{
        url => ?URL,
        owner => self(),
        verify => crt_bundle
    }),
    io:format("Connecting to ~s~n", [?URL]),

    loop(WS, 1).

loop(WS, Seq) ->
    receive
        {websocket, WS, connected} ->
            io:format("Connected.~n"),
            Msg = list_to_binary("hello " ++ integer_to_list(Seq)),
            ok = websocket_client:send_text(WS, Msg),
            io:format("Sent: ~p~n", [Msg]),
            loop(WS, Seq + 1);
        {websocket, WS, {text, Data}} ->
            io:format("Received: ~p~n", [Data]),
            timer:sleep(1000),
            Msg = list_to_binary("hello " ++ integer_to_list(Seq)),
            ok = websocket_client:send_text(WS, Msg),
            loop(WS, Seq + 1);
        {websocket, WS, {closed, Reason}} ->
            %% The client reconnects on its own, so this is not the end: a
            %% `connected' will follow.
            io:format("Closed: ~p~n", [Reason]),
            loop(WS, Seq);
        {websocket, WS, {error, Reason}} ->
            io:format("Error: ~p~n", [Reason]),
            loop(WS, Seq);
        Other ->
            io:format("Unexpected: ~p~n", [Other]),
            loop(WS, Seq)
    end.

start_network(StaConfig) ->
    case network:wait_for_sta(StaConfig) of
        {ok, {Address, Netmask, Gateway}} ->
            io:format(
                "Acquired IP address: ~p Netmask: ~p Gateway: ~p~n",
                [Address, Netmask, Gateway]
            ),
            ok;
        Error ->
            throw({unable_to_start_network, Error})
    end.
