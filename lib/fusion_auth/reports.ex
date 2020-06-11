defmodule FusionAuth.Reports do
  @moduledoc """
  The `FusionAuth.Reports` module provides access functions to the [FusionAuth Reports API](https://fusionauth.io/docs/v1/tech/apis/reports).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.

  All but one function (totals) takes in required parameters `start_date` and `end_date`.
    - end_date :: integer() :: Required]\n
    The end of the query range. This is an [instant](https://fusionauth.io/docs/v1/tech/reference/data-types#instants) but it is truncated to days in the report timezone (which is set in the system settings).

    - start_date :: integer() :: Required]\n
    The start of the query range. This is an [instant](https://fusionauth.io/docs/v1/tech/reference/data-types#instants) but it is truncated to days in the report timezone (which is set in the system settings).
  """
  alias FusionAuth.Utils

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()

  @type start_date :: integer()
  @type end_date :: integer()
  @type application_id :: String.t()
  @type login_id :: String.t()
  @type user_id :: String.t()

  @reports_daily_active_users_url "/api/report/daily-active-users"
  @reports_logins_url "/api/report/login"
  @reports_monthly_active_users_url "/api/report/monthly-active-users"
  @reports_registration_url "/api/report/registration"
  @reports_totals_url "/api/report/totals"

  @doc """
  Generate the daily active users report

  This report retrieves the number of daily active users for a given application or across all applications. You must specify a date range for the report.

  ## Parameters
    - applicationid :: String.t() :: Optional\n
    A specific application to query for. If not provided a "Global" (across all applications) daily active users report will be returned.

  ## Examples
        iex>

  For more information, visit the FusionAuth API Documentation for [Generate Daily Active Users Report](https://fusionauth.io/docs/v1/tech/apis/reports#generate-daily-active-users-report).
  """
  @spec get_daily_active_users_report(client(), start_date(), end_date(), [key: application_id()] | []) :: result()
  def get_daily_active_users_report(client, start_date, end_date, parameters \\ []) do
    params = Keyword.merge([start: start_date, end: end_date], parameters)
    Tesla.get(
      client,
      @reports_daily_active_users_url <>
      Utils.build_query_parameters(params)
    ) |> FusionAuth.result()
  end

  @doc """
  Generate Login Report

  This report retrieves the number of logins for a given application or across all applications.
  You must specify a date range for the report. The report is always generated in hours.
  If you want to calculate daily logins, you’ll need to roll up the results in the response.

  ## Parameters
    - applicationid :: String.t() :: Optional\n
    A specific application to query for. If not provided a "Global" (across all applications) logins report will be returned.

    - loginId :: String.t() :: Optional\n
    When this parameter is provided it will reduce the scope of the report to a single user with the requested email or username specified by this parameter.\n
    This parameter is mutually exclusive with `userId`, if both are provided, the `loginId` will take precedence.\n

    - userId :: String.t() :: Optional\n
    When this parameter is provided it will reduce the scope of the report to a single user with the requested unique Id.\n
    This parameter is mutually exclusive with `loginId`, if both are provided, the `loginId` will take precedence.\n

  ## Examples
      iex> client = FusionAuth.client()
      iex> end_date = 1591830136785
      iex> start_date = 1588316400000
      iex> params = [applicationId: "473f2618-c526-45ba-9c35-8739ba6cfc2e"]
      iex> FusionAuth.Reports.get_login_report(client, start_date, end_date, params)
      {
        :ok,
        %{
          "hourlyCounts" => [
            %{"count" => 1, "interval" => 442050},
            %{"count" => 1, "interval" => 442174},
            ...
          ],
          "total" => 20
        },
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Generate Login Report](https://fusionauth.io/docs/v1/tech/apis/reports#generate-login-report).
  """
  @spec get_login_report(client(), start_date(), end_date(), [key: String.t()] | []) :: result()
  def get_login_report(client, start_date, end_date, parameters \\ []) do
    params = Keyword.merge([start: start_date, end: end_date], parameters)
    Tesla.get(
      client,
      @reports_logins_url <>
      Utils.build_query_parameters(params)
    ) |> FusionAuth.result()
  end

  @doc """
  Generate Monthly Active Users Report

  This report retrieves the number of monthly active users for a given application or across all applications.
  You must specify a date range for the report. The report is always generated using months as the interval.

  ## Parameters
    - applicationid :: String.t() :: Optional\n
    A specific application to query for. If not provided a "Global" (across all applications) monthly active users report will be returned.

  ## Examples
      iex>

  For more information, visit the FusionAuth API Documentation for [Generate Monthly Active Users Report](https://fusionauth.io/docs/v1/tech/apis/reports#generate-monthly-active-users-report).
  """
  @spec get_monthly_active_users_report(client(), start_date(), end_date(), [key: application_id()] | []) :: result()
  def get_monthly_active_users_report(client, start_date, end_date, parameters \\ []) do
    params = Keyword.merge([start: start_date, end: end_date], parameters)
    Tesla.get(
      client,
      @reports_monthly_active_users_url <>
      Utils.build_query_parameters(params)
    ) |> FusionAuth.result()
  end

  @doc """
  Generate Registration Report

  This report retrieves the number of registrations for a given application or across all applications.
  You must specify a date range for the report. The report is always generated in hours.
  Tf you want to calculate daily registrations, you’ll need to roll up the results in the response.

  ## Parameters
    - applicationid :: String.t() :: Optional\n
    A specific application to query for. If not provided a "Global" (across all applications) registrations report will be returned.

  ## Examples
      iex> client = FusionAuth.client()
      iex> end_date = 1591830136785
      iex> start_date = 1588316400000
      iex> params = [applicationId: "473f2618-c526-45ba-9c35-8739ba6cfc2e"]
      iex> FusionAuth.Reports.get_registration_report(client, start_date, end_date, params)
      {
        :ok,
        %{
          "hourlyCounts" => [
            %{"count" => 1, "interval" => 442030},
            %{"count" => 1, "interval" => 442055},
            %{"count" => 1, "interval" => 442056},
            %{"count" => 0, "interval" => 442168}
          ],
          "total" => 3
        },
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Generate Registration Report](https://fusionauth.io/docs/v1/tech/apis/reports#generate-registration-report).
  """
  @spec get_registration_report(client(), start_date(), end_date(), [key: application_id()] | []) :: result()
  def get_registration_report(client, start_date, end_date, parameters \\ []) do
    params = Keyword.merge([start: start_date, end: end_date], parameters)
    Tesla.get(
      client,
      @reports_registration_url <>
      Utils.build_query_parameters(params)
    ) |> FusionAuth.result()
  end

  @doc """
  Generate Totals Report

  This report retrieves the number of registrations for a given application or across all applications.
  You must specify a date range for the report. The report is always generated in hours.
  Tf you want to calculate daily registrations, you’ll need to roll up the results in the response.

  ## Examples
      iex> FusionAuth.Reports.get_totals_report(client)
      {
        :ok,
        %{
          "applicationTotals" => %{
            "3c219e58-ed0e-4b18-ad48-f4f92793ae32" => %{
              "logins" => 15,
              "registrations" => 1,
              "totalRegistrations" => 1
            },
            "c4e82607-dd9f-412a-a033-c53b79820446" => %{
              "logins" => 0,
              "registrations" => 0,
              "totalRegistrations" => 0
            },
            "f7a72ad1-de6a-412f-a372-e689a3b7adcb" => %{
              "logins" => 5,
              "registrations" => 1,
              "totalRegistrations" => 1
            }
          },
          "globalRegistrations" => 1,
          "totalGlobalRegistrations" => 3
        },
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Generate Totals Report](https://fusionauth.io/docs/v1/tech/apis/reports#generate-totals-report).
  """
  @spec get_totals_report(client()) :: result()
  def get_totals_report(client) do
    Tesla.get(client, @reports_totals_url) |> FusionAuth.result()
  end
end
