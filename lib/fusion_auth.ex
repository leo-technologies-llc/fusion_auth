defmodule FusionAuth do
  @moduledoc """
  This library provides an Elixir API for accessing the [FusionAuth Developer APIs](https://fusionauth.io/docs/v1/tech/apis/).

  Currently implemented are:
  * [Users API](https://fusionauth.io/docs/v1/tech/apis/users)

  The API access uses the [Tesla](https://github.com/teamon/tesla) library and
  relies on the caller passing in a FusionAuth base URL, API Key and Tenant ID to create a
  client. The client is then passed into all API calls.

  The API returns a 3 element tuple. If the API HTTP status code is less
  the 300 (ie. suceeded) it returns `:ok`, the HTTP body as a map and the full
  Tesla Env if you need to access more data about the return. If the API HTTP
  status code is greater than 300. it returns `:error`, the HTTP body and the
  Telsa Env. If the API doesn't return at all it should return `:error`, a blank
  map and the error from Tesla.

  ## Installation

  If [available in Hex](https://hex.pm/docs/publish), the package can be installed
  by adding `fusion_auth` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:fusion_auth, "~> 0.1.0"}
    ]
  end
  ```

  Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
  and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
  be found at [https://hexdocs.pm/fusion_auth](https://hexdocs.pm/fusion_auth).
  """
  @type client() :: Tesla.Client.t()
  @type result() :: {:ok, map() | String.t(), Tesla.Env.t()} | {:error, map(), any}
  @type search_criteria() :: %{
          ids: list() | nil,
          query: String.t() | nil,
          query_string: String.t() | nil,
          number_of_results: integer() | nil,
          sort_fields: list(sort_field()) | nil,
          start_row: integer() | nil
        }
  @type sort_field() :: %{
          missing: String.t() | nil,
          name: String.t(),
          order: String.t() | nil
        }

  @spec client() :: client()
  def client(),
    do:
      client(
        Application.get_env(:fusion_auth, :api_url),
        Application.get_env(:fusion_auth, :api_key),
        Application.get_env(:fusion_auth, :tenant_id)
      )

  @spec client(String.t(), String.t(), String.t()) :: client()
  def client(base_url, api_key, tenant_id) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"Authorization", api_key},
         {"X-FusionAuth-TenantId", tenant_id}
       ]}
    ]

    Tesla.client(middleware, adapter())
  end

  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status < 300 do
    {:ok, body, env}
  end

  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status >= 300 do
    {:error, body, env}
  end

  @spec result({:error, any}) :: result()
  def result({:error, any}), do: {:error, %{}, any}

  @doc false
  def adapter do
    case Application.get_env(:fusion_auth, :tesla) do
      nil -> {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}
      tesla -> tesla[:adapter]
    end
  end
end
