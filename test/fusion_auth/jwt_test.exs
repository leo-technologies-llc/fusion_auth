defmodule FusionAuth.JWTTest do
  use FusionAuth.DataCase

  alias FusionAuth.{JWT, TestUtilities}

  @invalid_user_id "25a872da-bb44-4af8-a43d-e7bcb5351ebc"
  @invalid_token "123123"
  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
  @invalid_application_id "88ebf5e2-097c-4b28-ba57-6effb7f3a627"
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"

  setup do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    TestUtilities.create_application_with_id(client_with_tenant, @application_id)
    TestUtilities.enable_JWT(client, @application_id)
    TestUtilities.enable_refresh_tokens(client, @application_id)

    %{token: token, refresh_token: refresh_token} =
      TestUtilities.create_tokens_and_user(client_with_tenant, @application_id, @user_id)

    {:ok,
     %{client: client_with_tenant, token: token, refresh_token: refresh_token, base_url: base_url}}
  end

  describe "Issue an Access Token by Application ID" do
    test "issue_jwt_by_application_id/4 send a 200 along with a JSON body on successful request",
         %{client: client, token: token, refresh_token: refresh_token} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               JWT.issue_jwt_by_application_id(client, token, @application_id, refresh_token)
    end

    test "issue_jwt_by_application_id/4 sends 401 when using an invalid token", %{
      client: client,
      refresh_token: refresh_token
    } do
      assert {:error, "", %Tesla.Env{status: 401}} =
               JWT.issue_jwt_by_application_id(
                 client,
                 @invalid_token,
                 @application_id,
                 refresh_token
               )
    end
  end

  describe "Retrieve all Public Keys" do
    test "get_public_keys/1 returns a 200 status code for successful request", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_keys(client)
    end
  end

  describe "Retrieve a single Public Key for a specific Application by Application ID" do
    test "get_public_key_by_application_id/2 returns a 200 status code for successful request", %{
      client: client
    } do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               JWT.get_public_key_by_application_id(client, @application_id)
    end

    test "get_public_key_by_application_id/2 returns a 404 status code for an invalid application id",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               JWT.get_public_key_by_application_id(client, @invalid_application_id)
    end
  end

  describe "Retrieve a single Public Key by Key Identifier" do
    test "get_public_key_by_key_id/2 returns a 200 status code for successful request", %{
      client: client
    } do
      {:ok, keys, _} = JWT.get_public_keys(client)
      key_id = Map.keys(keys["publicKeys"]) |> Enum.at(0)

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_key_by_key_id(client, key_id)
    end

    test "get_public_key_by_key_id/2 returns a 404 status code when object doesn't exist", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               JWT.get_public_key_by_key_id(client, "bad-id")
    end
  end

  describe "Request a new Access Token by presenting a valid Refresh Token" do
    test "refresh_jwt/3 returns a 200 status code for successful request", %{
      client: client,
      refresh_token: refresh_token,
      token: token
    } do
      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.refresh_jwt(client, refresh_token, token)
    end
  end

  describe "Retrieve Refresh Tokens issued to a User by User ID" do
    test "get_user_refresh_tokens_by_user_id/2 returns a 200 status code for successful request",
         %{client: client} do
      TestUtilities.wait_for_process(fn ->
        {status, _, _} = FusionAuth.Users.get_user_by_id(client, @user_id)
        if status == :ok, do: :continue, else: :wait
      end)

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               JWT.get_user_refresh_tokens_by_user_id(client, @user_id)
    end

    test "get_user_refresh_tokens_by_user_id/2 returns a 401 status code for incorrect Authorization header",
         %{base_url: base_url} do
      client = FusionAuth.client(base_url, "", "")

      assert {:error, "", %Tesla.Env{status: 401}} =
               JWT.get_user_refresh_tokens_by_user_id(client, @user_id)
    end
  end

  describe "Retrieve Refresh Tokens issued to a User" do
    test "get_user_refresh_tokens/2 returns a 200 status code for a successful request", %{
      client: client,
      token: token
    } do
      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_user_refresh_tokens(client, token)
    end

    test "get_user_refresh_tokens/2 returns a 401 status code for an invalid token",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 401}} =
               JWT.get_user_refresh_tokens(client, "bad-token")
    end
  end

  describe "Revoke all Refresh Tokens for an entire Application by Application ID" do
    test "revoke_refresh_tokens_by_application_id/2 returns a 200 status code for a successful request",
         %{client: client} do
      assert {:ok, "", %Tesla.Env{status: 200}} =
               JWT.revoke_refresh_tokens_by_application_id(client, @application_id)
    end
  end

  describe "Revoke all Refresh Tokens issued to a User by User ID" do
    test "revoke_refresh_tokens_by_user_id/2 returns a 200 for success", %{client: client} do
      assert {:ok, "", %Tesla.Env{status: 200}} =
               JWT.revoke_refresh_tokens_by_user_id(client, @user_id)
    end

    test "revoke_refresh_tokens_by_user_id/2 returns a 401 when you did not supply Authorization header",
         %{base_url: base_url} do
      client = FusionAuth.client(base_url, "", "", [:disable_authorization_header])

      assert {:error, "", %Tesla.Env{status: 401}} =
               JWT.revoke_refresh_tokens_by_user_id(client, @user_id)
    end

    test "revoke_refresh_tokens_by_user_id/2 returns a 400 when the user doesn't exist", %{
      client: client
    } do
      error = %{
        "fieldErrors" => %{
          "userId" => [
            %{
              "code" => "[invalid]userId",
              "message" =>
                "Invalid [userId] property. No user exists with an Id [25a872da-bb44-4af8-a43d-e7bcb5351ebc]."
            }
          ]
        }
      }

      assert {:error, ^error, %Tesla.Env{status: 400}} =
               JWT.revoke_refresh_tokens_by_user_id(client, @invalid_user_id)
    end
  end

  describe "Revoke a single Refresh Token" do
    test "revoke_refresh_token/2 return a 200 status code for a successful request", %{
      client: client,
      refresh_token: refresh_token
    } do
      assert {:ok, "", %Tesla.Env{status: 200}} = JWT.revoke_refresh_token(client, refresh_token)
    end
  end

  describe "Validate Access Token" do
    test "validate_jwt/2 returns a 200 status code and jwt object for a successful request", %{
      client: client,
      token: token
    } do
      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.validate_jwt(client, token)
    end

    test "validate_jwt/2 returns a 401 status code for an invalid access token", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 401}} = JWT.validate_jwt(client, "bad-token")
    end
  end
end
