defmodule FusionAuth.Users do
  @moduledoc """
  The `FusionAuth.Users` module provides access functions to the [FusionAuth Users API](https://fusionauth.io/docs/v1/tech/apis/users).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.

  ## User Fields

    - token :: String.t()\n
      The access token, this string is an encoded JSON Web Token (JWT).

    - active :: boolean()\n
      True if the User is active. False if the User has been deactivated. Deactivated Users will not be able to login.

    - birthDate :: String.t()\n
      The User’s birthdate formatted as `YYYY-MM-DD`.

    - cleanSpeakId :: String.t()\n
      This Id is used by FusionAuth when the User’s username is sent to CleanSpeak to be moderated (filtered and potentially sent to the approval queue). It is the *content Id* of the username inside CleanSpeak.

    - data :: map()\n
      An object that can hold any information about the User that should be persisted.

    - email :: String.t()\n
      The User’s email address.

    - expiry :: float()\n
      The expiration instant of the User’s account. An expired user is not permitted to login.

    - firstName :: String.t()\n
      The first name of the User.

    - fullName :: String.t()\n
      The User’s full name as a separate field that is not calculated from `firstName` and `lastName`.

    - id :: String.t()\n
      The User's unique Id.

    - imageUrl :: String.t()\n
      The URL that points to an image file that is the User’s profile image.

    - insertInstant :: float()\n
      The instant when user was created.

    - lastLoginInstant :: float()\n
      The instant when the User logged in last.

    - lastName :: String.t()\n
      The User's last name.

    - middleName :: String.t()\n
      The User's middle name.

    - mobilePhone :: String.t()\n
      The User’s mobile phone number. This is useful is you will be sending push notifications or SMS messages to the User.

    - parentEmail :: String.t()\n
      The email address of the user’s parent or guardian. If this value was provided during a create or update operation, this value value will only remain until the child is claimed by a parent.

    - passwordChangeRequired :: boolean()\n
      Indicates that the User’s password needs to be changed during their next login attempt.

    - passwordLastUpdateInstant :: float()\n
      The instant that the User last changed their password.

    - preferredLanguages :: list()\n
      An array of locale strings that give, in order, the User’s preferred languages. These are important for email templates and other localizable text. See [Locales](https://fusionauth.io/docs/v1/tech/reference/data-types#locales).

    - registrations :: list()\n
      The list of registrations for the User.

    - tenantId :: String.t()\n
      The Id of the Tenant that this User belongs to.

    - timezone :: String.t()\n
      The User’s preferred timezone. This can be used as a default to display instants, and it is recommended that you allow User’s to change this per-session. The string will be in an [IANA](https://www.iana.org/time-zones) time zone format.

    - twoFactorDelivery :: String.t()\n
      The User’s preferred delivery for verification codes during a two factor login request.

    - twoFactorEnabled :: boolean()\n
      Determines if the User has two factor authentication enabled for their account or not.

    - username :: String.t()\n
      The username of the User.

    - usernameStatus :: String.t()\n
      The current status of the username. This is used if you are moderating usernames via CleanSpeak.

    - verified :: boolean()\n
      Whether or not the User’s email has been verified.

  ## Examples

      iex> client = FusionAuth.client("http://localhost:9011", "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8", "6b40f9d6-cfd8-4312-bff8-b082ad45e93c")
      iex> FusionAuth.Users.get_user_by_id(client, "06da543e-df3e-4011-b122-a9ff04326599")
      {:ok,
        %{
          "user" => %{
            "active" => true,
            "email" => "cogadmin@cogility.com",
            "firstName" => "Cogility",
            "fullName" => "Cogility Admin",
            "id" => "06da543e-df3e-4011-b122-a9ff04326599",
            "insertInstant" => 1590606624689,
            "lastLoginInstant" => 1591138635342,
            "lastName" => "Admin",
            "memberships" => [
              %{
                "groupId" => "6f0a1769-21f3-4705-a653-bd66c3ff6a63",
                "id" => "ff6fea80-31a3-439b-b880-def21933a01d",
                "insertInstant" => 1590705735370
              }
            ],
            "mobilePhone" => "6092895176",
            "passwordChangeRequired" => false,
            "passwordLastUpdateInstant" => 1590606624715,
            "preferredLanguages" => ["en"],
            "registrations" => [
              %{
                "applicationId" => "f8109431-14f2-4815-9987-77fdedeff802",
                "id" => "7aaad5c8-846d-4a40-b587-fa62f0e6240e",
                "insertInstant" => 1590606684278,
                "lastLoginInstant" => 1591138635342,
                "preferredLanguages" => ["en"],
                "roles" => ["admin", "user"],
                "timezone" => "America/Los_Angeles",
                "username" => "cogadmin",
                "usernameStatus" => "ACTIVE",
                "verified" => true
              }
            ],
            "tenantId" => "6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
            "timezone" => "America/Los_Angeles",
            "twoFactorDelivery" => "None",
            "twoFactorEnabled" => false,
            "username" => "cogadmin",
            "usernameStatus" => "ACTIVE",
            "verified" => true
          }
        },
        %Tesla.Env{
          __client__: %Tesla.Client{
            adapter: {Tesla.Adapter.Hackney, :call, [[recv_timeout: 30000]]},
            fun: nil,
            post: [],
            pre: [
              {Tesla.Middleware.BaseUrl, :call, ["http://localhost:9011"]},
              {Tesla.Middleware.JSON, :call, [[]]},
              {Tesla.Middleware.Headers, :call,
                [
                  [
                    {"Authorization", "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"},
                    {"X-FusionAuth-TenantId", "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"}
                  ]
                ]}
            ]
          },
          __module__: Tesla,
          body: %{
            "user" => %{
              "active" => true,
              "email" => "cogadmin@cogility.com",
              "firstName" => "Cogility",
              "fullName" => "Cogility Admin",
              "id" => "06da543e-df3e-4011-b122-a9ff04326599",
              "insertInstant" => 1590606624689,
              "lastLoginInstant" => 1591138635342,
              "lastName" => "Admin",
              "memberships" => [
                %{
                  "groupId" => "6f0a1769-21f3-4705-a653-bd66c3ff6a63",
                  "id" => "ff6fea80-31a3-439b-b880-def21933a01d",
                  "insertInstant" => 1590705735370
                }
              ],
              "mobilePhone" => "6092895176",
              "passwordChangeRequired" => false,
              "passwordLastUpdateInstant" => 1590606624715,
              "preferredLanguages" => ["en"],
              "registrations" => [
                %{
                  "applicationId" => "f8109431-14f2-4815-9987-77fdedeff802",
                  "id" => "7aaad5c8-846d-4a40-b587-fa62f0e6240e",
                  "insertInstant" => 1590606684278,
                  "lastLoginInstant" => 1591138635342,
                  "preferredLanguages" => ["en"],
                  "roles" => ["admin", "user"],
                  "timezone" => "America/Los_Angeles",
                  "username" => "cogadmin",
                  "usernameStatus" => "ACTIVE",
                  "verified" => true
                }
              ],
              "tenantId" => "6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
              "timezone" => "America/Los_Angeles",
              "twoFactorDelivery" => "None",
              "twoFactorEnabled" => false,
              "username" => "cogadmin",
              "usernameStatus" => "ACTIVE",
              "verified" => true
            }
          },
          headers: [
            {"content-type", "application/json;charset=UTF-8"},
            {"content-length", "1033"},
            {"date", "Thu, 04 Jun 2020 17:48:29 GMT"}
          ],
          method: :get,
          opts: [],
          query: [],
          status: 200,
          url: "http://localhost:9011/api/user/06da543e-df3e-4011-b122-a9ff04326599"
        }}

  """
  alias FusionAuth.Utils

  @users_url "/api/user"

  @type search_criteria() :: %{
          ids: list() | nil,
          query: String.t() | nil,
          query_string: String.t() | nil,
          number_of_results: integer() | nil,
          sort_fields: list(sort_field()) | nil,
          start_row: integer() | nil
        }
  @type sort_field() :: %{
          missing: String.t() | nil,
          name: String.t(),
          order: String.t() | nil
        }

  @doc """
  Create a new user. You must specify either the email or the username or both for the User. Either of these values
  may be used to uniquely identify the User and may be used to authenticate the User.

  For more information visit the FusionAuth API Documentation for [Create a User](https://fusionauth.io/docs/v1/tech/apis/users#create-a-user).
  """
  @spec create_user(FusionAuth.client(), map()) :: FusionAuth.result()
  def create_user(client, user) do
    Tesla.post(client, @users_url, %{user: user}) |> FusionAuth.result()
  end

  @doc """
  Get a user by the user’s ID.

  For more information visit the FusionAuth API Documentation for [Retrieve a User](https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user).
  """
  @spec get_user_by_id(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_user_by_id(client, user_id) do
    Tesla.get(client, @users_url <> "/#{user_id}") |> FusionAuth.result()
  end

  @doc """
  Get a user by the user’s email.

  For more information visit the FusionAuth API Documentation for [Retrieve a User](https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user).
  """
  @spec get_user_by_email(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_user_by_email(client, email) do
    Tesla.get(client, @users_url <> "?email=#{email}") |> FusionAuth.result()
  end

  @doc """
  Get a user by the user’s username.

  For more information visit the FusionAuth API Documentation for [Retrieve a User](https://fusionauth.io/docs/v1/tech/apis/users#retrieve-a-user).
  """
  @spec get_user_by_username(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_user_by_username(client, username) do
    Tesla.get(client, @users_url <> "?username=#{username}") |> FusionAuth.result()
  end

  @doc """
  Update a user.

  For more information visit the FusionAuth API Documentation for [Update a User](https://fusionauth.io/docs/v1/tech/apis/users#update-a-user).
  """
  @spec update_user(FusionAuth.client(), String.t(), map()) :: FusionAuth.result()
  def update_user(client, user_id, user) do
    Tesla.patch(client, @users_url <> "/#{user_id}", %{user: user}) |> FusionAuth.result()
  end

  @doc """
  Deactivate or delete a user by the user's ID. Soft deleted Users are marked as inactive but not deleted from FusionAuth.

  ## Parameters

    - hardDelete :: boolean() :: Optional :: _Defaults to false_\n
    To Permanently delete a user from FusionAuth set this value to `true`. Once a user has been permanently deleted, the action cannot be undone. When this value is set to `false` the user is marked as inactive and the user will be unable log into FusionAuth. This action may be undone by reactivating the user.

  For more information visit the FusionAuth API Documentation for [Delete a User](https://fusionauth.io/docs/v1/tech/apis/users#delete-a-user).
  """
  @spec delete_user(FusionAuth.client(), key: boolean()) :: FusionAuth.result()
  def delete_user(client, user_id, parameters \\ []) do
    Tesla.delete(client, @users_url <> "/#{user_id}" <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Bulk deactivate or delete users based on their user IDs.

  ## Parameters

    - dryRun :: boolean() :: Optional :: _Defaults to false_\n
      To preview the user Ids to be deleted by the request without applying the requested action set this value to `true`.

    - hardDelete :: boolean() :: Optional :: _Defaults to false_\n
      To Permanently delete a user from FusionAuth set this value to `true`. Once a user has been permanently deleted, the action cannot be undone. When this value is set to `false` the user is marked as inactive and the user will be unable log into FusionAuth. This action may be undone by reactivating the user.

    - query :: String.t() :: Optional\n
      The raw JSON Elasticsearch query that is used to search for Users. The `userId`, `query`, and `queryString` parameters are mutually exclusive, they are listed here in order of precedence.

      It is necessary to use the `query` parameter when querying against registrations in order to achieve expected results, as this field is defined as a nested datatype in the Elasticsearch mapping.

    - queryString :: String.t() :: Optional\n
      The Elasticsearch query string that is used to search for Users to be deleted. The userId, query, and queryString parameters are mutually exclusive, they are listed here in order of precedence.

    - userId :: list() :: Optional\n
      The Id of the User to delete. Repeat this parameter for each user to be deleted. The `userId`, `query`, and `queryString` parameters are mutually exclusive, they are listed here in order of precedence.

  For more information visit the FusionAuth API Documentation for [Bulk Delete Users](https://fusionauth.io/docs/v1/tech/apis/users#bulk-delete-users).
  """
  @spec bulk_delete_users(FusionAuth.client(), key: list() | String.t() | boolean()) ::
          FusionAuth.result()
  def bulk_delete_users(client, parameters \\ []) do
    Tesla.delete(client, @users_url <> "/bulk" <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Reactivate an inactive user by the user's ID.

  For more information visit the FusionAuth API Documentation for [Reactivate a User](https://fusionauth.io/docs/v1/tech/apis/users#reactivate-a-user).
  """
  @spec reactivate_user(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def reactivate_user(client, user_id) do
    Tesla.put(client, @users_url <> "/#{user_id}?reactivate=true", %{}) |> FusionAuth.result()
  end

  @doc """
  Bulk import multiple users.

  For more information visit the FusionAuth API Documentation for [Import Users](https://fusionauth.io/docs/v1/tech/apis/users#import-users).
  """
  @spec import_users(FusionAuth.client(), list()) :: FusionAuth.result()
  def import_users(client, users) do
    Tesla.post(client, @users_url <> "/import", %{users: users}) |> FusionAuth.result()
  end

  @doc """
  Search for users.

  For more information visit the FusionAuth API Documentation for [Search for Users](https://fusionauth.io/docs/v1/tech/apis/users#search-for-users).
  """
  @spec search_users(FusionAuth.client(), search_criteria()) :: FusionAuth.result()
  def search_users(client, search) do
    Tesla.post(client, @users_url <> "/search", %{search: search}) |> FusionAuth.result()
  end

  @doc """
  Get recent logins for a specific user or all users. If no userId is specified, recent logins for all users in the
  system will be returned.

  ## Parameters

    - limit :: integer() :: Optional :: _Defaults to 10_\n
      This parameter indicates the maximum amount of logins to return for a single request.

    - offset :: integer() :: Optional :: _Default to 0_\n
      This parameter provides the offset into the result set. Generally speaking if you wish to paginate the results, you will increment this parameter on subsequent API request by the size of the `limit` parameter.

    - userId :: String.t() :: Optional
      This parameter will narrow the results to only logins for a particular user. When this parameter is omitted, the most recent logins for all of FusionAuth will be returned.

  For more information visit the FusionAuth API Documentation for [Retrieve Recent Logins](https://fusionauth.io/docs/v1/tech/apis/users#retrieve-recent-logins).
  """
  @spec get_recent_logins(FusionAuth.client(), key: integer() | String.t()) :: FusionAuth.result()
  def get_recent_logins(client, parameters \\ []) do
    Tesla.get(client, @users_url <> "/recent-login" <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Verify a user's email.

  For more information visit the FusionAuth API Documentation for [Verify a User's Email](https://fusionauth.io/docs/v1/tech/apis/users#verify-a-users-email).
  """
  @spec verify_user_email(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def verify_user_email(client, verification_id) do
    Tesla.post(client, @users_url <> "/verify-email/#{verification_id}", %{})
    |> FusionAuth.result()
  end

  @doc """
  Resend verification email.

  For more information visit the FusionAuth API Documentation for [Resend Verification Email](https://fusionauth.io/docs/v1/tech/apis/users#resend-verification-email).
  """
  @spec resend_verification_email(FusionAuth.client(), String.t()) :: FusionAuth.result()
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

  For more information visit the FusionAuth API Documentation for [Start Forgot Password Workflow](https://fusionauth.io/docs/v1/tech/apis/users#start-forgot-password-workflow).
  """
  @spec forgot_password(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def forgot_password(client, login_id) do
    Tesla.post(client, @users_url <> "/forgot-password", %{loginId: login_id})
    |> FusionAuth.result()
  end

  @doc """
  Change a user's password with a change password ID. This usually occurs after an email has been sent to the user
  and they clicked on a link to reset their password.

  For more information visit the FusionAuth API Documentation for [Change a User's Password](https://fusionauth.io/docs/v1/tech/apis/users#change-a-users-password).
  """
  @spec change_password(FusionAuth.client(), String.t(), map()) ::
          FusionAuth.result()
  def change_password(client, change_password_id, password_data) do
    Tesla.post(client, @users_url <> "/change-password/#{change_password_id}", password_data)
    |> FusionAuth.result()
  end

  @doc """
  Change a user's password using their identity (loginID and password). Using a loginId instead of the changePasswordId
  bypasses the email verification and allows a password to be changed directly without first calling the forgot_password
  method.

  For more information visit the FusionAuth API Documentation for [Change a User's Password](https://fusionauth.io/docs/v1/tech/apis/users#change-a-users-password).
  """
  @spec change_password_by_identity(FusionAuth.client(), map()) :: FusionAuth.result()
  def change_password_by_identity(client, password_data) do
    Tesla.post(client, @users_url <> "/change-password", password_data)
    |> FusionAuth.result()
  end
end
