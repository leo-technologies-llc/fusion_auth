# defmodule FusionAuth.Plugs.AuthorizeJWTTest do
#   use ExUnit.Case

#   alias FusionAuth.Plugs.AuthorizeJWT
#   alias FusionAuth.Helpers.Mock

#   @base_url Mock.base_url()
#   @api_key "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
#   @tenant_id "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
#   @validate_jwt_url "/api/jwt/validate"
#   @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
#   @token "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTk5MjEsImlhdCI6MTU5MTY1NjMyMSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.HAR2yqirM_9ztVIJXHvB53bJNCVXMwuirsaof8YUxYAdjskfmfwNBm9fVzU-F3Bgq-xQcIuav6_FX4EYMUZbj3Y0KPL8BJA0Q6so9apneT3E-HyiHh-xaKou7ZImEepKlgk2swTxjM4imjADpoHUKCBqAcdxsEZEP825NtbXEibXdSwd9ssx29USH1WLVS5Fc3Ro4xyUWdgnTYS9zzE02-gKiNGX6U44VMT-NLEnm-XUCv9LRGvgxNAvpl-U8zzWLxfii9njwRJSRHL6ly9EHQqEjr6ZnYTvIIS1v9J0R42bB48qv_5-9syX0hFnU4nA8z00pUyC_RI40NXGY709lg"

#   @valid_response %{
#     "jwt" => %{
#       "applicationId" => @application_id,
#       "aud" => "861f5558-34a8-43e4-ab50-317bdcd47671",
#       "authenticationType" => "PASSWORD",
#       "email" => "ckempton@cogility.com",
#       "email_verified" => true,
#       "exp" => 1_591_814_524,
#       "iat" => 1_591_810_924,
#       "iss" => "acme.com",
#       "preferred_username" => "ckempton",
#       "roles" => ["admin", "user"],
#       "sub" => "84846873-89d2-44f8-91e9-dac80f420cb2"
#     }
#   }

#   setup do
#     base_url = Application.get_env(:fusion_auth, :api_url)
#     api_key = Application.get_env(:fusion_auth, :api_key)
#     tenant_id = Application.get_env(:fusion_auth, :tenant_id)

#     Application.put_env(:fusion_auth, :api_url, @base_url)
#     Application.put_env(:fusion_auth, :api_key, @api_key)
#     Application.put_env(:fusion_auth, :tenant_id, @tenant_id)

#     on_exit(fn ->
#       Application.put_env(:fusion_auth, :api_url, base_url)
#       Application.put_env(:fusion_auth, :api_key, api_key)
#       Application.put_env(:fusion_auth, :tenant_id, tenant_id)
#     end)

#     client = FusionAuth.client()
#     {:ok, %{client: client}}
#   end

#   describe "init/1" do
#     test "accepts options", %{client: client} do
#       base_url = Mock.base_url()

#       assert [
#                conn_key: :current_user,
#                atomize_keys: false,
#                case_format: :underscore,
#                client: %Tesla.Client{
#                  adapter: {Tesla.Mock, :call, [[]]},
#                  fun: nil,
#                  post: [],
#                  pre: [
#                    {Tesla.Middleware.BaseUrl, :call, [^base_url]},
#                    {Tesla.Middleware.JSON, :call, [[]]},
#                    {Tesla.Middleware.Telemetry, :call, [[]]},
#                    {Tesla.Middleware.Headers, :call,
#                     [[{"Authorization", @api_key}, {"X-FusionAuth-TenantId", @tenant_id}]]}
#                  ]
#                }
#              ] =
#                AuthorizeJWT.init(
#                  conn_key: :current_user,
#                  atomize_keys: false,
#                  case_format: :underscore,
#                  client: client
#                )
#     end
#   end

#   describe "call/2" do
#     test "default options" do
#       mock_http_request()

#       assert %Plug.Conn{assigns: %{user: %{application_id: @application_id}}} =
#                conn()
#                |> Plug.Conn.put_req_header("authorization", "Bearer " <> @token)
#                |> AuthorizeJWT.call()
#     end

#     test "with options", %{client: client} do
#       mock_http_request()

#       assert %Plug.Conn{assigns: %{current_user: %{"applicationId" => @application_id}}} =
#                conn()
#                |> Plug.Conn.put_req_header("authorization", "Bearer " <> @token)
#                |> AuthorizeJWT.call(
#                  client: client,
#                  atomize_keys: false,
#                  case_format: :camelcase,
#                  conn_key: :current_user
#                )
#     end

#     test "JWT token prefix" do
#       mock_http_request()

#       assert %Plug.Conn{assigns: %{user: %{application_id: @application_id}}} =
#                conn()
#                |> Plug.Conn.put_req_header("authorization", "JWT " <> @token)
#                |> AuthorizeJWT.call()
#     end

#     test "No token prefix" do
#       mock_http_request()

#       assert %Plug.Conn{assigns: %{user: %{application_id: @application_id}}} =
#                conn()
#                |> Plug.Conn.put_req_header("authorization", @token)
#                |> AuthorizeJWT.call()
#     end

#     test "No token" do
#       mock_http_request()

#       assert %Plug.Conn{halted: true, status: 401} =
#                conn()
#                |> Plug.Conn.put_req_header("authorization", "")
#                |> AuthorizeJWT.call()
#     end

#     test "No authorization header" do
#       mock_http_request()

#       assert %Plug.Conn{halted: true, status: 401} =
#                conn()
#                |> AuthorizeJWT.call()
#     end

#     test "failed fusion_auth validation" do
#       Mock.mock_request(
#         path: @validate_jwt_url,
#         method: :get,
#         status: 404,
#         response_body: "",
#         headers: [authorization: "JWT" <> @token]
#       )

#       assert %Plug.Conn{status: 401, halted: true} =
#                conn()
#                |> Plug.Conn.put_req_header("authorization", "Bearer " <> @token)
#                |> AuthorizeJWT.call()
#     end
#   end

#   defp mock_http_request() do
#     Mock.mock_request(
#       path: @validate_jwt_url,
#       method: :get,
#       status: 200,
#       response_body: @valid_response
#     )
#   end

#   defp conn(), do: Plug.Test.conn(:get, "/test")
# end
