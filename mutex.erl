-module(mutex).
-export([start/0, stop/0, wait/0, signal/0, free/0, busy/1]).
start() ->
  register(mutex, spawn(mutex, free, [])).
stop() ->
mutex ! stop.
wait() ->
  mutex ! {wait, self()},
  receive ok -> ok end.
signal() ->
  mutex ! {signal, self()}, ok.
free() ->
  receive
    {wait, Pid} -> Pid ! ok, busy(Pid);
    stop -> ok
  end.
busy(Pid) ->
  receive
    {signal, Pid} -> free()
  end.