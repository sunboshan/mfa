% demonstrate parallel brute force the hotp key utilizing all cpu power
-module(phack).
-export([run/1]).

% N - length of key
run(N) ->
    spawn(fun() -> validator(N) end).

validator(N) ->
    T0 = calendar:datetime_to_gregorian_seconds(calendar:universal_time()),
    Me = self(),

    % seperate the work evenly to all CPUs
    Total = 1 bsl (N*8),
    CPUs = erlang:system_info(schedulers_online),
    List = schedule(0,Total div CPUs,CPUs,Total,[]),
    io:format("Started ~w worker processes.~n",[CPUs]),

    % generate a random key
    Key = crypto:strong_rand_bytes(N),
    C = rand:uniform(1024),
    V = mfa:hotp(Key,C),
    io:format("Random generated key is ~w, hotp for ~6..0w is ~w~n",[Key,C,V]),

    % start workers
    lists:foreach(fun(E) -> spawn_link(fun() -> worker(Me,E,{C,V},N*8) end) end,List),

    % calculate a verify hotp value and enter loop
    C1 = rand:uniform(1024) + 1024,
    V1 = mfa:hotp(Key,C1),
    loop(T0,{C1,V1}).

loop(T0,{C,V}) ->
    receive
        {found,From,Key0} ->
            % if a potential key is found, just verify the key with another hotp result
            case mfa:hotp(Key0,C) of
                V ->
                    T1 = calendar:datetime_to_gregorian_seconds(calendar:universal_time()),
                    io:format("key ~w found by worker ~w in ~ws~n",[Key0,From,T1-T0]),

                    % since this process links to all the worker processes,
                    % exit here will also kill all the other worker processes
                    exit(1);
                _->
                    loop(T0,{C,V})
            end
    end.

schedule(Start,_Len,1,Last,Acc) ->
    [{Start,Last+1}|Acc];

schedule(Start,Len,Count,Last,Acc0) ->
    Acc = [{Start,Start+Len}|Acc0],
    schedule(Start+Len,Len,Count-1,Last,Acc).

worker(_,{End,End},_,_) -> ok;
worker(From,{Start,End},{C,V},N) ->
    case mfa:hotp(<<Start:N>>,C) of
        V ->
            io:format("potential key ~*w found by worker ~w, hotp is ~6..0w~n",[(N div 2)+3,<<Start:N>>,self(),V]),
            From ! {found,self(),<<Start:N>>};
        _ -> ok
    end,
    worker(From,{Start+1,End},{C,V},N).
