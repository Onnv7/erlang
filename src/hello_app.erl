-module(hello_app).
-behaviour(application).

-export([start/2, stop/1]).

-define(DB_HOST, "localhost").
-define(DB_USER, "root").
-define(DB_PASS, "112233").
-define(DB_NAME, "chat").
-define(DB_PORT, 3306).

start(_StartType, _StartArgs) ->
     {ok, Pid} = mysql:start_link([{host, ?DB_HOST}, {port, ?DB_PORT}, {user, ?DB_USER}, {password, ?DB_PASS}, {database, ?DB_NAME}]),
    register(mysql_conn, Pid),
    % Start the chat_room gen_server
    chat_room:start_link(),
    % Start the Cowboy server
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/hello", hello_handler, []},
            {"/", hello_ws_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8081}],
        #{env => #{dispatch => Dispatch}}
    ),
    io:format("Server started at http://localhost:8081/hello and ws://localhost:8081/ws~n"),
    {ok, self()}.

stop(_State) ->
     unregister(mysql_conn),
    ok.