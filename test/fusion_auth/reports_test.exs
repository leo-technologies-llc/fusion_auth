defmodule FusionAuth.ReportsTest do
  use ExUnit.Case

  alias FusionAuth.Reports
  alias FusionAuth.TestSupport.Helpers

  @application_id "473f2618-c526-45ba-9c35-8739ba6cfc2e"
  @start_date 1588316400000
  @end_date 1590908400000
  @login_id "example@gmail.com"
  @user_id "fffc8648-bab2-4bdd-b2eb-a48e853d9217"

  @reports_daily_active_users_url "/api/report/daily-active-users"
  @reports_logins_url "/api/report/login"
  @reports_monthly_active_users_url "/api/report/monthly-active-users"
  @reports_registration_url "/api/report/registration"
  @reports_totals_url "/api/report/totals"

  setup do
    application_id = Application.get_env(:fusion_auth, :application_id)
    client = FusionAuth.client(Helpers.base_url(), @api_key, @tenant_id)

    on_exit(fn ->
      Application.put_env(:fusion_auth, :application_id, application_id)
    end)

    Application.put_env(:fusion_auth, :application_id, @application_id)

    [client: client]
  end

  describe "Generate the daily active users report" do
    test "get_daily_active_users_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
    end
    test "get_daily_active_users_report/4 send a 400 along with an Errors JSON Object when the request was invalid and/or malformed", %{client: client} do
    end
    test "get_daily_active_users_report/4 send a 401 along with an empty JSON body when API key is not valid", %{client: client} do
    end
    test "get_daily_active_users_report/4 send a 404 along with an empty JSON body when object does not exist", %{client: client} do
    end
  end


  describe "Generate Login Report" do
    test "get_login_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
    end
    test "get_login_report/4 send a 400 along with an Errors JSON Object when the request was invalid and/or malformed", %{client: client} do
    end
    test "get_login_report/4 send a 401 along with an empty JSON body when API key is not valid", %{client: client} do
    end
    test "get_login_report/4 send a 404 along with an empty JSON body when object does not exist", %{client: client} do
    end
  end

  describe "Generate Monthly Active Users Report" do
    test "get_monthly_active_users_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
    end
    test "get_monthly_active_users_report/4 send a 400 along with an Errors JSON Object when the request was invalid and/or malformed", %{client: client} do
    end
    test "get_monthly_active_users_report/4 send a 401 along with an empty JSON body when API key is not valid", %{client: client} do
    end
    test "get_monthly_active_users_report/4 send a 404 along with an empty JSON body when object does not exist", %{client: client} do
    end
  end


  describe "Generate Registration Report" do
    test "get_registration_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
    end
    test "get_registration_report/4 send a 400 along with an Errors JSON Object when the request was invalid and/or malformed", %{client: client} do
    end
    test "get_registration_report/4 send a 401 along with an empty JSON body when API key is not valid", %{client: client} do
    end
    test "get_registration_report/4 send a 404 along with an empty JSON body when object does not exist", %{client: client} do
    end
  end


  describe "Generate Totals Report" do
    test "get_totals_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
    end
    test "get_totals_report/4 send a 400 along with an Errors JSON Object when the request was invalid and/or malformed", %{client: client} do
    end
    test "get_totals_report/4 send a 401 along with an empty JSON body when API key is not valid", %{client: client} do
    end
    test "get_totals_report/4 send a 404 along with an empty JSON body when object does not exist", %{client: client} do
    end
  end
end
