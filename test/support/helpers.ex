defmodule FusionAuth.TestSupport.Helpers do
  @moduledoc false
  import ExUnit.Assertions
  import Tesla.Mock

  @base_url "http://localhost:9011"

  def mock_request(opts), do: mock_request(@base_url, opts)

  def mock_request(base_url, opts, callback \\ nil) do
    status = Keyword.get(opts, :status)
    path = Keyword.get(opts, :path)
    method = Keyword.get(opts, :method)
    query_parameters = Keyword.get(opts, :query_parameters, [])
    response = Keyword.get(opts, :response, %{})
    body = Keyword.get(opts, :body)

    mock(fn
      %{method: method, url: build_url(path, query_parameters)} ->
        {response, %Tesla.Env{status: status, body: body}}
    end)

    if callback do
      callback.()
    end
  end

  defp build_url([]), do: path
  defp build_url(query_parameters) do

  end
end
