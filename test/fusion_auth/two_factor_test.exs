defmodule FusionAuth.TwoFactorTest do
  use ExUnit.Case

  alias FusionAuth.TwoFactor
  alias FusionAuth.TestSupport.Helpers

  @api_key "jnx6HeVRrLkulpwiUNh9s52qlJqp5dox77NcDVkf9YI"
  @tenant_id "d577a020-30cb-85de-bf30-785cb65997d6"

  @user_id "fffc8648-bab2-4bdd-b2eb-a48e853d9217"
  @token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.6hqLDc7-PxHpQRjsdDVt0NcDLcs6ZcoUy5hbwSzMcLM"
  @code "819169"
  @delivery "TextMessage"
  @secret "SP2m6K2Dg/x2JN9DyQvZ"
  @mobile_phone "2015960074"
  @two_factor_id ""

  @two_factor_url "/api/user/two-factor"
  @two_factor_send_url "/api/two-factor/send"
  @two_factor_secret_url "/api/two-factor/secret"

  setup do
    application_id = Application.get_env(:fusion_auth, :application_id)
    client = FusionAuth.client(Helpers.base_url(), @api_key, @tenant_id)

    on_exit(fn ->
      Application.put_env(:fusion_auth, :application_id, application_id)
    end)

    Application.put_env(:fusion_auth, :application_id, @application_id)

    [client: client]
  end

  describe "Enable Two Factor Authentication by User Id" do
    test "enable_two_factor_by_user_id/5 send a 200 on successful request", %{client: client} do
    end

    test "enable_two_factor_by_user_id/5 send a 404 when the user does not exist", %{client: client} do
    end

    test "enable_two_factor_by_user_id/5 send a 421 when code request parameter is not valid", %{client: client} do
    end
  end

  describe "Enable Two Factor Authentication by JWT" do
    test "enable_two_factor_by_jwt/5 send a 200 on successful request", %{client: client} do
    end

    test "enable_two_factor_by_jwt/5 send a 404 when the user does not exist", %{client: client} do
    end

    test "enable_two_factor_by_jwt/5 send a 421 when code request parameter is not valid", %{client: client} do
    end
  end

  describe "Disable Two Factor by User Id" do
    test "disable_two_factor_by_user_id/3 send a 200 on successful request", %{client: client} do
    end

    test "disable_two_factor_by_user_id/3 send a 404 when the user does not exist", %{client: client} do
    end

    test "disable_two_factor_by_user_id/3 send a 421 when code request parameter is not valid", %{client: client} do
    end
  end

  describe "Send a Two Factor code to an existing User by Id" do
    test "send_two_factor_code_by_user_id/3 send a 200 on successful request", %{client: client} do
    end
  end

  describe "Send a Two Factor code to a mobile phone" do
    test "send_two_factor_code_to_mobile_phone/3 send a 200 on successful request", %{client: client} do
    end
  end

  describe "Send a Two Factor code to complete Two Factor Login" do
    test "send_two_factor_code_to_complete_login/2 send a 200 on successful request", %{client: client} do
    end
  end

  describe "Generate a Two Factor Secret" do
    test "generate_secret/1 send a 200 along with a JSON body on successful request", %{client: client} do
    end
  end

  describe "Generate a Two Factor Secret by JWT" do
    test "generate_secret_for_jwt/2 send a 200 along with a JSON body on successful request", %{client: client} do
    end
  end
end
