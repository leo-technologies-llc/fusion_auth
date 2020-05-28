defmodule FusionAuth.Utils do
  @moduledoc """
  The `FusionAuth.Utils` module provides utility functions shared across the package modules.
  """

  @doc """
  Builds query parameters based on the keys and values passed in the parameters keyword list.
  """
  def build_query_parameters(parameters) do
    Enum.reduce(parameters, "", fn {key, value}, acc ->
      build_query_parameter(acc, key, value)
    end)
  end

  defp build_query_parameter(acc, _, nil), do: acc
  defp build_query_parameter("", key, value), do: "?#{key}=#{value}"
  defp build_query_parameter(acc, key, value), do: "#{acc}&#{key}=#{value}"
end
