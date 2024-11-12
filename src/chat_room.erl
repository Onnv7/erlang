-module(chat_room).
-behaviour(gen_server).

%% API
-export([start_link/0, arrive/1, leave/1, get_clients/0, broadcast/1]).
%% gen_server callbacks
-export([init/1, handle_cast/2, handle_call/3, terminate/2, code_change/3]).

%% API
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

arrive(Pid) ->
    io:fwrite("Arrive: ~w~n", [Pid]),
    gen_server:cast(?MODULE, {arrive, Pid}).

leave(Pid) ->
    gen_server:cast(?MODULE, {leave, Pid}).

get_clients() ->
    gen_server:call(?MODULE, get_clients).

broadcast(Msg) ->
    Clients = get_clients(),
    io:fwrite("Broadcasting message ~w to ~w clients~n", [Msg, length(Clients)]),
    lists:foreach(fun(Pid) ->
        io:fwrite("Sending message to ~w~n", [Pid]),
        Pid ! {broadcast, Msg}
    end, Clients).

%% gen_server callbacks
init([]) ->
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