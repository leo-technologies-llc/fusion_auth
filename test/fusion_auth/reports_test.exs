defmodule FusionAuth.ReportsTest do
  use FusionAuth.DataCase

  alias FusionAuth.Reports
  alias FusionAuth.TestUtilities
  alias FusionAuth.Registrations
  alias FusionAuth.Login

  @user %{username: "johndoe", password: "password", email: "email@email.com"}

  @invalid_api_key "51054144-e0b2-49a7-a92c-cce51cfc7038"

  @start_date 0
  @end_date :os.system_time(:milli_seconds) + 100_000_000_000
  @application_id "473f2618-c526-45ba-9c35-8739ba6cfc2e"

  setup do
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant_with_email_template(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)
    create_records(client_with_tenant)

    {:ok, %{client: client_with_tenant, base_url: base_url}}
  end

  describe "Generate the daily active users report" do
    test "get_daily_active_users_report/4 send a 200 along with a JSON body on successful request",
         %{client: client} do
      parameters = [applicationId: @application_id]

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Reports.get_daily_active_users_report(
                 client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end

    test "get_daily_active_users_report/4 send a 401 along with an empty JSON body when API key is not valid",
         %{base_url: base_url} do
      invalid_client = FusionAuth.client(base_url, @invalid_api_key, "")
      parameters = [applicationId: @application_id]

      assert {:error, "", %Tesla.Env{status: 401}} =
               Reports.get_daily_active_users_report(
                 invalid_client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end
  end

  describe "Generate Login Report" do
    test "get_login_report/4 send a 200 along with a JSON body on successful request", %{
      client: client
    } do
      parameters = [
        applicationId: @application_id
      ]

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Reports.get_login_report(
                 client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end

    test "get_login_report/4 send a 401 along with an empty JSON body when API key is not valid",
         %{base_url: base_url} do
      invalid_client = FusionAuth.client(base_url, @invalid_api_key, "")

      parameters = [
        applicationId: @application_id
      ]

      assert {:error, "", %Tesla.Env{status: 401}} =
               Reports.get_login_report(
                 invalid_client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end
  end

  describe "Generate Monthly Active Users Report" do
    test "get_monthly_active_users_report/4 send a 200 along with a JSON body on successful request",
         %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Reports.get_monthly_active_users_report(
                 client,
                 @start_date,
                 @end_date,
                 []
               )
    end

    test "get_monthly_active_users_report/4 send a 401 along with an empty JSON body when API key is not valid",
         %{base_url: base_url} do
      invalid_client = FusionAuth.client(base_url, @invalid_api_key, "")
      parameters = [applicationId: @application_id]

      assert {:error, "", %Tesla.Env{status: 401}} =
               Reports.get_monthly_active_users_report(
                 invalid_client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end
  end

  describe "Generate Registration Report" do
    test "get_registration_report/4 send a 200 along with a JSON body on successful request", %{
      client: client
    } do
      parameters = [applicationId: @application_id]

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Reports.get_registration_report(
                 client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end

    test "get_registration_report/4 send a 401 along with an empty JSON body when API key is not valid",
         %{base_url: base_url} do
      invalid_client = FusionAuth.client(base_url, @invalid_api_key, "")
      parameters = [applicationId: @application_id]

      assert {:error, "", %Tesla.Env{status: 401}} =
               Reports.get_registration_report(
                 invalid_client,
                 @start_date,
                 @end_date,
                 parameters
               )
    end
  end

  describe "Generate Totals Report" do
    test "get_totals_report/4 send a 200 along with a JSON body on successful request", %{
      client: client
    } do
      assert {:ok, %{}, %Tesla.Env{status: 200}} = Reports.get_totals_report(client)
    end

    test "get_totals_report/4 send a 401 along with an empty JSON body when API key is not valid",
         %{base_url: base_url} do
      invalid_client = FusionAuth.client(base_url, "", "", [:disable_authorization_headers])

      assert {:error, "", %Tesla.Env{status: 401}} = Reports.get_totals_report(invalid_client)
    end
  end

  defp create_records(client) do
    TestUtilities.create_application_with_id(client, @application_id)

    data = %{
      registration: %{
        applicationId: @application_id,
        data: %{displayName: "John"}
      },
      user: @user
    }

    Registrations.create_user_and_registration(client, data)

    Enum.each(0..5, fn _ ->
      Login.login_user(client, @application_id, @user[:username], @user[:password])
    end)
  end
end
