defmodule FusionAuth.Users do
  @moduledoc """
  The `FusionAuth.Users` module provides access methods to the [FusionAuth Users API](https://fusionauth.io/docs/v1/tech/apis/users).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.

  ## Examples
      client = FusionAuth.client("https://dev-000000.okta.com", "thisismykeycreatedinokta")
      {:ok, result, _env} = FusionAuth.Users.list_users(client)
  """

  @users_url "/api/user"

  @doc """
  Fetch a user by the user’s id, username or email address. The id is specified on the URI and the username or email are
  specified as URL parameters.

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user
  """
  @spec get_user(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_user(client, user) do
    Tesla.get(client, @users_url <> "/#{user}") |> FusionAuth.result()
  end
end
