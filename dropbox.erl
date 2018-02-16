-module(dropbox).
-export([server/1, start/0, stop/0, edit/1, read/0, write/1]).

server(String) ->
    receive
        {write, NewString} ->
            server(NewString);
        {read, From} ->
            From ! {fileContents, String},
            server(String);
        stop -> ok
    end.

start() ->
    Server_PID = spawn(dropbox, server, [""]),
    register(server_process, Server_PID).

stop() ->
    server_process ! stop,
    unregister(server_process).

write(S) ->
    server_process ! {write, S}.

read() ->
    server_process ! {read, self()},
    receive
        {fileContents, String} -> String
    end.

edit(String) ->
    mutex:wait(),
    OldFile = read(),
    NewFile = OldFile ++ String,
    write(NewFile),
    mutex:signal().