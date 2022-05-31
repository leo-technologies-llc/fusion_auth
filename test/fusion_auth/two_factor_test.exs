defmodule FusionAuth.TwoFactorTest do
  use FusionAuth.DataCase

  alias FusionAuth.{TwoFactor, TestUtilities}
  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"

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

    %{token: token, refresh_token: refresh_token} =
      FusionAuth.TestUtilities.create_tokens_and_user(client_with_tenant, application_id, user_id)

    {:ok, %{client: client_with_tenant, token: token, refresh_token: refresh_token}}
  end

  describe "generate a shared secret" do
    test "generate_secret/1 creates a secret", %{client: client} do
      {:ok, result, _} = TwoFactor.generate_secret(client)
      assert Map.has_key?(result, "secret")
    end

    test "generate_secret/2 creates a secret", %{client: client, token: token} do
      {:ok, result, _} = TwoFactor.generate_secret_for_jwt(client, token)
      assert Map.has_key?(result, "secret")
    end
  end
end
