defmodule FusionAuth.Plugs.RefreshJWTTest do
  use ExUnit.Case

  alias FusionAuth.Plugs.RefreshJWT
  alias FusionAuth.Helpers.Mock

  @base_url Mock.base_url()
  @api_key "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
  @tenant_id "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"

  @jwt_refresh_url "/api/jwt/refresh"
  @token "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTk5MjEsImlhdCI6MTU5MTY1NjMyMSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.HAR2yqirM_9ztVIJXHvB53bJNCVXMwuirsaof8YUxYAdjskfmfwNBm9fVzU-F3Bgq-xQcIuav6_FX4EYMUZbj3Y0KPL8BJA0Q6so9apneT3E-HyiHh-xaKou7ZImEepKlgk2swTxjM4imjADpoHUKCBqAcdxsEZEP825NtbXEibXdSwd9ssx29USH1WLVS5Fc3Ro4xyUWdgnTYS9zzE02-gKiNGX6U44VMT-NLEnm-XUCv9LRGvgxNAvpl-U8zzWLxfii9njwRJSRHL6ly9EHQqEjr6ZnYTvIIS1v9J0R42bB48qv_5-9syX0hFnU4nA8z00pUyC_RI40NXGY709lg"
  @refresh "zDfaqcFepy8Q0567IEXSRgCXzn9roKwnypHegadqSZfgAzMHWzzdSg"

  setup do
    client = FusionAuth.client(@base_url, @api_key, @tenant_id)
    {:ok, %{client: client}}
  end

  describe "init/1" do
    test "accepts options", %{client: client} do
      assert [client: ^client] = RefreshJWT.init(client: client)
    end
  end

  describe "call/2" do
    test "can generate new response headers", %{client: client} do
      Mock.mock_request(
        path: @jwt_refresh_url,
        method: :post,
        status: 200,
        response_body: %{
          "token" => "new_token"
        }
      )

      response = RefreshJWT.call(conn(), client: client)

      [test_fn] = response.before_send

      result = test_fn.(response)

      assert ["new_token"] = Plug.Conn.get_resp_header(result, "authorization")
    end

    test "failure does not return response headers", %{client: client} do
      Mock.mock_request(
        path: @jwt_refresh_url,
        method: :post,
        status: 422,
        response_body: %{}
      )

      response = RefreshJWT.call(conn(), client: client)

      [test_fn] = response.before_send

      result = test_fn.(response)

      assert [] = Plug.Conn.get_resp_header(result, "authorization")
    end

    test "missing token does not return response headers", %{client: client} do
      request =
        Plug.Test.conn(:get, "/test")
        |> Plug.Conn.put_req_header("authorization", @token)
        |> Plug.Conn.put_req_header("refresh", @refresh)

      Mock.mock_request(
        path: @jwt_refresh_url,
        method: :post,
        status: 200,
        response_body: %{}
      )

      response = RefreshJWT.call(request, client: client)

      [test_fn] = response.before_send

      result = test_fn.(response)

      assert [] = Plug.Conn.get_resp_header(result, "authorization")
    end
  end

  defp conn(),
    do:
      Plug.Test.conn(:get, "/test")
      |> Plug.Conn.put_req_header("authorization", @token)
      |> Plug.Conn.put_req_header("refresh", @refresh)
end
