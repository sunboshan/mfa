% demonstrate brute force the hotp 3-bytes long key
-module(hack).
-export([run/0]).

run() ->
    Key = crypto:strong_rand_bytes(3),
    C = rand:uniform(256),
    V = mfa:hotp(Key,C),
    io:format("Key is ~w, hotp for ~w is ~6..0w~n",[Key,C,V]),
    T0 = calendar:datetime_to_gregorian_seconds(calendar:universal_time()),

    % get the potential key list
    List=check(0,C,V,[]),

    % recheck the potential key list to get the final key
    N1 = 256 + rand:uniform(256),
    Key1 = recheck(List,N1,mfa:hotp(Key,N1),[]),
    T1 = calendar:datetime_to_gregorian_seconds(calendar:universal_time()),
    io:format("*** found key ~w in ~ws ***~n",[<<Key1:24>>,T1-T0]).

check(16777216,_,_,Acc) -> Acc;
check(Key,C,V,Acc0) ->
    Acc =
      case mfa:hotp(<<Key:24>>,C) of
          V ->
              io:format("potential key found ~15w, hotp is ~6..0w~n",[<<Key:24>>,V]),
              [Key|Acc0];
          _ -> Acc0
      end,
    check(Key+1,C,V,Acc).

recheck([],_,_,[Key]) -> Key;
recheck([H|T],C,V,Acc0) ->
    Acc =
      case mfa:hotp(<<H:24>>,C) of
          V -> [H|Acc0];
          _ -> Acc0
      end,
    recheck(T,C,V,Acc).
