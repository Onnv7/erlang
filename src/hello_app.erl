-module(hello_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    mongo_id_server:start_link(),
    case mongo_conn:start_link() of
        {ok, _Conn} ->
            Dispatch = cowboy_router:compile([
                {'_', [{"/hello", hello_handler, []}]}
            ]),
            {ok, _} = cowboy:start_clear(my_http_listener,
                [{port, 8080}],
                #{env => #{dispatch => Dispatch}}
            ),
            io:format("Server started at http://localhost:8080/hello~n"),
            {ok, self()};
        {error, Reason} ->
            io:format("Failed to connect to MongoDB: ~p~n", [Reason]),
            {error, Reason}
    end.

stop(_State) ->
    mongo_conn:stop(),
    ok.
