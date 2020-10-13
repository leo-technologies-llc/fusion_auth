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

  @two_factor_url "/api/user/two-factor"
  @two_factor_send_url "/api/two-factor/send"
  @two_factor_secret_url "/api/two-factor/secret"

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
  @spec enable_two_factor_by_user_id(client(), user_id(), code(), delivery(), secret()) :: result()
  def enable_two_factor_by_user_id(client, user_id, code, delivery, secret) do
    data = %{
      code: code,
      delivery: delivery,
      secret: secret
    }
    Tesla.post(client, @two_factor_url <> "/#{user_id}", data)
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
  @spec enable_two_factor_by_jwt(client(), token(), code(), delivery(), secret()) :: result()
  def enable_two_factor_by_jwt(client, token, code, delivery, secret) do
    data = %{
      code: code,
      delivery: delivery,
      secret: secret
    }
    Tesla.post(
      client,
      @two_factor_url,
      data,
      headers: [{"Authorization", "Bearer " <> token}]
    ) |> FusionAuth.result()
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
  @spec disable_two_factor_by_user_id(client(), user_id(), code()) :: result()
  def disable_two_factor_by_user_id(client, user_id, code) do
    Tesla.delete(
      client,
      @two_factor_url <> "/#{user_id}?code=#{code}"
    ) |> FusionAuth.result()
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
  @spec disable_two_factor_by_jwt(client(), token(), code()) :: result()
  def disable_two_factor_by_jwt(client, token, code) do
    Tesla.delete(
      client,
      @two_factor_url <> "?code=#{code}",
      headers: [{"Authorization", "Bearer " <> token}]
    ) |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to an existing User by Id

  This API is used to send a Two Factor verification code to a User. This may be useful during Two Factor authentication if the initial code is no longer valid. It may be also used to send a code to a User to assist in enabling or disabling Two Factor authentication.

  To send a code to a User that already has Two Factor enabled, it is not required they have `TextMessage` set as their preferred delivery. As long as the User has a mobile phone defined you may send the User a code.

  This API requires that the [Twilio](https://fusionauth.io/docs/v1/tech/integrations/twilio) integration is enabled and configured properly.

  This request is intended to be used to send a Two Factor code to a User that already has enabled Two Factor authentication to assist in disabling Two Factor authentication. The User must already have Two Factor enabled and have a valid mobile phone for this to succeed.

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
  @spec send_two_factor_code_by_user_id(client(), user_id()) :: result()
  def send_two_factor_code_by_user_id(client, user_id) do
    data = %{userId: user_id}
    Tesla.post(client, @two_factor_send_url, data)
    |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to a mobile phone

  This request is intended to be used to send a Two Factor code to a User to assist in enabling Two Factor authentication

  ## Examples
      iex> secret = "D90sYs5aPN51Z+ubdQt7"
      iex> mobile_phone= "2015970074"
      iex> FusionAuth.TwoFactor.send_two_factor_code_to_mobile_phone(client, mobile_phone, secret)
      {
        :ok,
        "",
        %Tesla.Env{...}
      }

  For more information, visit the FusionAuth API Documentation for [Send a Two Factor Code](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-two-factor-code).
  """
  @spec send_two_factor_code_to_mobile_phone(client(), mobile_phone(), secret()) :: result()
  def send_two_factor_code_to_mobile_phone(client, mobile_phone, secret) do
    data = %{mobilePhone: mobile_phone, secret: secret}
    Tesla.post(client, @two_factor_send_url, data)
    |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to complete Two Factor Login

  This request is intended to send additional messages to the User’s mobile phone during login.

  For more information, visit the FusionAuth API Documentation for [Send a Two Factor Code](https://fusionauth.io/docs/v1/tech/apis/two-factor#send-a-two-factor-code).
  """
  @spec send_two_factor_code_to_complete_login(client(), two_factor_id()) :: result()
  def send_two_factor_code_to_complete_login(client, two_factor_id) do
    Tesla.post(client, @two_factor_send_url <> "/#{two_factor_id}", %{})
    |> FusionAuth.result()
  end

  @doc """
  Send a Two Factor code to an authenticated User using a JWT

  This request is intended to be used to send a Two Factor code to a User that already has enabled Two Factor authentication to assist in disabling Two Factor authentication. When using JWT authentication the User’s Id is retrieved from the JWT. The User must already have Two Factor enabled and have a valid mobile phone for this to succeed.

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
  @spec send_two_factor_code_by_jwt(client(), token()) :: result()
  def send_two_factor_code_by_jwt(client, token) do
    Tesla.post(
      client,
      @two_factor_send_url,
      %{},
      headers: [{"Authorization", "Bearer " <> token}]
    ) |> FusionAuth.result()
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
    ) |> FusionAuth.result()
  end
end
