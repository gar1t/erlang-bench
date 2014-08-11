#!/usr/bin/env escript
% file-type.escript
%
% What's the fastest way to test whether a file is a file or a directory?
%
% There's filelib:is_file/1 and filelib:is_dir/1. There's also
% file:read_file_info/1. Which is built for speed?
%
% filelib_is: 2773
% read_file_info: 2746
%
% A dead heat. He he - should have checked! The filelib_is functions use
% read_file_info. Doh! Good to know our tests are sane at least.
%
-mode(compile).

-include("bench.hrl").
-include_lib("kernel/include/file.hrl").

-define(FILES, 100000).

main(_) ->
    {Tmp, Files} = create_tmp_files(),
    try
        test_filelib_is(Files),
        test_read_file_info(Files)
    after
        cleanup(Tmp)
    end.

%-------------------------------------------------------------------
% Setup
%-------------------------------------------------------------------

create_tmp_files() ->
    io:format("Creating tmp files... "),
    TmpDir = create_tmp_dir(),
    Files = create_tmp_files(TmpDir, lists:seq(1, ?FILES)),
    io:format("ok~n"),
    {TmpDir, Files}.

create_tmp_dir() ->
    Rand = erlang:phash2(os:timestamp()),
    Tmp = ["/tmp/file-type-bench-", integer_to_list(Rand)],
    ok = file:make_dir(Tmp),
    Tmp.

create_tmp_files(Tmp, Seq) ->
    [create_file_or_dir(Tmp, N) || N <- Seq].

create_file_or_dir(Tmp, N) ->
    case N rem 2 of
        0 -> {dir, create_dir(Tmp, N)};
        1 -> {file, create_file(Tmp, N)}
    end.

create_dir(Parent, N) ->
    Dir = [Parent, "/", "d", integer_to_list(N)],
    ok = file:make_dir(Dir),
    Dir.

create_file(Parent, N) ->
    File = [Parent, "/", "f", integer_to_list(N)],
    ok = file:write_file(File, ""),
    File.

cleanup(["/tmp/file-type-bench-"|_]=Tmp) ->
    io:format("Deleting tmp files... "),
    "" = os:cmd("rm -rf " ++ Tmp),
    io:format("ok~n").

%-------------------------------------------------------------------
% Shared
%-------------------------------------------------------------------

verify_file_types([{Type, File}|Rest], Fun) ->
    Type = Fun(File),
    verify_file_types(Rest, Fun);
verify_file_types([], _Fun) ->
    ok.

%-------------------------------------------------------------------
% filelib_is
%-------------------------------------------------------------------

test_filelib_is(Files) ->
    bench(
      "filelib_is",
      fun() -> verify_file_types(Files, fun filelib_file_type/1) end,
      1).

filelib_file_type(File) ->
    case filelib:is_dir(File) of
        true -> dir;
        false -> file
    end.

%-------------------------------------------------------------------
% read_file_info
%-------------------------------------------------------------------

test_read_file_info(Files) ->
    bench(
      "read_file_info",
      fun() -> verify_file_types(Files, fun read_info_file_type/1) end,
      1).

read_info_file_type(File) ->
    case file:read_file_info(File) of
        {ok, #file_info{type=directory}} -> dir;
        {ok, #file_info{type=regular}} -> file
    end.
