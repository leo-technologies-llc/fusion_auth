defmodule FusionAuth.Plugs.AuthorizeJWT do
  @moduledoc """
  The `FusionAuth.Plugs.AuthorizeJWT` module provides authentication of JWT tokens on incoming requests.
  Enabling access roles will can be utilized to ensure the user making the request has the proper roles. If
  the users roles dont match one of the specified roles in the config a 401 response will be sent. This option
  is useful when implementing Single Sign On (SSO) applications where groups/roles are used to segment what
  application a user has access to.

  ## Examples

  ```
    config/{env}.exs

    config :fusion_auth,
      token_header_key: "authorization",
      enable_access_roles: false,
      access_roles: ["superadmin", "admin", "user"]
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
         {:ok, claims} <- verify_token(client, token),
         true <- check_access_roles(claims) do
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

  defp case_keys(claims, :underscore),
    do: Recase.Enumerable.convert_keys(claims, &Recase.to_snake/1)

  defp case_keys(claims, :camelcase),
    do: Recase.Enumerable.convert_keys(claims, &Recase.to_camel/1)

  defp check_access_roles(%{"roles" => roles}) do
    case Application.get_env(:fusion_auth, :enable_access_roles, false) do
      false -> true
      true -> Enum.any?(access_roles(), &Enum.member?(roles, &1))
    end
  end

  defp verify_token(client, token) do
    case FusionAuth.JWT.validate_jwt(client, token) do
      {:ok, %{"jwt" => claims}, _} -> {:ok, claims}
      _ -> :error
    end
  end

  defp access_roles(), do: Application.get_env(:fusion_auth, :access_roles, [])
end
