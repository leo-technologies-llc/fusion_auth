defmodule FusionAuth.Users do
  @moduledoc """
  The `FusionAuth.Users` module provides access methods to the [FusionAuth Users API](https://fusionauth.io/docs/v1/tech/apis/users).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.

  ## Examples
      client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
      {:ok, result, _env} = FusionAuth.Users.get_user(client, "06da543e-df3e-4011-b122-a9ff04326599")

  TODO: Confirm if we want to leverage soft deletes or hard deletes.
  """

  @users_url "/api/user"
  @default_test_sort_fields [
    %{missing: "_first", name: "login", order: "asc"},
    %{name: "fullName", order: "asc"}
  ]
  @default_test_query "{\"bool\":{\"must\":[{\"nested\":{\"path\":\"registrations\",\"query\":{\"bool\":{\"must\":[{\"match\":{\"registrations.applicationId\":\"f8109431-14f2-4815-9987-77fdedeff802\"}}]}}}}]}}"

  @doc """
  Retrieve a user by the user’s ID.

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user
  """
  @spec get_user_by_id(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_user_by_id(client, user_id) do
    Tesla.get(client, @users_url <> "/#{user_id}") |> FusionAuth.result()
  end

  @doc """
  Retrieve a user by the user’s email.

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user
  """
  @spec get_user_by_email(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def get_user_by_email(client, email) do
    Tesla.get(client, @users_url <> "?email=#{email}") |> FusionAuth.result()
  end

  @doc """
  Retrieve a user by the user’s username.

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user
  """
  @spec get_user_by_username(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def get_user_by_username(client, username) do
    Tesla.get(client, @users_url <> "?username=#{username}") |> FusionAuth.result()
  end

  @doc """
  Create a new user.

  https://fusionauth.io/docs/v1/tech/apis/users#create-a-user
  """
  @spec create_user(FusionAuth.client(), map()) :: FusionAuth.request()
  def create_user(client, user) do
    Tesla.post(client, @users_url, %{user: user}) |> FusionAuth.result()
  end

  @doc """
  Update a user.

  https://fusionauth.io/docs/v1/tech/apis/users#update-a-user
  """
  @spec update_user(FusionAuth.client(), String.t(), map()) :: FusionAuth.request()
  def update_user(client, user_id, user) do
    Tesla.patch(client, @users_url <> "/#{user_id}", %{user: user}) |> FusionAuth.result()
  end

  @doc """
  Deactivate or delete a user by the user's ID.

  https://fusionauth.io/docs/v1/tech/apis/users#delete-a-user
  """
  @spec delete_user(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def delete_user(client, user_id) do
    Tesla.delete(client, @users_url <> "/#{user_id}?hardDelete=true") |> FusionAuth.result()
  end

  @doc """
  Bulk deactivate or delete users based on their user IDs.

  https://fusionauth.io/docs/v1/tech/apis/users#bulk-delete-users
  """
  @spec bulk_delete_users(FusionAuth.client(), list()) :: FusionAuth.request()
  def bulk_delete_users(client, user_ids) do
    Tesla.delete(
      client,
      @users_url <> "/bulk?#{format_bulk_user_ids(user_ids, "userId")}&hardDelete=true"
    )
    |> FusionAuth.result()
  end

  @doc """
  Reactivate an inactive user by the user's ID.

  https://fusionauth.io/docs/v1/tech/apis/users#reactivate-a-user
  """
  @spec reactivate_user(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def reactivate_user(client, user_id) do
    Tesla.put(client, @users_url <> "/#{user_id}?reactivate=true") |> FusionAuth.result()
  end

  @doc """
  Bulk import multiple users.

  https://fusionauth.io/docs/v1/tech/apis/users#import-users
  """
  @spec import_users(FusionAuth.client(), list()) :: FusionAuth.request()
  def import_users(client, users) do
    Tesla.post(client, @users_url <> "/import", %{users: users}) |> FusionAuth.result()
  end

  @doc """
  Search for users.

  https://fusionauth.io/docs/v1/tech/apis/users#search-for-users
  """
  @spec search_users(FusionAuth.client(), String.t(), list()) :: FusionAuth.request()
  def search_users(
        client,
        query \\ @default_test_query,
        sort_fields \\ @default_test_sort_fields
      ) do
    Tesla.post(client, @users_url <> "/search", %{
      search: %{query: query, sortFields: sort_fields}
    })
    |> FusionAuth.result()
  end

  defp format_bulk_user_ids(user_ids, key) do
    Enum.reduce(user_ids, "", fn user_id, acc ->
      "#{acc}&#{key}=#{user_id}"
    end)
    |> String.trim_leading("&")
  end
end
