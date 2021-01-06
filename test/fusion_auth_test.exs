defmodule FusionAuthTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  @base_url "http://localhost:9011"
  @api_key "123456"
  @tenant_id "234567"

  setup do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    Application.put_env(:fusion_auth, :api_url, @base_url)
    Application.put_env(:fusion_auth, :api_key, @api_key)
    Application.put_env(:fusion_auth, :tenant_id, @tenant_id)

    on_exit(fn ->
      Application.put_env(:fusion_auth, :api_url, base_url)
      Application.put_env(:fusion_auth, :api_key, api_key)
      Application.put_env(:fusion_auth, :tenant_id, tenant_id)
    end)

    :ok
  end

  test "client has correct headers" do
    client = FusionAuth.client(@base_url, @api_key, @tenant_id)

    assert client.pre == [
             {Tesla.Middleware.BaseUrl, :call, [@base_url]},
             {Tesla.Middleware.JSON, :call, [[]]},
             {Tesla.Middleware.Headers, :call,
              [[{"Authorization", @api_key}, {"X-FusionAuth-TenantId", @tenant_id}]]}
           ]
  end

  test "client has correct headers using Application variables" do
    client = FusionAuth.client()

    assert client.pre == [
             {Tesla.Middleware.BaseUrl, :call, [@base_url]},
             {Tesla.Middleware.JSON, :call, [[]]},
             {Tesla.Middleware.Headers, :call,
              [[{"Authorization", @api_key}, {"X-FusionAuth-TenantId", @tenant_id}]]}
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
    assert capture_log(fn -> FusionAuth.result({:error, ""}) end) =~
               "FusionAuth request resulted in an error.\n  Error: \"\""
  end
end
