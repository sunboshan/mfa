-module(mfa).
-export([main/1]).
-export([totp/1,hotp/2]).

-define(epoch,calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}})).

main([]) ->
    {ok,[[Home]]} = init:get_argument(home),
    {ok,List} = file:consult(filename:join(Home,".mfa/config")),
    MaxWidth = lists:foldl(fun({E,_},Acc) -> max(length(atom_to_list(E)),Acc) end,0,List),
    lists:foreach(fun(E) -> run(E,MaxWidth) end,List).

run({Name,Key},Width) ->
    {Passcode,Time} = totp(Key),
    io:format("~*w: ~6..0w, valid in ~ws~n",[Width,Name,Passcode,Time]).

-spec totp(string()) -> {integer(),integer()}.
totp(Key0) ->
    T = calendar:datetime_to_gregorian_seconds(calendar:now_to_datetime(erlang:timestamp())) - ?epoch,
    Key = decode32(string:uppercase(Key0)),
    {hotp(Key,T div 30), 30-(T rem 30)}.

-spec hotp(string(),binary()) -> integer().
hotp(Key,C) ->
    <<_:156,Sz:4>> = Hmac = crypto:hmac(sha,Key,<<C:64>>),
    <<_:Sz/binary,_:1,N:31,_/binary>> = Hmac,
    N rem 1000000.

decode32([H0|T0]) ->
    H=dec(H0),
    T=decode32(T0),
    <<H:5,T/bits>>;
decode32([]) -> <<>>.

dec($A) -> 0;
dec($B) -> 1;
dec($C) -> 2;
dec($D) -> 3;
dec($E) -> 4;
dec($F) -> 5;
dec($G) -> 6;
dec($H) -> 7;
dec($I) -> 8;
dec($J) -> 9;
dec($K) -> 10;
dec($L) -> 11;
dec($M) -> 12;
dec($N) -> 13;
dec($O) -> 14;
dec($P) -> 15;
dec($Q) -> 16;
dec($R) -> 17;
dec($S) -> 18;
dec($T) -> 19;
dec($U) -> 20;
dec($V) -> 21;
dec($W) -> 22;
dec($X) -> 23;
dec($Y) -> 24;
dec($Z) -> 25;
dec($2) -> 26;
dec($3) -> 27;
dec($4) -> 28;
dec($5) -> 29;
dec($6) -> 30;
dec($7) -> 31.
