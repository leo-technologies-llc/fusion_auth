defmodule FusionAuth.Plugs.AuthorizeJWT do
  @moduledoc """
  The `FusionAuth.Plugs.AuthorizeJWT` module provides authentication of JWT tokens on incoming requests.

  ## Examples

  ```
    config/{env}.exs

    config :fusion_auth,
      token_header_key: "authorization"
  ```

  ```
    lib/my_web_server/router.ex

    defmodule MyWebServer.Router do
      use MyWebServer, :router
      pipeline :protected do
        plug(FusionAuth.Plugs.AuthorizeJWT)
      end
    end
  ```

  ## Plug Options
    - client :: FusionAuth.client(String.t(), String.t(), String.t()) // default FusionAuth.client()
    - conn_key :: atom() // default :user
    - atomize_keys :: boolean() // default true
    - case_format :: :underscore | :camelcase  // default :underscore

  """

  alias FusionAuth.Utils

  @default_options [
    client: nil,
    conn_key: :user,
    atomize_keys: true,
    case_format: :underscore
  ]

  @formatter [
    underscore: &Recase.to_snake/1,
    camelcase: &Recase.to_camel/1
  ]

  @spec init(keyword()) :: keyword()
  def init(opts \\ []), do: opts

  @spec call(%Plug.Conn{}, keyword()) :: %Plug.Conn{}
  def call(conn, opts \\ []) do
    options = Keyword.merge(@default_options, opts)
    client = options[:client] || FusionAuth.client()

    with {:ok, token} <- Utils.fetch_token(conn),
         {:ok, claims} <- verify_token(client, token) do
      Plug.Conn.assign(
        conn,
        options[:conn_key],
        format(claims, options[:atomize_keys], options[:case_format])
      )
    else
      _ ->
        conn
        |> Plug.Conn.halt()
        |> Plug.Conn.send_resp(401, "Unauthorized")
    end
  end

  defp format(claims, false, key_format),
    do:
      claims
      |> Recase.Enumerable.convert_keys(@formatter[key_format])

  defp format(claims, true, key_format),
    do:
      claims
      |> Recase.Enumerable.atomize_keys(@formatter[key_format])

  defp verify_token(client, token) do
    case FusionAuth.JWT.validate_jwt(client, token) do
      {:ok, %{"jwt" => claims}, _} -> {:ok, claims}
      _ -> :error
    end
  end
end
