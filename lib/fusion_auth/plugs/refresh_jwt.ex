defmodule FusionAuth.Plugs.RefreshJWT do
  @moduledoc """
  The `FusionAuth.Plugs.RefreshJWT`

  ##Examples

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

  import Plug.Conn

  @spec init(keyword()) :: keyword()
  def init(opts \\ []), do: opts

  @spec call(%Plug.Conn{}, keyword()) :: %Plug.Conn{}
  def call(conn, opts \\ []) do
    client = opts[:client] || FusionAuth.client()
  end
end
