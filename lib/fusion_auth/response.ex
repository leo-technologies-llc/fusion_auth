defmodule FusionAuth.Response do
  @moduledoc """
  The `FusionAuth.Response` module provides functions to format the response from FusionAuth.result.

  ## Example

  ```
    iex> FusionAuth.client()
         |> FusionAuth.Groups.get_groups()
         |> FusionAuth.Response.format("groups", &atomize_keys/1)

    {:ok, [%{id: "id", name: "name"}]
  ```
  """

  @type result :: FusionAuth.result()

  @spec format(result()) :: {:error, any()}
  def format({:error, error, _}), do: {:error, error}

  @spec format(result()) :: {:ok, map() | list()}
  def format({:ok, data, _}), do: {:ok, data}

  @spec format(result(), String.t()) :: {:error, any()}
  def format({:error, error, _}, _), do: {:error, error}

  @spec format(result(), String.t()) :: {:ok, map() | list()}
  def format({:ok, data, _}, payload_key), do: {:ok, Map.get(data, payload_key)}

  @spec format(result(), String.t(), fun()) :: {:error, any()}
  def format({:error, error, _}, _, _), do: {:error, error}

  @spec format(result(), String.t(), fun()) :: {:ok, map() | list()}
  def format({:ok, data, _}, payload_key, formatter) do
    payload = Map.get(data, payload_key, %{})
    {:ok, process(payload, formatter)}
  end

  defp process(data, formatter) when is_list(data),
    do: Enum.map(data, &process(&1, formatter))

  defp process(data, formatter) when is_map(data), do: formatter.(data)
end
