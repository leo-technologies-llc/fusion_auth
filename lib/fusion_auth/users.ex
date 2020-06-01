defmodule FusionAuth.Users do
  @moduledoc """
  The `FusionAuth.Users` module provides access functions to the [FusionAuth Users API](https://fusionauth.io/docs/v1/tech/apis/users).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.

  ## Examples
      client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
      {:ok, result, _env} = FusionAuth.Users.get_user(client, "06da543e-df3e-4011-b122-a9ff04326599")

  """
  alias FusionAuth.Utils

  @users_url "/api/user"

  @doc """
  Get a user by the user’s ID.

  ## Examples

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.get_user_by_id(client, "06da543e-df3e-4011-b122-a9ff04326599")
    {
      :ok,
      %{
        "user" => %{
          "active" => true,
          "email" => "cogadmin@cogility.com",
          "firstName" => "Cogility",
          "fullName" => "Cogility Admin",
          "id" => "06da543e-df3e-4011-b122-a9ff04326599",
          "insertInstant" => 1590606624689,
          "lastLoginInstant" => 1590607603500,
          "lastName" => "Admin",
          "memberships" => [...],
          "mobilePhone" => "6092895176",
          "passwordChangeRequired" => false,
          "passwordLastUpdateInstant" => 1590606624715,
          "preferredLanguages" => ["en"],
          "registrations" => [...],
          "tenantId" => "6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
          "timezone" => "America/Los_Angeles",
          "twoFactorDelivery" => "None",
          "twoFactorEnabled" => false,
          "username" => "cogadmin",
          "usernameStatus" => "ACTIVE",
          "verified" => true
        }
      },
      %Tesla.Env{...}
    }

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.get_user_by_id(client, "bad-id")
    {:error, "", %Tesla.Env{...}}

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user
  """
  @spec get_user_by_id(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_user_by_id(client, user_id) do
    Tesla.get(client, @users_url <> "/#{user_id}") |> FusionAuth.result()
  end

  @doc """
  Get a user by the user’s email.

    ## Examples

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.get_user_by_email(client, "cogadmin@cogility.com")
    {
      :ok,
      %{
        "user" => %{
          "active" => true,
          "email" => "cogadmin@cogility.com",
          "firstName" => "Cogility",
          "fullName" => "Cogility Admin",
          "id" => "06da543e-df3e-4011-b122-a9ff04326599",
          "insertInstant" => 1590606624689,
          "lastLoginInstant" => 1590607603500,
          "lastName" => "Admin",
          "memberships" => [...],
          "mobilePhone" => "6092895176",
          "passwordChangeRequired" => false,
          "passwordLastUpdateInstant" => 1590606624715,
          "preferredLanguages" => ["en"],
          "registrations" => [...],
          "tenantId" => "6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
          "timezone" => "America/Los_Angeles",
          "twoFactorDelivery" => "None",
          "twoFactorEnabled" => false,
          "username" => "cogadmin",
          "usernameStatus" => "ACTIVE",
          "verified" => true
        }
      },
      %Tesla.Env{...}
    }

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.get_user_by_email(client, "invalidemail@invalid.com")
    {:error, "", %Tesla.Env{...}}

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user
  """
  @spec get_user_by_email(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def get_user_by_email(client, email) do
    Tesla.get(client, @users_url <> "?email=#{email}") |> FusionAuth.result()
  end

  @doc """
  Get a user by the user’s username.

    ## Examples

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.get_user_by_username(client, "cogadmin")
    {
      :ok,
      %{
        "user" => %{
          "active" => true,
          "email" => "cogadmin@cogility.com",
          "firstName" => "Cogility",
          "fullName" => "Cogility Admin",
          "id" => "06da543e-df3e-4011-b122-a9ff04326599",
          "insertInstant" => 1590606624689,
          "lastLoginInstant" => 1590607603500,
          "lastName" => "Admin",
          "memberships" => [...],
          "mobilePhone" => "6092895176",
          "passwordChangeRequired" => false,
          "passwordLastUpdateInstant" => 1590606624715,
          "preferredLanguages" => ["en"],
          "registrations" => [...],
          "tenantId" => "6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
          "timezone" => "America/Los_Angeles",
          "twoFactorDelivery" => "None",
          "twoFactorEnabled" => false,
          "username" => "cogadmin",
          "usernameStatus" => "ACTIVE",
          "verified" => true
        }
      },
      %Tesla.Env{...}
    }

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.get_user_by_username(client, "invalid")
    {:error, "", %Tesla.Env{...}}

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
  @spec bulk_delete_users(FusionAuth.client(), list(), boolean()) :: FusionAuth.request()
  def bulk_delete_users(client, user_ids, hard_delete \\ nil) do
    Tesla.delete(
      client,
      @users_url <>
        "/bulk" <> Utils.build_query_parameters(userId: user_ids, hardDelete: hard_delete)
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
  @spec search_users(FusionAuth.client(), FusionAuth.search_criteria()) :: FusionAuth.request()
  def search_users(client, search) do
    Tesla.post(client, @users_url <> "/search", %{search: search}) |> FusionAuth.result()
  end

  @doc """
  Get recent logins.

  https://fusionauth.io/docs/v1/tech/apis/users#retrieve-recent-logins
  """
  @spec get_recent_logins(FusionAuth.client(), integer() | nil, integer() | nil, String.t() | nil) ::
          FusionAuth.request()
  def get_recent_logins(client, limit \\ nil, offset \\ nil, user_id \\ nil) do
    Tesla.get(
      client,
      @users_url <>
        "/recent-login" <>
        Utils.build_query_parameters(limit: limit, offset: offset, userId: user_id)
    )
    |> FusionAuth.result()
  end

  @doc """
  Verify a user's email.

  https://fusionauth.io/docs/v1/tech/apis/users#verify-a-users-email
  """
  @spec verify_user_email(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def verify_user_email(client, verification_id) do
    Tesla.post(client, @users_url <> "/verify-email/#{verification_id}")
    |> FusionAuth.result()
  end

  @doc """
  Resend verification email.

  https://fusionauth.io/docs/v1/tech/apis/users#resend-verification-email
  """
  @spec resend_verification_email(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def resend_verification_email(client, email) do
    Tesla.put(client, @users_url <> "/verify-email?email=#{email}", %{})
    |> FusionAuth.result()
  end

  @doc """
  Start forgot password workflow.

  https://fusionauth.io/docs/v1/tech/apis/users#start-forgot-password-workflow
  """
  @spec forgot_password(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def forgot_password(client, login_id) do
    Tesla.post(client, @users_url <> "/forgot-password", %{loginId: login_id})
    |> FusionAuth.result()
  end

  @doc """
  Change a user's password with a change password ID. This usually occurs after an email has been sent to the user
  and they clicked on a link to reset their password.

  https://fusionauth.io/docs/v1/tech/apis/users#change-a-users-password
  """
  @spec change_password(FusionAuth.client(), String.t(), map()) ::
          FusionAuth.request()
  def change_password(client, change_password_id, password_data) do
    Tesla.post(client, @users_url <> "/change-password/#{change_password_id}", password_data)
    |> FusionAuth.result()
  end

  @doc """
  Change a user's password using their identity (loginID and password). Using a loginId instead of the changePasswordId
  bypasses the email verification and allows a password to be changed directly without first calling the forgot_password
  method.

  https://fusionauth.io/docs/v1/tech/apis/users#change-a-users-password
  """
  @spec change_password_by_identity(FusionAuth.client(), map()) :: FusionAuth.request()
  def change_password_by_identity(client, password_data) do
    Tesla.post(client, @users_url <> "/change-password", password_data)
    |> FusionAuth.result()
  end
end
