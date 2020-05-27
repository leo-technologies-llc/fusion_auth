defmodule FusionAuthTest do
  use ExUnit.Case
  doctest FusionAuth

  test "client has correct headers" do
    base_url = "http://localhost:9011"
    api_key = "123456"
    client = FusionAuth.client(base_url, api_key)

    assert client.pre == [
      {Tesla.Middleware.BaseUrl, :call, ["http://localhost:9011"]},
      {Tesla.Middleware.JSON, :call, [[]]},
      {Tesla.Middleware.Headers, :call, [[{"Authorization", "123456"}]]}
    ]
  end

  test "results with a status code under 300 return an ok tuple" do
    body = %{body: "1"}
    env = %Tesla.Env{status: 200, body: body}

    assert {:ok, %{body: _}, %Tesla.Env{}} = FusionAuth.result({:ok, env})
  end

  test "results with a status code over 300 return an error tuple" do
    body = %{body: "1"}
    env = %Tesla.Env{status: 400, body: body}

    assert {:error, %{body: _}, %Tesla.Env{}} = FusionAuth.result({:ok, env})
  end

  test "results that fail return an error tuple" do
    assert {:error, %{}, _} = FusionAuth.result({:error, ""})
  end
end
