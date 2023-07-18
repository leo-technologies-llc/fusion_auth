defmodule FusionAuth.Plugs.RefreshJWTTest do
  use FusionAuth.DataCase

  alias FusionAuth.Plugs.RefreshJWT
  alias FusionAuth.TestUtilities

  @jwt_refresh_url "/api/jwt/refresh"
  @invalid_token "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTk5MjEsImlhdCI6MTU5MTY1NjMyMSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.HAR2yqirM_9ztVIJXHvB53bJNCVXMwuirsaof8YUxYAdjskfmfwNBm9fVzU-F3Bgq-xQcIuav6_FX4EYMUZbj3Y0KPL8BJA0Q6so9apneT3E-HyiHh-xaKou7ZImEepKlgk2swTxjM4imjADpoHUKCBqAcdxsEZEP825NtbXEibXdSwd9ssx29USH1WLVS5Fc3Ro4xyUWdgnTYS9zzE02-gKiNGX6U44VMT-NLEnm-XUCv9LRGvgxNAvpl-U8zzWLxfii9njwRJSRHL6ly9EHQqEjr6ZnYTvIIS1v9J0R42bB48qv_5-9syX0hFnU4nA8z00pUyC_RI40NXGY709lg"
  @invalid_refresh "zDfaqcFepy8Q0567IEXSRgCXzn9roKwnypHegadqSZfgAzMHWzzdSg"
  @user_id "a5332a43-8ae2-4895-9699-ae6213f7cb92"
  @application_id "c7592dff-a6d2-4322-aeef-d50d548b40aa"

  setup do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    TestUtilities.create_application_with_id(client_with_tenant, @application_id)

    %{token: token, refresh_token: refresh_token} =
      TestUtilities.create_tokens_and_user(client_with_tenant, @application_id, @user_id)

    {:ok, %{client: client_with_tenant, token: token, refresh_token: refresh_token}}
  end

  describe "init/1" do
    test "accepts options", %{client: client} do
      assert [client: ^client] = RefreshJWT.init(client: client)
    end
  end

  describe "call/2" do
    test "can generate new response headers", %{
      client: client,
      token: token,
      refresh_token: refresh_token
    } do
      response = RefreshJWT.call(conn(token, refresh_token), client: client)

      [test_fn] = response.private.before_send

      result = test_fn.(response)
      [new_token] = Plug.Conn.get_resp_header(result, "authorization")
      jwt_regex = ~r"^(?:[\w-]*\.){2}[\w-]*$"
      assert String.match?(new_token, jwt_regex)
    end

    test "failure does not return response headers", %{client: client} do
      response = RefreshJWT.call(conn(@invalid_token, @invalid_refresh), client: client)

      [test_fn] = response.private.before_send

      result = test_fn.(response)

      assert [] = Plug.Conn.get_resp_header(result, "authorization")
    end

    test "missing token does not return response headers", %{client: client} do
      request =
        Plug.Test.conn(:get, "/test")
        |> Plug.Conn.put_req_header("authorization", @invalid_token)
        |> Plug.Conn.put_req_header("refresh", @invalid_refresh)

      Tesla.post(client, @jwt_refresh_url, %{})

      response = RefreshJWT.call(request, client: client)

      [test_fn] = response.private.before_send

      result = test_fn.(response)

      assert [] = Plug.Conn.get_resp_header(result, "authorization")
    end
  end

  defp conn(token, refresh_token),
    do:
      Plug.Test.conn(:get, "/test")
      |> Plug.Conn.put_req_header("authorization", token)
      |> Plug.Conn.put_req_header("refresh", refresh_token)
end
