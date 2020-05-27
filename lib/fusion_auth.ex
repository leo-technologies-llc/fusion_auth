defmodule FusionAuth do
  @moduledoc """
  This library provides an Elixir API for accessing the [FusionAuth Developer APIs](https://fusionauth.io/docs/v1/tech/apis/).

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

  # TODO: Local configs. Remove after testing.
  @base_url "http://10.1.101.112:9011"
  @api_key "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
  @tenant_id "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"

  # TODO: Remove after testing.
  def client() do
    client(@base_url, @api_key, @tenant_id)
  end

  @spec client(String.t(), String.t(), String.t()) :: client()
  def client(base_url, api_key, tenant_id) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [
        {"Authorization", api_key},
        {"X-FusionAuth-TenantId", tenant_id}
      ]}
    ]

    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end

  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status < 300 do
    {:ok, VerusCommon.Utilities.CaseFormatter.snake_case_map(body), env}
  end

  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status >= 300 do
    {:error, VerusCommon.Utilities.CaseFormatter.snake_case_map(body), env}
  end

  @spec result({:error, any}) :: result()
  def result({:error, any}), do: {:error, %{}, any}
end
