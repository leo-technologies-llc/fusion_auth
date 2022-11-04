defmodule FusionAuth.Plugs.RefreshJWT do
  @moduledoc """
  The `FusionAuth.Plugs.RefreshJWT` module provides functionality to return a new refresh token and JWT
  back to the client after the request is processed.

  ## Examples

  ```
    config/{env}.exs

    config :fusion_auth,
      token_header_key: "authorization",
      refresh_header_key: "refresh",
  ```

  ```
    lib/my_web_server/router.ex

    defmodule MyWebServer.Router do
      use MyWebServer, :router
      pipeline :protected do
        plug(FusionAuth.Plugs.RefreshJWT)
      end
    end
  ```

  ## Plug Options
    - client :: FusionAuth.client(String.t(), String.t(), String.t()) // default FusionAuth.client()
  """

  alias FusionAuth.Utils
  alias JOSE.JWK
  alias JOSE.JWT

  @default_check_period 5

  @spec init(keyword()) :: keyword()
  def init(opts \\ []), do: opts

  @spec call(%Plug.Conn{}, keyword()) :: %Plug.Conn{}
  def call(conn, opts \\ []) do
    client = opts[:client] || FusionAuth.client()

    Plug.Conn.register_before_send(conn, fn conn ->
      with {:ok, token} <- Utils.fetch_token(conn),
           true <- needs_refresh?(token),
           {:ok, refresh} <- Utils.fetch_refresh(conn),
           {:ok, %{"token" => new_token}, _} <-
             FusionAuth.JWT.refresh_jwt(client, refresh, token) do
        conn
        |> Plug.Conn.put_resp_header(
          Application.get_env(:fusion_auth, :token_header_key),
          new_token
        )
      else
        _ ->
          conn
      end
    end)
  end

  defp needs_refresh?(token) do
    IO.inspect("edaedea")

    case verify_token(token) do
      false ->
        false

      token_map ->
        IO.inspect("getting here")
        expired_date = token_map["exp"] |> DateTime.from_unix!()
        start_range = DateTime.add(expired_date, -1 * @default_check_period, :minute)
        now = DateTime.utc_now()
        start_range <= now and now <= expired_date
    end
  end

  defp verify_token(token) do
    key = Application.get_env(:fusion_auth, :jwt_signing_key) |> Base.encode64()
    jwk = JWK.from(%{"kty" => "oct", "k" => key})

    case JWT.verify_strict(jwk, ["HS256"], token) do
      {false, _, _} ->
        false

      {true, jwt, _} ->
        {_, jwt_map} = JWT.to_map(jwt)
        jwt_map
    end
  end
end
