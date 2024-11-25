defmodule FusionAuth.Passwordless do
  @moduledoc """
  The `FusionAuth.Passwordless` module provides access functions to the [Passwordless APIs](https://fusionauth.io/docs/apis/passwordless).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.
  """

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()

  @passwordless_start_url "/api/passwordless/start"
  @passwordless_login_url "/api/passwordless/login"

  @doc """
  Starts a passwordless login for a user.

  ## Parameters
    * `client` - A Tesla client struct.
    * `login_id` - The loginId of the user.
    * `state` - A map of key-value pairs that will be returned in the response.

  ## Examples
    iex> client = FusionAuth.client()
    iex> FusionAuth.Passwordless.start(client, "john@doe.com", %{})
    {:ok, %{"code" => "123456"}}, %Tesla.Env{status: 200}}}
    {:error, "", %Tesla.Env{status: 400}}}
  """
  @spec start(client(), String.t(), map()) :: result()
  def start(client, login_id, state) do
    start(client, get_application_id(), login_id, state)
  end

  @doc """
  Starts a passwordless login for a user.

  ## Parameters
    * `client` - A Tesla client struct.
    * `application_id` - The applicationId of the application.
    * `login_id` - The loginId of the user.
    * `state` - A map of key-value pairs that will be returned in the response.

  ## Examples
    iex> client = FusionAuth.client()
    iex> FusionAuth.Passwordless.start(client, "application_id", "john@doe.com", %{})
    {:ok, %{"code" => "123456"}}, %Tesla.Env{status: 200}}}
    {:error, "", %Tesla.Env{status: 400}}}
  """
  @spec start(client(), String.t(), String.t(), map()) :: result()
  def start(client, application_id, login_id, state) do
    data = %{
      applicationId: application_id,
      loginId: login_id,
      state: state
    }

    Tesla.post(client, @passwordless_start_url, data)
    |> FusionAuth.result()
  end

  @doc """
  Logs in a user using a passwordless code.

  ## Parameters
    * `client` - A Tesla client struct.
    * `code` - The passwordless code.

  ## Examples
    iex> client = FusionAuth.client()
    iex> FusionAuth.Passwordless.login(client, "passwordless_code")
    {:ok, %{"token" => "123456", "refreshToken" => "123456", "user" => %{}}}, %Tesla.Env{status: 200}}}
    {:error, "", %Tesla.Env{status: 400}}}
  """
  @spec login(client(), String.t()) :: result()
  def login(client, code) do
    login(client, get_application_id(), code)
  end

  @doc """
  Logs in a user using a passwordless code.

  ## Parameters
    * `client` - A Tesla client struct.
    * `application_id` - The applicationId of the application.
    * `code` - The passwordless code.

  ## Examples
    iex> client = FusionAuth.client()
    iex> FusionAuth.Passwordless.login(client, "application_id", "passwordless_code")
    {:ok, %{"token" => "123456", "refreshToken" => "123456", "user" => %{}}}, %Tesla.Env{status: 200}}}
    {:error, "", %Tesla.Env{status: 400}}}
  """
  @spec login(client(), String.t(), String.t()) :: result()
  def login(client, application_id, code) do
    data = %{
      applicationId: application_id,
      code: code
    }

    Tesla.post(client, @passwordless_login_url, data)
    |> FusionAuth.result()
  end

  @doc false
  defp get_application_id() do
    Application.get_env(:fusion_auth, :application_id, nil)
  end
end
