defmodule FusionAuth.JWTTest do
  use ExUnit.Case

  alias FusionAuth.JWT
  alias FusionAuth.TestSupport.Helpers

  @jwt_url "/api/jwt"
  @valid_jwt "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJleHAiOjE1OTEzOTUzMTYsImlhdCI6MTU5MTM5MTcxNiwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiYWRlbGFjcnV6QGNvZ2lsaXR5LmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlfQ.zUZP1A-I_R22Ez0AjfF59MJyan0bGHNuihe8BH_bGfo"

  setup do
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    client = FusionAuth.client(Helpers.base_url(), api_key, tenant_id)
    app_id = "42b54a1a-e285-41c8-9be0-7fb070c4e3b2"
    user_id = "06da543e-df3e-4011-b122-a9ff04326599"
    [client: client, app_id: app_id, user_id: user_id, tenant_id: tenant_id]
  end

  describe "Issue an Access Token by Application ID" do
    test "get_jwt_by_application_id/2 send a 200 along with a JSON body on successful request", %{
      tenant_id: tenant_id,
      app_id: app_id
    } do
      jwt_client = FusionAuth.client(
        Helpers.base_url(),
        "Bearer " <> @valid_jwt,
        tenant_id
      )
      resp_body = %{
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiIzYzIxOWU1OC1lZDBlLTRiMTgtYWQ0OC1mNGY5Mjc5M2FlMzIiLCJleHAiOjE1OTE0MDMwMDcsImlhdCI6MTU5MTM5OTU2NiwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJKV1RfU1NPIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiIzYzIxOWU1OC1lZDBlLTRiMTgtYWQ0OC1mNGY5Mjc5M2FlMzIiLCJyb2xlcyI6WyJhZG1pbiJdfQ.Nleerqr5Z4sOTLvJEBbknHc4HuhsNOVQ15IkDV7JKo0"
      }

      Helpers.mock_request(
        path: @jwt_url <> "/issue",
        method: :get,
        status: 200,
        response_body: resp_body
      )

      assert {:ok, resp_body, %Tesla.Env{status: 200}} = JWT.get_jwt_by_application_id(jwt_client, app_id)
    end

    test "get_jwt_by_application_id/2 sends 401 on invalid Authorization header", %{
      client: client,
      app_id: app_id
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/issue",
        method: :get,
        status: 401,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 401}} = JWT.get_jwt_by_application_id(client, app_id)
    end
  end

  describe "Reconcile a JWT" do
    # test "reconcile_jwt success" do
    # end

    # test "reconcile_jwt error" do
    # end
  end

  describe "Retrieve all Public Keys" do
    test "get_public_keys/1 returns a 200 status code for successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_url <> "/public-key",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_keys(client)
    end

  #   # test "get_public_keys error" do
  #   # end
  end

  describe "Retrieve a single Public Key for a specific Application by Application ID" do
    # test "get_public_key_by_application_id/1 success" do
    # end
    # test "get_public_key_by_application_id/1 error" do
    # end
  end

  # describe "Retrieve a single Public Key by Key Identifier" do
  #   # test "get_public_key_by_key_id/1 success" do
  #   # end
  #   # test "get_public_key_by_key_id/1 error" do
  #   # end
  # end

  # describe "Request a new Access Token by presenting a valid Refresh Token" do
  #   # test "refresh_jwt success" do
  #   # end
  #   # test "refresh_jwt error" do
  #   # end
  # end

  describe "Retrieve Refresh Tokens issued to a User by User ID" do
    test "get_user_refresh_tokens_by_user_id/2 returns a 200 status code for successful request", %{
      client: client,
      user_id: user_id
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/refresh?userId=#{user_id}",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               JWT.get_user_refresh_tokens_by_user_id(
                 client,
                 user_id
               )
    end

    # test "get_user_refresh_tokens_by_user_id/2 error" do
    # end
  end

  # describe "Retrieve Refresh Tokens issued to a User" do
  #   # test "get_user_refresh_tokens success" do
  #   # end
  #   # test "get_user_refresh_tokens error" do
  #   # end
  # end

  # describe "Revoke all Refresh Tokens for an entire Application by Application ID" do
  #   # test "delete_refresh_tokens_by_application_id/1 success" do
  #   # end
  #   # test "delete_refresh_tokens_by_application_id/1 error" do
  #   # end
  # end

  # describe "Revoke all Refresh Tokens issued to a User by User ID" do
  #   # test "delete_refresh_tokens_by_user_id/1 success" do
  #   # end
  #   # test "delete_refresh_tokens_by_user_id/1 error" do
  #   # end
  # end

  # describe "Revoke a single Refresh Token" do
  #   # test "delete_refresh_token/1 success" do
  #   # end
  #   # test "delete_refresh_token/1 error" do
  #   # end
  # end

  describe "Validate Access Token" do
    test "validate_jwt/1 returns a 200 status for a successful request", %{tenant_id: tenant_id} do
      jwt_client = FusionAuth.client(
        Helpers.base_url(),
        "JWT " <> @valid_jwt,
        tenant_id
      )
      resp_body = %{
        "jwt" => %{
          "applicationId" => "3c219e58-ed0e-4b18-ad48-f4f92793ae32",
          "exp" => 1487975407000,
          "iat" => 1487971807000,
          "iss" => "acme.com",
          "roles" => [
            "admin"
          ],
          "sub" => "858a4b01-62c8-4c2f-bfa7-6d018833bea7"
        }
      }

      Helpers.mock_request(
        path: @jwt_url <> "/validate",
        method: :get,
        status: 200,
        response_body: resp_body
      )

      assert {:ok, resp_body, %Tesla.Env{status: 200}} = JWT.validate_jwt(jwt_client)
    end

    test "validate_jwt/1 returns a 401 for an invalid access token", %{tenant_id: tenant_id} do
      jwt_client = FusionAuth.client(
        Helpers.base_url(),
        "JWT asdf",
        tenant_id
      )

      Helpers.mock_request(
        path: @jwt_url <> "/validate",
        method: :get,
        status: 401,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 401}} = JWT.validate_jwt(jwt_client)
    end
  end
end
