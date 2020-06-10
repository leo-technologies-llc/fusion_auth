defmodule FusionAuth.JWTTest do
  use ExUnit.Case

  alias FusionAuth.JWT
  alias FusionAuth.TestSupport.Helpers

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()

  @jwt_issue_url "/api/jwt/issue"
  @jwt_reconcile_url "/api/jwt/reconcile"
  @jwt_public_key_url "/api/jwt/public-key"
  @jwt_refresh_url "/api/jwt/refresh"
  @jwt_validate_url "/api/jwt/validate"

  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
  @api_key "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
  @tenant_id "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"
  @identity_provider_id "0c5ecd6e-a55f-4d3c-8236-f26a966392ea"
  @public_key_id "61e5576e-5f3a-0c29-650d-38c88b98f9ea"
  @refresh_token "i4HzwC5NsG7DF-Ca7z_yu8hs8FDGuSRyFR4QyBqSzXL8vq59xIsr6w"
  @token "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTk5MjEsImlhdCI6MTU5MTY1NjMyMSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.HAR2yqirM_9ztVIJXHvB53bJNCVXMwuirsaof8YUxYAdjskfmfwNBm9fVzU-F3Bgq-xQcIuav6_FX4EYMUZbj3Y0KPL8BJA0Q6so9apneT3E-HyiHh-xaKou7ZImEepKlgk2swTxjM4imjADpoHUKCBqAcdxsEZEP825NtbXEibXdSwd9ssx29USH1WLVS5Fc3Ro4xyUWdgnTYS9zzE02-gKiNGX6U44VMT-NLEnm-XUCv9LRGvgxNAvpl-U8zzWLxfii9njwRJSRHL6ly9EHQqEjr6ZnYTvIIS1v9J0R42bB48qv_5-9syX0hFnU4nA8z00pUyC_RI40NXGY709lg"

  setup do
    application_id = Application.get_env(:fusion_auth, :application_id)
    client = FusionAuth.client(Helpers.base_url(), @api_key, @tenant_id)

    on_exit(fn ->
      Application.put_env(:fusion_auth, :application_id, application_id)
    end)

    Application.put_env(:fusion_auth, :application_id, @application_id)

    [client: client]
  end

  describe "Issue an Access Token by Application ID" do
    test "issue_jwt_by_application_id/4 send a 200 along with a JSON body on successful request", %{client: client} do
      resp_body = %{ "token" => @token }

      Helpers.mock_request(
        path: @jwt_issue_url,
        query_parameters: [
          applicationId: @application_id,
          refreshToken: @refresh_token
        ],
        method: :get,
        status: 200,
        response_body: resp_body
      )

      assert {:ok, resp_body, %Tesla.Env{status: 200}} =
        JWT.issue_jwt_by_application_id(client, @token, @application_id, @refresh_token)
    end

    test "issue_jwt_by_application_id/4 send a 202 along with a JSON body on successful but denied request", %{client: client} do
      resp_body = %{ "token" => @token }

      Helpers.mock_request(
        path: @jwt_issue_url,
        query_parameters: [
          applicationId: @application_id,
          refreshToken: @refresh_token
        ],
        method: :get,
        status: 202,
        response_body: resp_body
      )

      assert {:ok, resp_body, %Tesla.Env{status: 202}} =
        JWT.issue_jwt_by_application_id(client, @token, @application_id, @refresh_token)
    end

    test "issue_jwt_by_application_id/4 sends 401 on invalid Authorization header", %{client: client} do
      Helpers.mock_request(
        path: @jwt_issue_url,
        query_parameters: [
          applicationId: @application_id,
          refreshToken: @refresh_token
        ],
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} =
        JWT.issue_jwt_by_application_id(client, @token, @application_id, @refresh_token)
    end
  end

  describe "Reconcile a JWT" do
    test "reconcile_jwt/4 returns a 200 status code for successful request", %{client: client} do
      data = %{ "token" => @token }

      Helpers.mock_request(
        path: @jwt_reconcile_url,
        method: :post,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
        JWT.reconcile_jwt(client, @application_id, data, @identity_provider_id)
    end

    test "reconcile_jwt/4 returns a 400 when the request was invalid and/or malformed", %{client: client} do
      data = %{ "token" => @token}

      Helpers.mock_request(
        path: @jwt_reconcile_url,
        method: :post,
        status: 400,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 400}} =
        JWT.reconcile_jwt(client, @application_id, data, @identity_provider_id)
    end

    test "reconcile_jwt/4 returns a 401 when the request cannot be completed", %{client: client} do
      data = %{ "token" => @token}

      Helpers.mock_request(
        path: @jwt_reconcile_url,
        method: :post,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} =
        JWT.reconcile_jwt(client, @application_id, data, @identity_provider_id)
    end

    test "reconcile_jwt/4 returns a 404 when the user is not found or the password is incorrect", %{client: client} do
      data = %{ "token" => @token}

      Helpers.mock_request(
        path: @jwt_reconcile_url,
        method: :post,
        status: 404,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 404}} =
        JWT.reconcile_jwt(client, @application_id, data, @identity_provider_id)
    end
  end

  describe "Retrieve all Public Keys" do
    test "get_public_keys/1 returns a 200 status code for successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_public_key_url,
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_keys(client)
    end

    test "get_public_keys/1-2 returns a 401 status code for incorrect Authorization header", %{client: client} do
      Helpers.mock_request(
        path: @jwt_public_key_url,
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_public_keys(client)
    end
  end

  describe "Retrieve a single Public Key for a specific Application by Application ID" do
    test "get_public_key_by_application_id/1-2 returns a 200 status code for successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_public_key_url,
        query_parameters: [
          applicationId: @application_id
        ],
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_key_by_application_id(client, @application_id)
    end

    test "get_public_key_by_application_id/1-2 returns a 401 status code for incorrect Authorization header" do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        @tenant_id
      )
      Helpers.mock_request(
        path: @jwt_public_key_url,
        query_parameters: [
          applicationId: @application_id
        ],
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_public_key_by_application_id(invalid_client, @application_id)
    end

    test "get_public_key_by_application_id/1-2 returns a 404 status code when object doesn't exist", %{client: client} do
      Helpers.mock_request(
        path: @jwt_public_key_url,
        query_parameters: [
          applicationId: "asdf"
        ],
        method: :get,
        status: 404,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 404}} = JWT.get_public_key_by_application_id(client, "asdf")
    end
  end

  describe "Retrieve a single Public Key by Key Identifier" do
    test "get_public_key_by_key_id/1-2 returns a 200 status code for successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_public_key_url,
        query_parameters: [
          kid: @public_key_id
        ],
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_key_by_key_id(client, @public_key_id)
    end

    test "get_public_key_by_key_id/1-2 returns a 401 status code for incorrect Authorization header" do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        @tenant_id
      )
        Helpers.mock_request(
          path: @jwt_public_key_url,
          query_parameters: [
            kid: @public_key_id
          ],
          method: :get,
          status: 401,
          response_body: %{}
        )

        assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_public_key_by_key_id(invalid_client, @public_key_id)
    end

    test "get_public_key_by_key_id/1-2 returns a 404 status code when object doesn't exist", %{client: client} do
      Helpers.mock_request(
        path: @jwt_public_key_url,
        query_parameters: [
          kid: @public_key_id
        ],
        method: :get,
        status: 404,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 404}} = JWT.get_public_key_by_key_id(client, @public_key_id)
    end
  end

  describe "Request a new Access Token by presenting a valid Refresh Token" do
    test "refresh_jwt/1-3 returns a 200 status code for successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        method: :post,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.refresh_jwt(client, @refresh_token, @token)
    end
  end

  describe "Retrieve Refresh Tokens issued to a User by User ID" do
    test "get_user_refresh_tokens_by_user_id/2 returns a 200 status code for successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          userId: @user_id
        ],
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_user_refresh_tokens_by_user_id(client, @user_id)
    end

    test "get_user_refresh_tokens_by_user_id/2 returns a 401 status code for incorrect Authorization header" do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        @tenant_id
      )

      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          userId: @user_id
        ],
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_user_refresh_tokens_by_user_id(invalid_client, @user_id)
    end
  end

  describe "Retrieve Refresh Tokens issued to a User" do
    test "get_user_refresh_tokens/2 returns a 200 status code for a successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_user_refresh_tokens(client, @token)
    end

    test "get_user_refresh_tokens/2 returns a 401 status code for invalid Authorization header", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_user_refresh_tokens(client, @token)
    end
  end

  describe "Revoke all Refresh Tokens for an entire Application by Application ID" do
    test "revoke_refresh_tokens_by_application_id/2 returns a 200 status code for a successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          applicationId: @application_id
        ],
        method: :delete,
        status: 200,
        response_body: nil
      )

      assert {:ok, nil, %Tesla.Env{status: 200}} = JWT.revoke_refresh_tokens_by_application_id(client, @application_id)
    end
  end

  describe "Revoke all Refresh Tokens issued to a User by User ID" do
    test "revoke_refresh_tokens_by_user_id/2 returns a 200 for success", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          userId: @user_id
        ],
        method: :delete,
        status: 200,
        response_body: nil
      )

      assert {:ok, nil, %Tesla.Env{status: 200}} = JWT.revoke_refresh_tokens_by_user_id(client, @user_id)
    end

    test "revoke_refresh_tokens_by_user_id/2 returns a 401 when you did not supply Authorization header" do
      client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        @tenant_id
      )
      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          userId: @user_id
        ],
        method: :delete,
        status: 401,
        response_body: nil
      )

      assert {:error, nil, %Tesla.Env{status: 401}} = JWT.revoke_refresh_tokens_by_user_id(client, @user_id)
    end

    test "revoke_refresh_tokens_by_user_id/2 returns a 404 when object doesn't exist", %{client: client} do
      invalid_user_id = "123456789"
      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          userId: invalid_user_id
        ],
        method: :delete,
        status: 404,
        response_body: nil
      )

      assert {:error, nil, %Tesla.Env{status: 404}} = JWT.revoke_refresh_tokens_by_user_id(client, invalid_user_id)
    end
  end

  describe "Revoke a single Refresh Token" do
    test "revoke_refresh_token/2 return a 200 status code for a successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_refresh_url,
        query_parameters: [
          token: @token
        ],
        method: :delete,
        status: 200,
        response_body: nil
      )

      assert {:ok, nil, %Tesla.Env{status: 200}} = JWT.revoke_refresh_token(client, @token)
    end
  end

  describe "Validate Access Token" do
    test "validate_jwt/1 returns a 200 status code and jwt object for a successful request", %{client: client} do
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
        path: @jwt_validate_url,
        method: :get,
        status: 200,
        response_body: resp_body
      )

      assert {:ok, resp_body, %Tesla.Env{status: 200}} = JWT.validate_jwt(client, @token)
    end

    test "validate_jwt/1 returns a 401 status code for an invalid access token", %{client: client} do
      Helpers.mock_request(
        path: @jwt_validate_url,
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.validate_jwt(client, @token)
    end
  end
end
