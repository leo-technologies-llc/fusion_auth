defmodule FusionAuth.Plugs.AuthorizeJWT do
  import Plug.Conn

  def init(opts \\ []), do: opts

  def call(conn, _) do
    with {:ok, token} <- fetch_token(conn),
         {:ok, user} <- verify_token(token),
         true <- verify_application_group_role(user) do
      assign(conn, :user, user)
    else
      conn
      |> put_resp_content_type("application/json")
      |> put_status(401)
      |> send_resp()
      |> halt()
    end
  end

  defp verify_application_group_role(%{"jwt" => %{"roles" => roles}}) do
    case Application.get_env(:fusion_auth, :enable_application_group, false) do
      false -> true
      true -> Enum.member?(roles, application_group_role())
      value -> raise "Invalid value config value: enable_application_group: #{inspect(value)}"
    end
  end

  defp verify_token(token) do
    {:ok, %{}}
  end

  defp fetch_token(conn) do
    get_req_header(conn, authorization_key())
    |> fetch_token()
  end

  defp fetch_token(["JWT " <> token]), do: {:ok, token}
  defp fetch_token(["Bearer " <> token]), do: {:ok, token}
  defp fetch_token([token]) when is_binary(token), do: {:ok, token}
  defp fetch_token(_), do: {:error, :unauthorized}

  defp application_group_role(), do: Application.get_env(:fusion_auth, :application_group_role)

  defp authorization_key(),
    do:
      Application.get_env(
        :fusion_auth,
        :jwt_header_key,
        "authorization"
      )
end
