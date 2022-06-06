defmodule FusionAuth.TwoFactor do
  @moduledoc """
  The `FusionAuth.TwoFactor` module provides access functions to the [Two Factor APIs](https://fusionauth.io/docs/v1/tech/apis/two-factor).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.
  """

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()

  @type user_id :: String.t()
  @type token :: String.t()
  @type code :: String.t()
  @type delivery :: String.t()
  @type secret :: String.t()
  @type mobile_phone :: String.t()
  @type two_factor_id :: String.t()
  @type email :: String.t()
  @type secret_base32_encoded :: String.t()
  @type method :: String.t()
  @type method_id :: String.t()
  @type application_id() :: String.t()
  @type login_id :: String.t()
  @type state :: map()
  @type trust_challenge :: String.t()

  @type mfa_data :: %{
          code: code(),
          method: method(),
          token: token(),
          email: email(),
          mobilePhone: mobile_phone(),
          secret: secret(),
          secretBase32Encoded: secret_base32_encoded()
        }
  @type start_mfa_data :: %{
          applicationId: application_id(),
          code: code(),
          loginId: login_id(),
          state: state(),
          trustChallenge: trust_challenge(),
          userId: user_id()
        }

  @type two_factor_user_id_data :: %{
          email: email(),
          method: method(),
          mobilePhone: mobile_phone(),
          userId: user_id()
        }
  @type two_factor_jwt_data :: %{
          email: email(),
          method: method(),
          mobilePhone: mobile_phone()
        }
  @two_factor_url "/api/user/two-factor"
  @two_factor_send_url "/api/two-factor/send"
  @two_factor_secret_url "/api/two-factor/secret"
  @two_factor_start_url "api/two-factor/start"
  @two_factor_recovery_code_url "/api/user/two-factor/recovery-code"

  @doc """
  Enable Two Factor Authentication by User Id

  This API is used to enable Two Factor authentication for a single User. To use this API the User must provide a valid Two Factor verification code.

  To enable using `TextMessage` delivery, you may use the [Two Factor Send API](https://fusionauth.io/docs/v1/tech/apis/two-factor#secret-a-two-factor-code) to deliver a code to the User, the User will then provide this code as input.

  ## Examples
      iex> client = FusionAuth.client()
      iex> token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.6hqLDc7-PxHpQRjsdDVt0NcDLcs6ZcoUy5hbwSzMcLM"
      iex> delivery = "TextMessage"
      iex> mobile_phone = "9516401023"
      iex> FusionAuth.TwoFactor.generate_secret_for_jwt(client, token)
      {
        :ok,
        %{
          "secret" => "SP2m6K2Dg/x2JN9DyQvZ",
          "secretBase32Encoded" => "JD62N2FNQOB7Y5RE35B4SC6Z"
        },
        %Tesla.Env{...}
      }
      iex> secret = "SP2m6K2Dg/x2JN9DyQvZ"
      iex> FusionAuth.TwoFactor.send_two_factor_code_to_mobile_phone(client, mobile_phone, secret)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
      iex> code = "819169"
      iex> FusionAuth.TwoFactor.enable_two_factor_by_user_id(client, user_id, code, delivery, secret)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
  For more information, visit the FusionAuth API Documentation for [Enable Two Factor](https://fusionauth.io/docs/v1/tech/apis/two-factor#enable-two-factor).
  """
  @spec enable_two_factor_by_user_id(client(), user_id(), mfa_data()) :: result()
  def enable_two_factor_by_user_id(client, user_id, mfa_data) do
    Tesla.post(client, @two_factor_url <> "/#{user_id}", mfa_data)
    |> FusionAuth.result()
  end

  @doc """
  Enable Two Factor Authentication by JWT

  ## Examples
      iex> client = FusionAuth.client()
      iex> token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.6hqLDc7-PxHpQRjsdDVt0NcDLcs6ZcoUy5hbwSzMcLM"
      iex> delivery = "TextMessage"
      iex> mobile_phone = "9516401023"
      iex> FusionAuth.TwoFactor.generate_secret_for_jwt(client, token)
      {
        :ok,
        %{
          "secret" => "S847HD/Gl5zcCf79iI3T",
          "secretBase32Encoded" => "JPHDWHB7Y2LZZXAJ736YRDOT"
        },
        %Tesla.Env{...}
      }
      iex> secret = "S847HD/Gl5zcCf79iI3T"
      iex> FusionAuth.TwoFactor.send_two_factor_code_to_mobile_phone(client, mobile_phone, secret)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
      iex> code = "059984"
      iex> FusionAuth.TwoFactor.enable_two_factor_by_jwt(client, token, code, delivery, secret)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
  For more information, visit the FusionAuth API Documentation for [Enable Two Factor](https://fusionauth.io/docs/v1/tech/apis/two-factor#enable-two-factor).
  """
  @spec enable_two_factor_by_jwt(client(), token(), mfa_data()) :: result()
  def enable_two_factor_by_jwt(client, token, mfa_data) do
    Tesla.post(
      client,
      @two_factor_url,
      mfa_data,
      headers: [{"Authorization", "Bearer " <> token}]
    )
    |> FusionAuth.result()
  end

  @doc """
  Disable Two Factor by User Id

  This API is used to disable Two Factor authentication for a single User. To use this API the User must provide a valid Two Factor verification code.

  If the User has configured `TextMessage` delivery, you may use the [Two Factor Send API](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-two-factor-code) to deliver a code to the User, the User will then provide this code as input.

  ## Examples
      iex> client = FusionAuth.client()
      iex> user_id = "fffc8648-bab2-4bdd-b2eb-a48e853d9217"
      iex> FusionAuth.TwoFactor.generate_secret(client)
      {
        :ok,
        %{
          "secret" => "EgLthMnIgHaQot7sgloI",
          "secretBase32Encoded" => "CIBO3BGJZCAHNEFC33WIEWQI"
        },
        %Tesla.Env{...}
      }
      iex> FusionAuth.TwoFactor.disable_two_factor_by_user_id(client, user_id, code)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
      iex> secret = "EgLthMnIgHaQot7sgloI"
      iex> FusionAuth.TwoFactor.send_two_factor_code_by_user_id(client, user_id, secret)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
      iex> code = "284703"
      iex> FusionAuth.TwoFactor.disable_two_factor_by_user_id(client, user_id, code)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
  For more information, visit the FusionAuth API Documentation for [Disable Two Factor](https://fusionauth.io/docs/v1/tech/apis/two-factor#disable-two-factor).
  """
  @spec disable_two_factor_by_user_id(client(), user_id(), code(), method_id()) :: result()
  def disable_two_factor_by_user_id(client, user_id, code, method_id) do
    Tesla.delete(
      client,
      @two_factor_url <> "/#{user_id}?code=#{code}&methodId=#{method_id}"
    )
    |> FusionAuth.result()
  end

  @doc """
  Disable Two Factor by JWT

  ## Examples
      iex> client = FusionAuth.client()
      iex> token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.6hqLDc7-PxHpQRjsdDVt0NcDLcs6ZcoUy5hbwSzMcLM"
      iex> FusionAuth.TwoFactor.disable_two_factor_by_jwt(client, token, code)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Disable Two Factor](https://fusionauth.io/docs/v1/tech/apis/two-factor#disable-two-factor).
  """
  @spec disable_two_factor_by_jwt(client(), token(), code(), method_id()) :: result()
  def disable_two_factor_by_jwt(client, token, code, method_id) do
    Tesla.delete(
      client,
      @two_factor_url <> "?code=#{code}&methodId=#{method_id}",
      headers: [{"Authorization", "Bearer " <> token}]
    )
    |> FusionAuth.result()
  end

  @doc """
  Sends a code when disabling the MFA method with the given `method_id` for a user with the given `user_id`

  For more information, visit the FusionAuth API Documentation for [Send a Multi-Factor Code When Disabling MFA](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-multi-factor-code-when-disabling-mfa).
  """
  @spec disable_two_factor_with_code_by_user_id(client(), method_id(), user_id()) :: result()
  def disable_two_factor_with_code_by_user_id(client, method_id, user_id) do
    Tesla.post(client, @two_factor_send_url, %{methodId: method_id, userId: user_id})
    |> FusionAuth.result()
  end

  @doc """
  Sends a code when disabling the MFA method with the given `method_id` for a user with the given JWT

  For more information, visit the FusionAuth API Documentation for [Send a Multi-Factor Code When Disabling MFA](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-multi-factor-code-when-disabling-mfa).
  """
  @spec disable_two_factor_with_code_by_jwt(client(), method_id(), token()) :: result()
  def disable_two_factor_with_code_by_jwt(client, method_id, token) do
    Tesla.post(client, @two_factor_send_url, %{methodId: method_id},
      headers: [{"Authorization", "Bearer " <> token}]
    )
    |> FusionAuth.result()
  end

  @doc """
  Starts an MFA request, typically only used for step up auth

  For more information, visit the FusionAuth API Documentation for [Start Multi-Factor](https://fusionauth.io/docs/v1/tech/apis/two-factor#start-multi-factor).
  """
  @spec start_mfa_auth(client(), start_mfa_data()) :: result()
  def start_mfa_auth(client, start_mfa_data) do
    Tesla.post(client, @two_factor_start_url, start_mfa_data)
    |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to an existing User by Id

  This API is used to send a Two Factor verification code to a User.

  This request is intended to be used to send a Two Factor code to enable Two Factor authentication for a user.

  ## Examples
      iex> client = FusionAuth.client()
      iex> user_id = "fffc8648-bab2-4bdd-b2eb-a48e853d9217"
      iex> FusionAuth.TwoFactor.send_two_factor_code_by_user_id(client, user_id)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Send a Two Factor Code](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-two-factor-code).
  """
  @spec send_two_factor_code_by_user_id(client(), two_factor_user_id_data()) :: result()
  def send_two_factor_code_by_user_id(client, two_factor_user_id_data) do
    Tesla.post(client, @two_factor_send_url, two_factor_user_id_data)
    |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to complete Two Factor Login

  Can be used to re-send a code to a user during login

  For more information, visit the FusionAuth API Documentation for [Send a Multi-Factor Code During Login or Step Up](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-multi-factor-code-during-login-or-step-up).
  """
  @spec send_two_factor_code_to_complete_login(client(), two_factor_id(), method_id()) :: result()
  def send_two_factor_code_to_complete_login(client, two_factor_id, method_id) do
    Tesla.post(client, @two_factor_send_url <> "/#{two_factor_id}", %{methodId: method_id})
    |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to an authenticated User using a JWT

  This API is used to send a Two Factor verification code to a User.

  This request is intended to be used to send a Two Factor code to enable Two Factor authentication for a user.
  ## Examples
      iex(137)> token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.6hqLDc7-PxHpQRjsdDVt0NcDLcs6ZcoUy5hbwSzMcLM"
      iex(138)> FusionAuth.TwoFactor.send_two_factor_code_by_jwt(client, token)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }
  For more information, visit the FusionAuth API Documentation for [Send a Two Factor Code](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-two-factor-code).
  """
  @spec send_two_factor_code_by_jwt(client(), token(), two_factor_jwt_data()) :: result()
  def send_two_factor_code_by_jwt(client, token, two_factor_jwt_data) do
    Tesla.post(
      client,
      @two_factor_send_url,
      two_factor_jwt_data,
      headers: [{"Authorization", "Bearer " <> token}]
    )
    |> FusionAuth.result()
  end

  @doc """
  Generate a Two Factor Secret

  This API is used to generate a new Two Factor secret for use when enabling Two Factor authentication for a User. This is provided as a helper to assist you in enabling Two Factor authentication.

  If this secret will be used with a QR code to allow the User to scan the value it will need utilize the Base32 encoded value returned in the response.

  ## Examples
      iex> client = FusionAuth.client()
      iex> FusionAuth.TwoFactor.generate_secret(client)
      {
        :ok,
        %{
          "secret" => "D90sYs5aPN51Z+ubdQt7",
          "secretBase32Encoded" => "B7OSYYWOLI6N45LH5ONXKC33"
        },
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Send a Two Factor Code](https://fusionauth.io/docs/v1/tech/apis/two-factor#generate-a-secret).
  """
  @spec generate_secret(client()) :: result()
  def generate_secret(client) do
    Tesla.get(client, @two_factor_secret_url)
    |> FusionAuth.result()
  end

  @doc """
  Generate a Two Factor Secret by JWT

  ## Examples
      iex> client = FusionAuth.client()
      iex> token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTE5OTY1NzAsImlhdCI6MTU5MTk5Mjk3MCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiYWRlbGFjcnV6QGNvZ2lsaXR5LmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhcHBsaWNhdGlvbklkIjoiZjdhNzJhZDEtZGU2YS00MTJmLWEzNzItZTY4OWEzYjdhZGNiIiwicm9sZXMiOltdfQ.CqKgxZvqCLPgdT8vSk_KvfNbISe-uIAfQJp0xKWbKno"
      iex> FusionAuth.TwoFactor.generate_secret_for_jwt(client, token)
      {
        :ok,
        %{
          "secret" => "ZlaRg5hfQ5/cF25tYHKU",
          "secretBase32Encoded" => "MZLJDA4YL5BZ7XAXNZWWA4UU"
        },
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Send a Two Factor Code](https://fusionauth.io/docs/v1/tech/apis/two-factor#generate-a-secret).
  """
  @spec generate_secret_for_jwt(client(), token()) :: result()
  def generate_secret_for_jwt(client, token) do
    Tesla.get(
      client,
      @two_factor_secret_url,
      headers: [{"Authorization", "Bearer " <> token}]
    )
    |> FusionAuth.result()
  end

  @doc """
  Generates recovery codes for a given user

  ## Examples
      FusionAuth.TwoFactor.generate_recovery_codes(client, user_id)
      {:ok,
      %{
        "recoveryCodes" => ["8WZDD-TYFPH", "QGGLS-N4428", "KTXHK-M9F9B",
          "C9LHS-VNT78", "M5NG2-YB9TY", "P3W2C-QDFGG", "CHGFK-3DVWG", "J8LGT-6BM3D",
          "STZ4M-CMGSS", "VR8N8-9GX6N"]
      },
      %Tesla.Env{...}

  """
  @spec generate_recovery_codes(client(), user_id()) :: result()
  def generate_recovery_codes(client, user_id) do
    Tesla.post(client, @two_factor_recovery_code_url <> "/#{user_id}", %{})
    |> FusionAuth.result()
  end

  @doc """
  Retrieves recovery codes for a given user

  ## Examples
      FusionAuth.TwoFactor.retrieve_recovery_codes(client, user_id)
      {:ok,
      %{
        "recoveryCodes" => ["8WZDD-TYFPH", "QGGLS-N4428", "KTXHK-M9F9B",
          "C9LHS-VNT78", "M5NG2-YB9TY", "P3W2C-QDFGG", "CHGFK-3DVWG", "J8LGT-6BM3D",
          "STZ4M-CMGSS", "VR8N8-9GX6N"]
      },
      %Tesla.Env{...}

  """
  @spec retrieve_recovery_codes(client(), user_id()) :: result()
  def retrieve_recovery_codes(client, user_id) do
    Tesla.get(client, @two_factor_recovery_code_url <> "/#{user_id}")
    |> FusionAuth.result()
  end
end
