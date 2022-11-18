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
    - refresh_window :: integer() // default 5
    - generate_refresh_token :: boolean() // default :true
  """
  require Logger

  alias FusionAuth.Utils
  alias JOSE.JWK
  alias JOSE.JWT

  @default_options [
    client: nil,
    conn_key: :user,
    atomize_keys: true,
    case_format: :underscore,
    refresh_window: 5,
    generate_refresh_token: true
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
    generate_refresh_token = options[:generate_refresh_token]

    with {:ok, token} <- Utils.fetch_token(conn),
         {:ok, claims} <- verify_signature(token),
         {:ok, diff} <- verify_exp(claims["exp"], generate_refresh_token) do
      conn =
        with true <- needs_refresh?(diff, generate_refresh_token, options[:refresh_window]),
             {_, refresh} <- Utils.fetch_refresh(conn),
             {:ok, %{"token" => new_token}, _} <-
               FusionAuth.JWT.refresh_jwt(client, refresh, token) do
          Plug.Conn.put_resp_header(
            conn,
            Application.get_env(:fusion_auth, :token_header_key),
            new_token
          )
        else
          {:error, body, env} ->
            Logger.warn("""
            FusionAuth refresh token request resulted in an error.
            Env: #{inspect(env)}
            Body: #{body}}
            """)

            if diff <= 0 do
              conn
              |> Plug.Conn.halt()
              |> Plug.Conn.send_resp(401, "Unauthorized")
            else
              conn
            end

          _ ->
            conn
        end

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

  defp needs_refresh?(diff, true, refresh_window) when diff <= refresh_window * 60,
    do: true

  defp needs_refresh?(_, _, _), do: false

  defp verify_signature(token) do
    key = Application.get_env(:fusion_auth, :jwt_signing_key) |> Base.encode64()
    jwk = JWK.from(%{"kty" => "oct", "k" => key})

    case JWT.verify_strict(jwk, ["HS256"], token) do
      {false, _, _} ->
        {:error, "couldn't verify signature"}

      {true, jwt, _} ->
        {_, jwt_map} = JWT.to_map(jwt)
        {:ok, jwt_map}

      error ->
        {:error, error}
    end
  end

  defp verify_exp(exp, generate_refresh_token) do
    expire_date = exp |> DateTime.from_unix!()
    now = DateTime.utc_now()
    diff = DateTime.diff(expire_date, now, :second)

    cond do
      diff <= 0 and !generate_refresh_token -> {:error, "expired token"}
      true -> {:ok, diff}
    end
  end
end
