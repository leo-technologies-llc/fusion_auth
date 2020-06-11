defmodule FusionAuth.Utils do
  @moduledoc """
  The `FusionAuth.Utils` module provides utility functions shared across the package modules.
  """

  @doc """
  Retrieve authorization token
  """
  def fetch_token(conn),
    do: get_token(conn, Application.get_env(:fusion_auth, :token_header_key))

  @doc """
  Retrieve refresh token
  """
  def fetch_refresh(conn),
    do: get_token(conn, Application.get_env(:fusion_auth, :refresh_header_key))

  @doc """
  Builds query parameters based on the keys and values passed in the parameters keyword list.
  """
  def build_query_parameters(parameters) do
    case Keyword.keyword?(parameters) do
      true ->
        Enum.reduce(parameters, "", fn {key, value}, acc ->
          build_query_parameter(acc, key, value)
        end)

      false ->
        raise ArgumentError,
              "A keyword list must be passed to the build_query_parameters/1 function."
    end
  end

  defp build_query_parameter(acc, _, nil), do: acc

  defp build_query_parameter("", key, value) when is_binary(value),
    do: "?#{key}=#{URI.encode(value)}"

  defp build_query_parameter(acc, key, value) when is_binary(value),
    do: "#{acc}&#{key}=#{URI.encode(value)}"

  defp build_query_parameter("", key, value), do: "?#{key}=#{value}"
  defp build_query_parameter(acc, key, value), do: "#{acc}&#{key}=#{value}"

  defp get_token(conn, key) do
    Plug.Conn.get_req_header(conn, key)
    |> parse_token()
  end

  defp parse_token(["JWT " <> token]), do: {:ok, token}
  defp parse_token(["Bearer " <> token]), do: {:ok, token}
  defp parse_token([""]), do: {:error, :unauthorized}
  defp parse_token([nil]), do: {:error, :unauthorized}
  defp parse_token([token]) when is_binary(token), do: {:ok, token}
  defp parse_token(_), do: {:error, :unauthorized}
end
