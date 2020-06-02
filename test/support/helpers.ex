defmodule FusionAuth.TestSupport.Helpers do
  @moduledoc false

  import Tesla.Mock

  alias FusionAuth.Utils

  @doc false
  def mock_request(opts), do: mock_request(base_url(), opts)

  @doc false
  def mock_request(base_url, opts, callback \\ nil) do
    status = Keyword.get(opts, :status)
    path = Keyword.get(opts, :path)
    method = Keyword.get(opts, :method)
    query_parameters = Keyword.get(opts, :query_parameters, [])
    response_body = Keyword.get(opts, :response_body)
    url = build_url(path, query_parameters)

    mock(fn
      %{method: method, url: url} ->
        {:ok, %Tesla.Env{status: status, body: response_body}}
    end)

    if callback do
      callback.()
    end
  end

  @doc false
  def base_url(), do: "http://localhost:9011"

  defp build_url(path, []), do: path
  defp build_url(path, query_parameters) do
    base_url() <> path <> Utils.build_query_parameters(query_parameters)
  end
end
