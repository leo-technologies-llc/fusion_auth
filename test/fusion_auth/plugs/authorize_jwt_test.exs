defmodule FusionAuth.Plugs.AuthorizeJWTTest do
  use FusionAuth.DataCase

  alias FusionAuth.{Plugs.AuthorizeJWT, TestUtilities}

  @base_url Application.get_env(:fusion_auth, :api_url)
  @api_key Application.get_env(:fusion_auth, :api_key)
  @tenant_id Application.get_env(:fusion_auth, :tenant_id)
  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"

  @user_id "eec7905c-a79d-4069-992f-5088109ac51e"

  setup do
    Application.put_env(:fusion_auth, :api_url, @base_url)

    client = FusionAuth.client(@base_url, @api_key, "")
    TestUtilities.create_tenant(client, @tenant_id)
    client_with_tenant = FusionAuth.client(@base_url, @api_key, @tenant_id)

    TestUtilities.create_application_with_id(client_with_tenant, @application_id)

    %{token: token, refresh_token: refresh_token} =
      TestUtilities.create_tokens_and_user(client_with_tenant, @application_id, @user_id)

    {:ok, %{client: client_with_tenant, token: token, refresh_token: refresh_token}}
  end

  describe "init/1" do
    test "accepts options", %{client: client} do
      base_url = @base_url

      assert [
               conn_key: :current_user,
               atomize_keys: false,
               case_format: :underscore,
               client: %Tesla.Client{
                 fun: nil,
                 post: [],
                 pre: [
                   {Tesla.Middleware.BaseUrl, :call, [^base_url]},
                   {Tesla.Middleware.JSON, :call, [[]]},
                   {Tesla.Middleware.Telemetry, :call, [[]]},
                   {Tesla.Middleware.Headers, :call,
                    [[{"Authorization", @api_key}, {"X-FusionAuth-TenantId", @tenant_id}]]}
                 ]
               }
             ] =
               AuthorizeJWT.init(
                 conn_key: :current_user,
                 atomize_keys: false,
                 case_format: :underscore,
                 client: client
               )
    end
  end

  describe "call/2" do
    test "default options", %{token: token} do
      assert %Plug.Conn{assigns: %{user: %{application_id: @application_id}}} =
               conn()
               |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
               |> AuthorizeJWT.call()
    end

    test "with options", %{client: client, token: token} do
      assert %Plug.Conn{assigns: %{current_user: %{"applicationId" => @application_id}}} =
               conn()
               |> Plug.Conn.put_req_header("authorization", "Bearer " <> token)
               |> AuthorizeJWT.call(
                 client: client,
                 atomize_keys: false,
                 case_format: :camelcase,
                 conn_key: :current_user
               )
    end

    test "JWT token prefix", %{token: token} do
      assert %Plug.Conn{assigns: %{user: %{application_id: @application_id}}} =
               conn()
               |> Plug.Conn.put_req_header("authorization", "JWT " <> token)
               |> AuthorizeJWT.call()
    end

    test "No token prefix", %{token: token} do
      assert %Plug.Conn{assigns: %{user: %{application_id: @application_id}}} =
               conn()
               |> Plug.Conn.put_req_header("authorization", token)
               |> AuthorizeJWT.call()
    end

    test "No token" do
      assert %Plug.Conn{halted: true, status: 401} =
               conn()
               |> Plug.Conn.put_req_header("authorization", "")
               |> AuthorizeJWT.call()
    end

    test "No authorization header" do
      assert %Plug.Conn{halted: true, status: 401} =
               conn()
               |> AuthorizeJWT.call()
    end

    test "failed fusion_auth validation" do
      assert %Plug.Conn{status: 401, halted: true} =
               conn()
               |> Plug.Conn.put_req_header("authorization", "Bearer " <> "bad token")
               |> AuthorizeJWT.call()
    end
  end

  defp conn(), do: Plug.Test.conn(:get, "/test")
end
