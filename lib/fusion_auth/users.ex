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
  Create a new user. You must specify either the email or the username or both for the User. Either of these values
  may be used to uniquely identify the User and may be used to authenticate the User.

    ## Examples

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.create_user(client, %{
      "birthDate": "1976-05-30",
      "data": %{
        "displayName": "Johnny Boy",
        "favoriteColors": [
          "Red",
          "Blue"
        ]
      },
      "email": "example@fusionauth.io",
      "encryptionScheme": "salted-sha256",
      "factor": 24000,
      "expiry": 1571786483322,
      "firstName": "John",
      "fullName": "John Doe",
      "imageUrl": "http://65.media.tumblr.com/tumblr_l7dbl0MHbU1qz50x3o1_500.png",
      "lastName": "Doe",
      "middleName": "William",
      "mobilePhone": "303-555-1234",
      "passwordChangeRequired": false,
      "preferredLanguages": [
        "en",
        "fr"
      ],
      "timezone": "America/Los_Angeles",
      "twoFactorEnabled": false,
      "usernameStatus": "ACTIVE",
      "username": "johnny123"
    })
    {
      :ok,
      %{
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImMxVU5ON0pIUVc4X21ROHBTaWZKbzBXekdybDlTbTRnIn0.eyJleHAiOjE1ODY4ODQzNzksImlhdCI6MTU4Njg4NDMxOSwiaXNzIjoiZnVzaW9uYXV0aC5pbyIsInN1YiI6IjAwMDAwMDAwLTAwMDAtMDAwMS0wMDAwLTAwMDAwMDAwMDAwMCIsImF1dGhlbnRpY2F0aW9uVHlwZSI6IlVTRVJfQ1JFQVRFIiwiZW1haWwiOiJ0ZXN0MEBmdXNpb25hdXRoLmlvIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6InVzZXJuYW1lMCJ9.Z1jV8xDcayZZDBdLRVd2fIyowhstRI4Dgk7_u2XFerc",
        "user" => %{
          "active" => true,
          "birthDate" => "1976-05-30",
          "data" => %{
            "displayName": "Johnny Boy",
            "favoriteColors" => [
              "Red",
              "Blue"
            ]
          },
          "email" => "example@fusionauth.io",
          "expiry" => 1571786483322,
          "firstName" => "John",
          "fullName" => "John Doe",
          "id" => "00000000-0000-0001-0000-000000000000",
          "imageUrl" => "http://65.media.tumblr.com/tumblr_l7dbl0MHbU1qz50x3o1_500.png",
          "lastLoginInstant" => 1471786483322,
          "lastName" => "Doe",
          "memberships" => [%{
            "data" => %{
              "externalId" => "cc6714c6-286c-411c-a6bc-ee413cda1dbc"
            },
            "groupId" => "2cb5c83f-53ff-4d16-88bd-c5e3802111a5",
            "id" => "27218714-305e-4408-bac0-23e7e1ddceb6",
            "insertInstant" => 1471786482322
          }],
          "middleName" => "William",
          "mobilePhone" => "303-555-1234",
          "passwordChangeRequired" => false,
          "passwordLastUpdateInstant" => 1471786483322,
          "preferredLanguages" => [
            "en",
            "fr"
          ],
          "registrations" => [
            %{
              "applicationId" => "10000000-0000-0002-0000-000000000001",
              "data" => %{
                "displayName" => "Johnny",
                "favoriteSports" => [
                  "Football",
                  "Basketball"
                ]
              },
              "id" => "00000000-0000-0002-0000-000000000000",
              "insertInstant" => 1446064706250,
              "lastLoginInstant" => 1456064601291,
              "preferredLanguages" => [
                "en",
                "fr"
              ],
              "roles" => [
                "user",
                "community_helper"
              ],
              "timezone" => "America/Chicago",
              "tokens" => %{
                "Facebook" => "nQbbBIzDhMXXfa7iDUoonz5zS",
                "19544aa2-d634-4859-b193-e57af82b5d12" => "eu1SsrjsiDf3h3LryUjxHIKTS0yyrbiPcsKF3HDp"
              },
              "username" => "johnny123",
              "usernameStatus" => "ACTIVE"
            }
          ],
          "timezone" => "America/Los_Angeles",
          "tenantId" => "f24aca2b-ce4a-4dad-951a-c9d690e71415",
          "twoFactorEnabled" => false,
          "usernameStatus" => "ACTIVE",
          "username" => "johnny123",
          "verified" => true
        }
      },
      %Tesla.Env{...}
    }

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.create_user(client, %{})
    {
      :error,
      %{
        "fieldErrors" => %{
          "user.email" => [
            %{
              "code" => "[blank]user.email",
              "message" => "You must specify either the [user.email] or [user.username] property. If you are emailing the user you must specify the [user.email]."
            }
          ],
          "user.password" => [
            %{
              "code" => "[blank]user.password",
              "message" => "You must specify the [user.password] property."
            }
          ],
          "user.username" => [
            %{
              "code" => "[blank]user.username",
              "message" => "You must specify either the [user.email] or [user.username] property. If you are emailing the user you must specify the [user.email]."
            }
          ]
        }
      },
      %Tesla.Env{...}
    }

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
  Deactivate or delete a user by the user's ID. Soft deleted Users are marked as inactive but not deleted from FusionAuth.

  https://fusionauth.io/docs/v1/tech/apis/users#delete-a-user
  """
  @spec delete_user(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def delete_user(client, user_id, hard_delete \\ nil) do
    Tesla.delete(
      client,
      @users_url <> "/#{user_id}" <> Utils.build_query_parameters(hardDelete: hard_delete)
    )
    |> FusionAuth.result()
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
    Tesla.put(client, @users_url <> "/#{user_id}?reactivate=true", %{}) |> FusionAuth.result()
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

    ## Examples

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.search_users(client, %{
      numberOfResults: 10,
      queryString: "memberships.groupId:6f0a1769-21f3-4705-a653-bd66c3ff6a63",
      sortFields: [
        %{
          missing: "_first",
          name: "email",
          order: "asc"
        }
      ],
      startRow: 0
    })
    {
      :ok,
      %{
        "total" => 2,
        "users" => [...],
      },
      %Tesla.Env{...}
    }

    iex> client = FusionAuth.client("https://10.1.101.112:9011", "fusion_auth_api_key")
    iex> FusionAuth.Users.search_users(client, %{invalid: "body"})
    {
      :error,
      %{
        "fieldErrors" => %{}
      },
      %Tesla.Env{...}
    }

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
    Tesla.post(client, @users_url <> "/verify-email/#{verification_id}", %{})
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
  Start forgot password workflow. For example, on your login form you may have a button for Forgot your password. This
  would be the API you would call to initiate the request for the user. If the email configuration is complete, the user
  will be sent the forgot password email containing a link containing the changePasswordId. The provided link should take
  the user to a form that allows them to change their password. This form should contain a hidden field for the
  changePasswordId generated by this API.

  The login identifier can be either the email or the username. The username is not case sensitive.

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
