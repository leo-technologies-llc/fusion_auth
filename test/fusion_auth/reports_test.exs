defmodule FusionAuth.ReportsTest do
  use ExUnit.Case

  alias FusionAuth.Reports
  alias FusionAuth.TestSupport.Helpers

  @api_key "jnx6HeVRrLkulpwiUNh9s52qlJqp5dox77NcDVkf9YI"
  @invalid_api_key "invalid-key"
  @tenant_id "d577a020-30cb-85de-bf30-785cb65997d6"

  @start_date 1588316400000
  @end_date 1590908400000
  @application_id "473f2618-c526-45ba-9c35-8739ba6cfc2e"
  @login_id "fffc8648-bab2-4bdd-b2eb-a48e853d9217"

  @reports_daily_active_users_url "/api/report/daily-active-user"
  @reports_logins_url "/api/report/login"
  @reports_monthly_active_users_url "/api/report/monthly-active-user"
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
      parameters = [applicationId: @application_id]

      Helpers.mock_request(
        path: @reports_daily_active_users_url,
        method: :get,
        status: 200,
        response_body: %{},
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id
        ]
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
              Reports.get_daily_active_users_report(
                client,
                @start_date,
                @end_date,
                parameters
              )
    end

    test "get_daily_active_users_report/4 send a 401 along with an empty JSON body when API key is not valid" do
      invalid_client = FusionAuth.client(Helpers.base_url(), @invalid_api_key, @tenant_id)
      parameters = [applicationId: @application_id]

      Helpers.mock_request(
        path: @reports_daily_active_users_url,
        method: :get,
        status: 401,
        response_body: "",
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id
        ]
      )

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
    test "get_login_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
      parameters = [
        applicationId: @application_id,
        loginId: @login_id
      ]

      Helpers.mock_request(
        path: @reports_logins_url,
        method: :get,
        status: 200,
        response_body: %{},
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id,
          loginId: @login_id
        ]
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
              Reports.get_login_report(
                client,
                @start_date,
                @end_date,
                parameters
              )
    end

    test "get_login_report/4 send a 401 along with an empty JSON body when API key is not valid" do
      invalid_client = FusionAuth.client(Helpers.base_url(), @invalid_api_key, @tenant_id)
      parameters = [
        applicationId: @application_id,
        loginId: @login_id
      ]

      Helpers.mock_request(
        path: @reports_logins_url,
        method: :get,
        status: 401,
        response_body: "",
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id,
          loginId: @login_id
        ]
      )

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
    test "get_monthly_active_users_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
      parameters = [applicationId: @application_id]

      Helpers.mock_request(
        path: @reports_monthly_active_users_url,
        method: :get,
        status: 200,
        response_body: %{},
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id
        ]
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
              Reports.get_monthly_active_users_report(
                client,
                @start_date,
                @end_date,
                parameters
              )
    end

    test "get_monthly_active_users_report/4 send a 401 along with an empty JSON body when API key is not valid" do
      invalid_client = FusionAuth.client(Helpers.base_url(), @invalid_api_key, @tenant_id)
      parameters = [applicationId: @application_id]

      Helpers.mock_request(
        path: @reports_monthly_active_users_url,
        method: :get,
        status: 401,
        response_body: "",
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id
        ]
      )

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
    test "get_registration_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
      parameters = [applicationId: @application_id]

      Helpers.mock_request(
        path: @reports_registration_url,
        method: :get,
        status: 200,
        response_body: %{},
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id
        ]
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
              Reports.get_registration_report(
                client,
                @start_date,
                @end_date,
                parameters
              )
    end

    test "get_registration_report/4 send a 401 along with an empty JSON body when API key is not valid" do
      invalid_client = FusionAuth.client(Helpers.base_url(), @invalid_api_key, @tenant_id)
      parameters = [applicationId: @application_id]

      Helpers.mock_request(
        path: @reports_registration_url,
        method: :get,
        status: 401,
        response_body: "",
        query_parameters: [
          start: @start_date,
          end: @end_date,
          applicationId: @application_id
        ]
      )

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
    test "get_totals_report/4 send a 200 along with a JSON body on successful request", %{client: client} do
      Helpers.mock_request(
        path: @reports_totals_url,
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
              Reports.get_totals_report(client)
    end

    test "get_totals_report/4 send a 401 along with an empty JSON body when API key is not valid" do
      invalid_client = FusionAuth.client(Helpers.base_url(), @invalid_api_key, @tenant_id)
      Helpers.mock_request(
        path: @reports_totals_url,
        method: :get,
        status: 401,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 401}} =
              Reports.get_totals_report(invalid_client)
    end
  end
end
