defmodule FusionAuth.PasswordlessTest do
  use FusionAuth.DataCase

  alias FusionAuth.Passwordless
  alias FusionAuth.TestUtilities
  alias FusionAuth.Registrations

  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"

  @login_id "john@doe.com"
  @user %{username: "johndoe", password: "password", email: @login_id}

  setup do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    Application.put_env(:fusion_auth, :application_id, @application_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant_with_email_template(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)
    TestUtilities.create_application_with_id(client_with_tenant, @application_id)
    TestUtilities.enable_passwordless(client, @application_id)

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

  describe "start/3" do
    test "should get the passwordless login code", %{client: client} do
      assert {:ok, %{"code" => _}, %Tesla.Env{status: 200}} =
               Passwordless.start(client, @login_id, %{})
    end

    test "should return an error if no user with the login_id", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Passwordless.start(client, "invalid_user@test.com", %{})
    end
  end

  describe "start/4" do
    test "should get the passwordless login code", %{client: client} do
      assert {:ok, %{"code" => _}, %Tesla.Env{status: 200}} =
               Passwordless.start(client, @application_id, @login_id, %{})
    end

    test "should return an error if no user with the login_id", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Passwordless.start(client, @application_id, "invalid_user@test.com", %{})
    end
  end

  describe "login/2" do
    test "should login the user with the passwordless code", %{client: client} do
      {:ok, %{"code" => code}, %Tesla.Env{status: 200}} =
        Passwordless.start(client, @login_id, %{})

      assert {:ok,
              %{
                "token" => _,
                "refreshToken" => _,
                "user" => %{"id" => @user_id}
              },
              %Tesla.Env{status: 200}} =
               Passwordless.login(client, code)
    end

    test "should return an error if the code is invalid", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Passwordless.login(client, "invalid_code")
    end
  end

  describe "login/3" do
    test "should login the user with the passwordless code", %{client: client} do
      {:ok, %{"code" => code}, %Tesla.Env{status: 200}} =
        Passwordless.start(client, @application_id, @login_id, %{})

      assert {:ok,
              %{
                "token" => _,
                "refreshToken" => _,
                "user" => %{"id" => @user_id}
              },
              %Tesla.Env{status: 200}} =
               Passwordless.login(client, @application_id, code)
    end

    test "should return an error if the code is invalid", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Passwordless.login(client, @application_id, "invalid_code")
    end
  end
end
