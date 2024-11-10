-module(hello_handler).
-behaviour(cowboy_handler).

-export([init/2]).

init(Req, _Opts) ->
  Method = cowboy_req:method(Req),
  case Method of
    <<"GET">> ->
      handle_get(Req);
    <<"POST">> ->
      handle_post(Req);
    <<"PUT">> ->
      handle_put(Req);
    <<"DELETE">> ->
      handle_delete(Req);
    _ ->
      {ok, Resp} = cowboy_req:reply(405, #{<<"content-type">> => <<"application/json">>},
        <<"{\"error\": \"Method not allowed\"}">>, Req),
      {ok, Resp, []}
  end.

handle_get(Req) ->
  {ok, Resp} = cowboy_req:reply(200,
    #{<<"content-type">> => <<"application/json">>},
    <<"{\"message\": \"Hello, GET!\"}">>, Req),
  {ok, Resp, []}.

handle_post(Req) ->
  {ok, Body, Req1} = cowboy_req:read_body(Req),
  io:format("Received POST body: ~s~n", [Body]), % Thêm log để kiểm tra body nhận được
  % Chuyển tất cả phần tử thành list trước khi kết hợp
  ResponseBody = lists:concat([binary_to_list(<<"{\"message\": \"Received POST!\", \"body\": ">>),
    binary_to_list(Body),
    binary_to_list(<<"}">>)]),
  {ok, Resp} = cowboy_req:reply(200,
    #{<<"content-type">> => <<"application/json">>},
    ResponseBody, Req1),
  {ok, Resp, []}.



handle_put(Req) ->
  {ok, Body, Req1} = cowboy_req:read_body(Req),
  {ok, Resp} = cowboy_req:reply(200,
    #{<<"content-type">> => <<"application/json">>},
    <<"{\"message\": \"Received PUT!\", \"body\": ">> ++ Body ++ <<"}">>, Req1),
  {ok, Resp, []}.

handle_delete(Req) ->
  {ok, Resp} = cowboy_req:reply(200,
    #{<<"content-type">> => <<"application/json">>},
    <<"{\"message\": \"Delete successful!\"}">>, Req),
  {ok, Resp, []}.
