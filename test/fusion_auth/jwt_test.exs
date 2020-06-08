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
    k_id = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAjocc7+h63/jSkxnT0eaNY\nx1CAKtTB3oIUd6IfxXLdbhHtt7dwtOVkSMxSXR7232ZxFN52iITL6IJNEmq7vrOPd\ndIAlS5qakwqwRR7zaH73dn3JHfDdGI3CJ4/sHbFZZztXTElU44kglbuQv+2QVEHM5\nwLLf4abUWrndjDokgVWzQukTovnS7YgvKcEsgfQDouH6lMnIw/+fXFEA+NWKK/HcX\nMmd2G98DSWUXC1dbwOj9LsPs2Jp4rksjxkzb4SLbq5Lnx22DxfURg7EQtufhr1CO8\nXuw8fA52h0xnZmbVh3zeASe6lf8hY21nPuB+Ih7gIgrUq45P020/KvdfjgKnau980\nMzuxr2DcNOKXDoNUoPys6mOQIINRE+v5Rxbekf758E+OGJjc/8uok8BmAWrolorJO\nwMKpRAnI2M523Pf4czjtz7k2E4LKGs/9UKWlCGgobQ5gwc4ZkkUgk1wx6vjCzXmFH\nkR6U6NvoXs6RBKEptSHN2uIhNNxiin2I/42JWb6kZhtDU88bC6wUwpKEVOrKlFhT0\ne9kelXHPxAq93i+rDomhMMqrZLARAZ+hA7yblN6RlMRlDoiuusG3C/NsqdNZM919r\njo+uymdkfsn07QSWWoLZzxhuyMcDUqWOn9kqbGUQKI+RVT3JNNuggMP7kpGIEobHL\n6PER9atthGjUCAwEAAQ=="
    [client: client, app_id: app_id, user_id: user_id, tenant_id: tenant_id, k_id: k_id]
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
      tenant_id: tenant_id,
      app_id: app_id
    } do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "asdf",
        tenant_id
      )
      Helpers.mock_request(
        path: @jwt_url <> "/issue",
        method: :get,
        status: 401,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 401}} = JWT.get_jwt_by_application_id(invalid_client, app_id)
    end
  end

  describe "Reconcile a JWT" do
    test "reconcile_jwt/4 returns a 200 status code for successful request", %{
      client: client,
      app_id: app_id
    } do
      data = %{ "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo"}
      identity_provider_id = "0c5ecd6e-a55f-4d3c-8236-f26a966392ea"

      Helpers.mock_request(
        path: @jwt_url <> "/reconcile",
        method: :post,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.reconcile_jwt(client, app_id, data, identity_provider_id)
    end

    test "reconcile_jwt/4 returns a 400 when the request was invalid and/or malformed", %{
      client: client,
      app_id: app_id
    } do
      data = %{ "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo"}
      identity_provider_id = "0c5ecd6e-a55f-4d3c-8236-f26a966392ea"

      Helpers.mock_request(
        path: @jwt_url <> "/reconcile",
        method: :post,
        status: 400,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 400}} = JWT.reconcile_jwt(client, app_id, data, identity_provider_id)
    end

    test "reconcile_jwt/4 returns a 401 when the request cannot be completed", %{
      client: client,
      app_id: app_id
    } do
      data = %{ "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo"}
      identity_provider_id = "0c5ecd6e-a55f-4d3c-8236-f26a966392ea"

      Helpers.mock_request(
        path: @jwt_url <> "/reconcile",
        method: :post,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.reconcile_jwt(client, app_id, data, identity_provider_id)
    end

    test "reconcile_jwt/4 returns a 404 when the user is not found or the password is incorrect", %{
      client: client,
      app_id: app_id
    } do
      data = %{ "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo"}
      identity_provider_id = "0c5ecd6e-a55f-4d3c-8236-f26a966392ea"

      Helpers.mock_request(
        path: @jwt_url <> "/reconcile",
        method: :post,
        status: 404,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 404}} = JWT.reconcile_jwt(client, app_id, data, identity_provider_id)
    end
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

    test "get_public_keys/1-2 returns a 401 status code for incorrect Authorization header", %{tenant_id: tenant_id} do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "asdf",
        tenant_id
      )
      Helpers.mock_request(
        path: @jwt_url <> "/public-key",
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_public_keys(invalid_client)
    end
  end

  describe "Retrieve a single Public Key for a specific Application by Application ID" do
    test "get_public_key_by_application_id/1-2 returns a 200 status code for successful request", %{
      client: client,
      app_id: app_id
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/public-key?applicationId=#{app_id}",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_key_by_application_id(client, app_id)
    end

    test "get_public_key_by_application_id/1-2 returns a 401 status code for incorrect Authorization header", %{
      app_id: app_id,
      tenant_id: tenant_id
    } do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        tenant_id
      )
      Helpers.mock_request(
        path: @jwt_url <> "/public-key?applicationId=#{app_id}",
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_public_key_by_application_id(invalid_client, app_id)
    end

    test "get_public_key_by_application_id/1-2 returns a 404 status code when object doesn't exist", %{
      client: client
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/public-key?applicationId=asdf",
        method: :get,
        status: 404,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 404}} = JWT.get_public_key_by_application_id(client, "asdf")
    end
  end

  describe "Retrieve a single Public Key by Key Identifier" do
    test "get_public_key_by_key_id/1-2 returns a 200 status code for successful request", %{
      client: client,
      k_id: k_id
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/public-key?kid=#{k_id}",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_public_key_by_key_id(client, k_id)
    end

    test "get_public_key_by_key_id/1-2 returns a 401 status code for incorrect Authorization header", %{
      tenant_id: tenant_id,
      k_id: k_id
    } do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        tenant_id
      )
        Helpers.mock_request(
          path: @jwt_url <> "/public-key?kid=#{k_id}",
          method: :get,
          status: 401,
          response_body: %{}
        )

        assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_public_key_by_key_id(invalid_client, k_id)
    end

    test "get_public_key_by_key_id/1-2 returns a 404 status code when object doesn't exist", %{
      client: client,
      k_id: k_id
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/public-key?kid=#{k_id}",
        method: :get,
        status: 404,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 404}} = JWT.get_public_key_by_key_id(client, k_id)
    end
  end

  describe "Request a new Access Token by presenting a valid Refresh Token" do
    test "refresh_jwt/1-3 returns a 200 status code for successful request", %{client: client} do
      refresh_token = "xRxGGEpVawiUak6He367W3oeOfh+3irw+1G1h1jc"
      token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkFuYV91STRWbWxiMU5YVXZ0cV83SjZKZFNtTSJ9.eyJleHAiOjE1ODgzNTM0NjAsImlhdCI6MTU4ODM1MzQwMCwiaXNzIjoiZnVzaW9uYXV0aC5pbyIsInN1YiI6IjAwMDAwMDAwLTAwMDAtMDAwMS0wMDAwLTAwMDAwMDAwMDAwMCIsImF1dGhlbnRpY2F0aW9uVHlwZSI6IlBBU1NXT1JEIiwiZW1haWwiOiJ0ZXN0MEBmdXNpb25hdXRoLmlvIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6InVzZXJuYW1lMCJ9.ZoIHTo3Pv0DpcELeX_wu-ZB_rd988jefZc2Ozu9_p59kttwqMm5PV8IDbgxJw9xcq9TFoNG8e_B6renoc11JC54UbiyeXBjF7EH01n9LDz-zTGqu9U72470Z4E7IPAHcyvJIBx4Mp9sgsEYAUm9Tb8ChudqNHhn6ZnXYI7Sew7CtGlu62f10wdBYGX0soYARHBv9CwhJC3-gsD2HLmqHAP_XhrpaYPNr5EAvmCHlM-JlTiEQ9bXwSc4gv-XbPQWamwy8Kcdb-g0EEAml_dC_b2CduwwYg0EoPQB3tQxzTUQzADi7K6q0CtQXv2_1VrRi6aQ4lt7v7t-Na39wGry_pA"
      Helpers.mock_request(
        path: @jwt_url <> "/refresh",
        method: :post,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %Tesla.Env{status: 200}} = JWT.refresh_jwt(client, refresh_token, token)
    end
  end

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

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_user_refresh_tokens_by_user_id(client, user_id)
    end

    test "get_user_refresh_tokens_by_user_id/2 returns a 401 status code for incorrect Authorization header", %{
      tenant_id: tenant_id,
      user_id: user_id
    } do
      invalid_client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        tenant_id
      )

      Helpers.mock_request(
        path: @jwt_url <> "/refresh?userId=#{user_id}",
        method: :get,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_user_refresh_tokens_by_user_id(invalid_client, user_id)
    end
  end

  describe "Retrieve Refresh Tokens issued to a User" do
    test "get_user_refresh_tokens/2 returns a 200 status code for a successful request", %{
      tenant_id: tenant_id
    } do
      jwt_client = FusionAuth.client(
        Helpers.base_url(),
        "Bearer " <> @valid_jwt,
        tenant_id
      )

      Helpers.mock_request(
        path: @jwt_url <> "/refresh",
        method: :delete,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = JWT.get_user_refresh_tokens(jwt_client)
    end

    test "get_user_refresh_tokens/2 returns a 401 status code for incorrect Authorization header", %{
      tenant_id: tenant_id
    } do
      invalid_jwt = "asdf"

      invalid_jwt_client = FusionAuth.client(
        Helpers.base_url(),
        "Bearer" <> invalid_jwt,
        tenant_id
      )

      Helpers.mock_request(
        path: @jwt_url <> "/refresh",
        method: :delete,
        status: 401,
        response_body: %{}
      )

      assert {:error, %{}, %Tesla.Env{status: 401}} = JWT.get_user_refresh_tokens(invalid_jwt_client)
    end
  end

  describe "Revoke all Refresh Tokens for an entire Application by Application ID" do
    test "delete_refresh_tokens_by_application_id/2 returns a 200 status code for a successful request", %{
      client: client,
      app_id: app_id
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/refresh?applicationId=#{app_id}",
        method: :delete,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %Tesla.Env{status: 200}} = JWT.delete_refresh_tokens_by_application_id(client, app_id)
    end
  end

  describe "Revoke all Refresh Tokens issued to a User by User ID" do
    test "delete_refresh_tokens_by_user_id/2 returns a 200 for success", %{
      user_id: user_id,
      client: client
    } do
      Helpers.mock_request(
        path: @jwt_url <> "/refresh?userId=#{user_id}",
        method: :delete,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %Tesla.Env{status: 200}} = JWT.delete_refresh_tokens_by_user_id(client, user_id)
    end

    test "delete_refresh_tokens_by_user_id/2 returns a 401 when you did not supply Authorization header", %{
      tenant_id: tenant_id,
      user_id: user_id
    } do
      client = FusionAuth.client(
        Helpers.base_url(),
        "-b6xI0gKV4ae2WKdcnnsEfaqgHR7u_m2MlQBQZWmCRk",
        tenant_id
      )
      Helpers.mock_request(
        path: @jwt_url <> "/refresh?userId=#{user_id}",
        method: :delete,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %Tesla.Env{status: 200}} = JWT.delete_refresh_tokens_by_user_id(client, user_id)
    end

    test "delete_refresh_tokens_by_user_id/2 returns a 404 when object doesn't exist", %{client: client} do
      invalid_user_id = "123456789"
      Helpers.mock_request(
        path: @jwt_url <> "/refresh?userId=#{invalid_user_id}",
        method: :delete,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %Tesla.Env{status: 200}} = JWT.delete_refresh_tokens_by_user_id(client, invalid_user_id)
    end
  end

  describe "Revoke a single Refresh Token" do
    test "delete_refresh_token/2 return a 200 status code for a successful request", %{client: client} do
      Helpers.mock_request(
        path: @jwt_url <> "/refresh?token=#{@valid_jwt}",
        method: :delete,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %Tesla.Env{status: 200}} = JWT.delete_refresh_token(client, @valid_jwt)
    end
  end

  describe "Validate Access Token" do
    test "validate_jwt/1 returns a 200 status code and jwt object for a successful request", %{tenant_id: tenant_id} do
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

    test "validate_jwt/1 returns a 401 status code for an invalid access token", %{tenant_id: tenant_id} do
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
