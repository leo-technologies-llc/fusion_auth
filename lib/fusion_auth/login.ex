defmodule FusionAuth.Login do
  @moduledoc """
  The `FusionAuth.Login` module provides access methods to the [FusionAuth Login API](https://fusionauth.io/docs/v1/tech/apis/login).

  If an Application ID is not specified no refresh token will return in the response when logging in a user.
  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.
  """

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()
  @type options ::
          map()
          | %{
              noJWT: boolean(),
              trustComputer: boolean(),
              twoFactorTrustId: String.t(),
              ipAddress: String.t(),
              code: String.t(),
              metaData: %{
                device: %{
                  lastAccessedAddress: String.t(),
                  description: String.t(),
                  name: String.t(),
                  type: String.t()
                }
              }
            }

  @type search_parameters ::
          map()
          | %{
              applicationId: String.t(),
              userId: String.t(),
              start: number(),
              end: number(),
              startRow: number(),
              numberOfResults: number(),
              retrieveTotal: boolean()
            }

  @login_url "/api/login"
  @logout_url "/api/logout"
  @two_factor_url "/api/two-factor/login"
  @login_search_url "/api/system/login-record/search"

  @doc """
  Login user with one time password.
  Default application_id will be applied if specified in Application config.

  ## Example

  ```
    iex> client = FusionAuth.client()
    iex> FusionAuth.Login.login_one_time_password(client, "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4")
    {
      :ok,
      %{
        "refreshToken" => "xesneAYTdwF42uWM0dHRLgHp0_f1DsHOiNMXHN-ZCHvtRYX-MgvJUg",
        "token" => "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTIxOTUsImlhdCI6MTU5MTY0ODU5NSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.cZI203pyGAej9DPCxIQ0URakZkgNHO0DCC270qbeR-W-QbMgKERdgNmoOtnimQTxfUAdaipbCH7VVorblvlWZlRlTHd6qCUX5x7A9J0ww1xQincCeOgX-54tAybVMUVgxYvmoyxkx2Pea4MuuJXc3ut43yFXK3MtmSO7HnE5eChHMCw8GNhq71IP3TuTsnkdUHgdvJDF9NalsuxWZ4Ua2sIkIWNVB-XpUXArQd02q6XHY9p8OKe8ordmA-Vpw6nFMnY-naAhWV6MshTDyRXtE-_s5sDiE5xHszuiO40DZVo8Cqmu81gM41jPO9OQbFqFbyQN-WCPBdq8AuN79HF_zQ",
        "user" => %{...}
      },
      %Tesla.Env{...}
    }
  ```

  For more information visit the FusionAuth API Documentation for [Authenticate a User with a One Time Password](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user-with-a-one-time-password)
  """
  @spec login_one_time_password(client(), String.t()) :: result()
  def login_one_time_password(client, one_time_password) do
    login_one_time_password(client, get_application_id(), one_time_password)
  end

  @doc """
  Login user with one time password and application_id.
  No default application_id will be applied.

  For more information visit the FusionAuth API Documentation for [Authenticate a User with a One Time Password](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user-with-a-one-time-password)
  """
  @spec login_one_time_password(client(), String.t(), String.t()) :: result()
  def login_one_time_password(client, application_id, one_time_password) do
    login_one_time_password(client, application_id, one_time_password, %{})
  end

  @doc """
  Login user with one time password, application_id, and options.
  No default application_id will be applied.

  For more information visit the FusionAuth API Documentation for [Authenticate a User with a One Time Password](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user-with-a-one-time-password)
  """
  @spec login_one_time_password(client(), String.t(), String.t(), options()) :: result()
  def login_one_time_password(client, application_id, one_time_password, options) do
    data = %{
      oneTimePassword: one_time_password,
      applicationId: application_id
    }

    execute_login(client, data, options)
  end

  @doc """
  Login user with login_id and password.
  Default application_id will be applied if specified in Application config.

  ## Example

  ```
    iex> client = FusionAuth.client()
    iex> FusionAuth.Login.login_user(client, "username", "password")
    {
      :ok,
      %{
        "refreshToken" => "xesneAYTdwF42uWM0dHRLgHp0_f1DsHOiNMXHN-ZCHvtRYX-MgvJUg",
        "token" => "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTIxOTUsImlhdCI6MTU5MTY0ODU5NSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.cZI203pyGAej9DPCxIQ0URakZkgNHO0DCC270qbeR-W-QbMgKERdgNmoOtnimQTxfUAdaipbCH7VVorblvlWZlRlTHd6qCUX5x7A9J0ww1xQincCeOgX-54tAybVMUVgxYvmoyxkx2Pea4MuuJXc3ut43yFXK3MtmSO7HnE5eChHMCw8GNhq71IP3TuTsnkdUHgdvJDF9NalsuxWZ4Ua2sIkIWNVB-XpUXArQd02q6XHY9p8OKe8ordmA-Vpw6nFMnY-naAhWV6MshTDyRXtE-_s5sDiE5xHszuiO40DZVo8Cqmu81gM41jPO9OQbFqFbyQN-WCPBdq8AuN79HF_zQ",
        "user" => %{...}
      },
      %Tesla.Env{...}
    }
  ```

  For more information visit the FusionAuth API Documentation for [Authenticate a User](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user)
  """
  @spec login_user(client(), String.t(), String.t()) :: result()
  def login_user(client, login_id, password) do
    login_user(client, login_id, password, %{})
  end

  @doc """
  Login user with login_id, password and additional options.
  Default application_id will be applied if specified in Application config.

  For more information visit the FusionAuth API Documentation for [Authenticate a User](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user)
  """
  @spec login_user(client(), String.t(), String.t(), options()) :: result()
  def login_user(client, login_id, password, options) when is_map(options) do
    login_user(
      client,
      get_application_id(),
      login_id,
      password,
      options
    )
  end

  @doc """
  Login user with login_id, password and application_id.
  No default application_id will be applied.

  For more information visit the FusionAuth API Documentation for [Authenticate a User](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user)
  """
  @spec login_user(client(), String.t(), String.t(), String.t()) :: result()
  def login_user(client, application_id, login_id, password) do
    login_user(
      client,
      application_id,
      login_id,
      password,
      %{}
    )
  end

  @doc """
  Login user with application_id, login_id, password and additional options.
  No default application_id will be applied.

  For more information visit the FusionAuth API Documentation for [Authenticate a User](https://fusionauth.io/docs/v1/tech/apis/login#authenticate-a-user)
  """
  @spec login_user(client(), String.t(), String.t(), String.t(), options()) :: result()
  def login_user(client, application_id, login_id, password, options) do
    data = %{
      applicationId: application_id,
      loginId: login_id,
      password: password
    }

    execute_login(client, data, options)
  end

  @doc """
  Login user with two factor authentication.
  Default application_id will be applied if specified in Application config.

    ## Example

  ```
    iex> client = FusionAuth.client()
    iex> FusionAuth.Login.two_factor_login(client, "12345", "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4")
    {
      :ok,
      %{
        "refreshToken" => "xesneAYTdwF42uWM0dHRLgHp0_f1DsHOiNMXHN-ZCHvtRYX-MgvJUg",
        "token" => "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTIxOTUsImlhdCI6MTU5MTY0ODU5NSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.cZI203pyGAej9DPCxIQ0URakZkgNHO0DCC270qbeR-W-QbMgKERdgNmoOtnimQTxfUAdaipbCH7VVorblvlWZlRlTHd6qCUX5x7A9J0ww1xQincCeOgX-54tAybVMUVgxYvmoyxkx2Pea4MuuJXc3ut43yFXK3MtmSO7HnE5eChHMCw8GNhq71IP3TuTsnkdUHgdvJDF9NalsuxWZ4Ua2sIkIWNVB-XpUXArQd02q6XHY9p8OKe8ordmA-Vpw6nFMnY-naAhWV6MshTDyRXtE-_s5sDiE5xHszuiO40DZVo8Cqmu81gM41jPO9OQbFqFbyQN-WCPBdq8AuN79HF_zQ",
        "user" => %{...}
      },
      %Tesla.Env{...}
    }
  ```

  For more information visit the FusionAuth API Documentation for [Complete Two Factor Authentication](https://fusionauth.io/docs/v1/tech/apis/login#complete-two-factor-authentication)
  """
  @spec two_factor_login(client(), String.t(), String.t()) :: result()
  def two_factor_login(client, code, two_factor_id) do
    two_factor_login(client, get_application_id(), code, two_factor_id)
  end

  @doc """
  Login user with two factor authentication for specified application.
  No application_id will be applied if specified in Application config.

  For more information visit the FusionAuth API Documentation for [Complete Two Factor Authentication](https://fusionauth.io/docs/v1/tech/apis/login#complete-two-factor-authentication)
  """
  @spec two_factor_login(client(), String.t(), String.t(), String.t()) :: result()
  def two_factor_login(client, application_id, code, two_factor_id) do
    two_factor_login(client, application_id, code, two_factor_id, %{})
  end

  @doc """
  Login user with two factor authentication for specified application and additional options.
  No application_id will be applied if specified in Application config.

  For more information visit the FusionAuth API Documentation for [Complete Two Factor Authentication](https://fusionauth.io/docs/v1/tech/apis/login#complete-two-factor-authentication)
  """
  @spec two_factor_login(client(), String.t(), String.t(), String.t(), options()) ::
          result()
  def two_factor_login(client, application_id, code, two_factor_id, options) do
    data = %{
      applicationId: application_id,
      twoFactorId: two_factor_id,
      code: code
    }

    Tesla.post(client, @two_factor_url, post_data(data, options))
    |> FusionAuth.result()
  end

  @doc """
  Record user login.
  Default application_id will be applied if specified in Application config.

  ## Example

  ```
    iex> client = FusionAuth.client()
    iex> FusionAuth.Login.update_login_instant(client, "84846873-89d2-44f8-91e9-dac80f420cb2")
    {:ok, "", %Tesla.Env{...}}
  ```

  For more information visit the FusionAuth API Documentation for [Update Login Instant](https://fusionauth.io/docs/v1/tech/apis/login#update-login-instant)
  """
  @spec update_login_instant(client(), String.t()) :: result()
  def update_login_instant(client, user_id) do
    update_login_instant(client, user_id, get_application_id())
  end

  @doc """
  Record user login with application_id.
  No application_id will be applied if specified in Application config.

  For more information visit the FusionAuth API Documentation for [Update Login Instant](https://fusionauth.io/docs/v1/tech/apis/login#update-login-instant)
  """
  @spec update_login_instant(client(), String.t(), String.t() | nil) :: result()
  def update_login_instant(client, user_id, application_id) do
    update_login_instant(client, user_id, application_id, nil)
  end

  @doc """
  Record user login with application_id and ip address.
  No application_id will be applied if specified in Application config.

  For more information visit the FusionAuth API Documentation for [Update Login Instant](https://fusionauth.io/docs/v1/tech/apis/login#update-login-instant)
  """
  @spec update_login_instant(client(), String.t(), String.t() | nil, String.t() | nil) :: result()
  def update_login_instant(client, user_id, application_id, ip_address) do
    path =
      case application_id do
        nil -> "/#{user_id}"
        value -> "/#{user_id}/#{value}"
      end

    url = Tesla.build_url(@login_url <> path, %{ipAddress: ip_address})

    Tesla.put(client, url, %{})
    |> FusionAuth.result()
  end

  @doc """
  Logout user and invalidate refresh token.

  ## Example

  ```
    iex> client = FusionAuth.client()
    iex> FusionAuth.Login.logout_user(client, "xesneAYTdwF42uWM0dHRLgHp0_f1DsHOiNMXHN-ZCHvtRYX-MgvJUg", false)
    {:ok, "", %Tesla.Env{...}}
  ```

  For more information visit the FusionAuth API Documentation for [Logout a User](https://fusionauth.io/docs/v1/tech/apis/login#logout-a-user)
  """
  @spec update_login_instant(client(), String.t(), boolean()) :: result()
  def logout_user(client, refresh_token, global \\ false) do
    url = Tesla.build_url(@logout_url, %{global: global, refreshToken: refresh_token})

    Tesla.post(client, url, %{})
    |> FusionAuth.result()
  end

  @doc """
  Search user login.

  ## Example

  ```
    iex> client = FusionAuth.client()
    iex> FusionAuth.Login.search(client, %{userId: "d7be5e1e-0020-4f6f-a9dc-0f9230650042"})
    {
      :ok,
      %{
        "logins" => [
          %{
            "applicationId" => "2edd54c6-695d-409e-b8af-2d3ebf73711a",
            "applicationName" => "applicationName",
            "loginId" => "loginId",
            "instant" => 1562608320303,
            "ipAddress" => "0.0.0.0",
            "userId" => "d7be5e1e-0020-4f6f-a9dc-0f9230650042"
          },
          ...
        ]
      },
      %Tesla.Env{...}}
  ```

  For more information visit the FusionAuth API Documentation for [Search Login Records](https://fusionauth.io/docs/v1/tech/apis/login#search-login-records)
  """
  @spec search(client(), search_parameters()) :: result()
  def search(client, search_parameters \\ %{}) do
    url = Tesla.build_url(@login_search_url, search_parameters)

    Tesla.get(client, url)
    |> FusionAuth.result()
  end

  @doc false
  defp execute_login(client, data, options) do
    Tesla.post(client, @login_url, post_data(data, options))
    |> FusionAuth.result()
  end

  @doc false
  defp post_data(data, options) do
    default_options = %{noJWT: !Application.get_env(:fusion_auth, :enable_jwt, true)}

    parsed_options =
      Map.take(options, [
        :ipAddress,
        :metaData,
        :twoFactorTrustId,
        :noJWT,
        :code,
        :trustComputer
      ])

    merged_options = Map.merge(default_options, parsed_options)
    Map.merge(data, merged_options)
  end

  @doc false
  defp get_application_id() do
    Application.get_env(:fusion_auth, :application_id, nil)
  end
end
