defmodule FusionAuth.LoginTest do
  use FusionAuth.DataCase

  alias FusionAuth.{Login, TestUtilities, Registrations, Users}

  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"
  @ip_address "0.0.0.0"

  @invalid_one_time_passord_response %{
    "fieldErrors" => %{
      "oneTimePassword" => [
        %{
          "code" => "[invalid]oneTimePassword",
          "message" => "Invalid [oneTimePassword] property."
        }
      ]
    }
  }

  @user %{username: "johndoe", password: "password", email: "john@doe.com"}

  setup do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    Application.put_env(:fusion_auth, :application_id, @application_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant_with_email_template(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)
    TestUtilities.create_application_with_id(client_with_tenant, @application_id)
    TestUtilities.enable_refresh_tokens(client, @application_id)

    data = %{
      registration: %{
        applicationId: @application_id
      },
      user: @user
    }

    Registrations.create_user_and_registration(
      client,
      data,
      @user_id
    )

    # sleeping to allow indexing for registration
    TestUtilities.wait_for_process(fn ->
      if TestUtilities.user_exists?(client, @user), do: :continue, else: :wait
    end)

    {:ok, %{client: client_with_tenant}}
  end

  describe "login_user/3" do
    test "can login user", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Login.login_user(client, @user[:email], @user[:password])
    end

    test "user not found", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Login.login_user(client, @user[:email], "test")
    end
  end

  describe "login_user/4" do
    test "can login user with additional options", %{client: client} do
      {:ok, %{}, %Tesla.Env{status: 200}} =
        Login.login_user(client, @user[:email], @user[:password], %{ipAddress: @ip_address})
    end

    test "can login user with application_id", %{client: client} do
      {:ok, %{}, %Tesla.Env{status: 200}} =
        Login.login_user(client, @application_id, @user[:email], @user[:password])
    end
  end

  describe "login_user/5" do
    test "nil application_id does not return a refreshToken", %{client: client} do
      {:ok, response, %Tesla.Env{status: 200}} =
        Login.login_user(client, nil, @user[:email], @user[:password], %{})

      assert Map.get(response, "refreshToken") == nil
    end

    test "with all valid attributes", %{client: client} do
      assert {:ok, %{"token" => _, "refreshToken" => _, "user" => _}, %Tesla.Env{status: 200}} =
               Login.login_user(client, @application_id, @user[:email], @user[:password], %{})
    end
  end

  describe "login_one_time_password/2" do
    test "invalid one_time_password", %{client: client} do
      assert {:error, @invalid_one_time_passord_response, %Tesla.Env{status: 400}} =
               Login.login_one_time_password(client, "123")
    end

    test "valid one_time_password", %{client: client} do
      {:ok, %{"changePasswordId" => change_password_id}, %Tesla.Env{status: 200}} =
        Users.forgot_password(client, @user[:username])

      password_data = %{password: "updated_password"}

      {:ok, %{"oneTimePassword" => one_time_password}, %Tesla.Env{status: 200}} =
        Users.change_password(client, change_password_id, password_data)

      assert {:ok, %{"token" => _, "refreshToken" => _}, %Tesla.Env{status: 200}} =
               Login.login_one_time_password(client, one_time_password)
    end
  end

  describe "update_login_instant/2" do
    test "can record user login manually", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id
               )
    end
  end

  describe "update_login_instant/3" do
    test "can record user login manually", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id,
                 @application_id
               )
    end
  end

  describe "update_login_instant/4" do
    test "can record user login manually", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id,
                 @application_id,
                 @ip_address
               )
    end

    test "can handle nil application_id", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id,
                 nil,
                 @ip_address
               )
    end
  end

  describe "search/2" do
    test "can search logins", %{client: client} do
      assert {:ok, %{"logins" => [_]}, %Tesla.Env{status: 200}} =
               Login.search(
                 client,
                 %{
                   userId: @user_id
                 }
               )
    end
  end

  describe "logout_user/3" do
    test "can logout user", %{client: client} do
      {:ok, %{"refreshToken" => refresh_token}, _} =
        Login.login_user(client, @user[:email], @user[:password])

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Login.logout_user(
                 client,
                 refresh_token,
                 true
               )
    end
  end
end
