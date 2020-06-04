defmodule FusionAuth do
  @moduledoc """
  The `FusionAuth` module provides functions for building a dynamic HTTP client as well as standardizing the responses returned from the FusionAuth API.

  ## Examples

    iex> FusionAuth.client("http://localhost:9011", "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8", "6b40f9d6-cfd8-4312-bff8-b082ad45e93c")
    %Tesla.Client{
      adapter: {Tesla.Adapter.Hackney, :call, [[recv_timeout: 30000]]},
      fun: nil,
      post: [],
      pre: [
        {Tesla.Middleware.BaseUrl, :call, ["http://localhost:9011"]},
        {Tesla.Middleware.JSON, :call, [[]]},
        {Tesla.Middleware.Headers, :call,
        [
          [
            {"Authorization", "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"},
            {"X-FusionAuth-TenantId", "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"}
          ]
        ]}
      ]
    }

  """
  @type client() :: Tesla.Client.t()
  @type result() :: {:ok, map() | String.t(), Tesla.Env.t()} | {:error, map(), any}

  @doc """
  Builds a dynamic client for executing HTTP requests to the FusionAuth API based on runtime arguments.
  """
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

  @doc """
  Standardizes the response to be returned from the FusionAuth API request.
  """
  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status < 300 do
    {:ok, body, env}
  end

  @doc """
  Standardizes the response to be returned from the FusionAuth API request.
  """
  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status >= 300 do
    {:error, body, env}
  end

  @doc """
  Standardizes the response to be returned from the FusionAuth API request.
  """
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
