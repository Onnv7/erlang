-module(mongo_conn).
-export([start_link/0, stop/0, get_db/0]).

-define(DB_NAME, <<"erlang">>).
-define(HOST, "localhost").
-define(PORT, 27017).

start_link() ->
    case mc_worker_api:connect([{host, ?HOST}, {port, ?PORT}]) of
        {ok, Conn} ->
            register(mongo_conn, Conn),
            {ok, Conn};
        {error, Reason} ->
            io:fwrite("Failed to connect to MongoDB: ~p~n", [Reason]),
            {error, Reason}
    end.

stop() ->
    Conn = whereis(mongo_conn),
    mc_worker_api:disconnect(Conn),
    unregister(mongo_conn),
    ok.

get_db() ->
    whereis(mongo_conn).