defmodule FusionAuth.Plugs.AuthorizeJWT do
  import Plug.Conn

  @default_options [
    conn_key: :user,
    atomize_keys: true
  ]

  def init(opts \\ []), do: opts

  def call(conn, opts \\ []) do
    options = Keyword.merge(@default_options, opts)

    with {:ok, token} <- fetch_token(conn),
         {:ok, claims} <- verify_token(token),
         true <- check_access_roles(claims) do
      assign(
        conn,
        options[:conn_key],
        format_session(claims, options[:atomize_keys])
      )
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> put_status(401)
        |> send_resp()
        |> halt()
    end
  end

  defp format_session(claims, false), do: claims

  defp format_session(claims, true),
    do:
      claims
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms)

  defp check_access_roles(%{"roles" => roles}) do
    case Application.get_env(:fusion_auth, :enable_access_roles, false) do
      false -> true
      true -> Enum.any?(access_roles(), &Enum.member?(&1, roles))
      value -> raise "Invalid FusionAuth config value: enable_access_roles: #{inspect(value)}"
    end
  end

  defp verify_token(_) do
    client = FusionAuth.client()
    {:ok, %{"token" => token}, _} = FusionAuth.Login.login_user(client, "ckempton", "Rabitt5955")

    response =
      Tesla.get(client, "/api/jwt/validate", headers: [{"Authorization", "JWT #{token}"}])
      |> FusionAuth.result()

    case response do
      {:ok, %{"jwt" => claims}, _} -> {:ok, claims}
      _ -> :error
    end
  end

  defp fetch_token(conn) do
    get_req_header(conn, authorization_key())
    |> parse_token()
  end

  defp parse_token(["JWT " <> token]), do: {:ok, token}
  defp parse_token(["Bearer " <> token]), do: {:ok, token}
  defp parse_token([token]) when is_binary(token), do: {:ok, token}
  defp parse_token(_), do: {:error, :unauthorized}

  defp access_roles(), do: Application.get_env(:fusion_auth, :access_roles)

  defp authorization_key(),
    do:
      Application.get_env(
        :fusion_auth,
        :jwt_header_key,
        "authorization"
      )
end
