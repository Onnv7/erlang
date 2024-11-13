-module(chat_room).
-behaviour(gen_server).

%% API
-export([start_link/0, arrive/1, leave/1, get_clients/0, broadcast/2]).
%% gen_server callbacks
-export([init/1, handle_cast/2, handle_call/3, terminate/2, code_change/3]).

%% API
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

arrive(Pid) ->
    io:fwrite("Arrive: ~w~n", [Pid]),
    gen_server:cast(?MODULE, {arrive, Pid}),
    query("INSERT INTO clients (pid) VALUES ('" ++ erlang:pid_to_list(Pid) ++ "')").

leave(Pid) ->
    gen_server:cast(?MODULE, {leave, Pid}),
    query("DELETE FROM clients WHERE pid = '" ++ erlang:pid_to_list(Pid) ++ "'").

get_clients() ->
    gen_server:call(?MODULE, get_clients).

broadcast(SenderPid, Msg) ->
    Clients = get_clients(),
    io:fwrite("Broadcasting message ~w to ~w clients~n", [Msg, length(Clients)]),
    lists:foreach(fun(Pid) ->
        if
            Pid =/= SenderPid ->
                io:fwrite("Sending message to ~w~n", [Pid]),
                Pid ! {broadcast, Msg};
            true ->
                ok
        end
    end, Clients).

%% gen_server callbacks
init([]) ->
    create_table(),
    {ok, []}.

handle_cast({arrive, Pid}, State) ->
    {noreply, lists:usort([Pid | State])}; % Ensure no duplicates

handle_cast({leave, Pid}, State) ->
    {noreply, lists:delete(Pid, State)}.

handle_call(get_clients, _From, State) ->
    {reply, State, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

create_table() ->
    Sql = "CREATE TABLE IF NOT EXISTS clients (pid VARCHAR(255) PRIMARY KEY)",
    query(Sql).

query(Sql) ->
    Pid = whereis(mysql_conn),
    case Pid of
        undefined -> {error, not_connected};
        _ -> mysql:query(Pid, Sql)
    end.