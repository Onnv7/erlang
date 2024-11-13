-module(mysql_example).
-export([start/0, stop/0, query/1]).

-define(DB_HOST, "localhost").
-define(DB_USER, "root").
-define(DB_PASS, "112233").
-define(DB_NAME, "chat").
-define(DB_PORT, 3306).

start() ->
    {ok, Pid} = mysql:start_link([{host, ?DB_HOST}, {port, ?DB_PORT}, {user, ?DB_USER}, {password, ?DB_PASS}, {database, ?DB_NAME}]),
    register(mysql_conn, Pid).

stop() ->
    unregister(mysql_conn),
    ok.

query(Sql) ->
    Pid = whereis(mysql_conn),
    case Pid of
        undefined -> {error, not_connected};
        _ -> mysql:query(Pid, Sql)
    end.