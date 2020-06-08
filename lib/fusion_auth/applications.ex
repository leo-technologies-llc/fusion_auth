defmodule FusionAuth.Applications do
  @moduledoc """
  The `FusionAuth.Applications` module provides access methods to the [FusionAuth Applications API](https://fusionauth.io/docs/v1/tech/apis/applications).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.

  # Application Fields

    - active :: boolean()\n
      Whether or not the Application is active.

    - authenticationTokenConfiguration :: map()\n

      - enabled :: boolean()\n
        Whether or not Users can have Authentication Tokens associated with this Application.

    - cleanSpeakConfiguration :: map()\n

      - applicationIds :: list()\n
        An array of UUIDs that map to the CleanSpeak applications for this Application.

      - enabled :: boolean()\n
        True if CleanSpeak integration is enabled. This setting is global and is not modifiable using this API.

      - usernameModeration :: map()\n

        - applicationId :: String.t()\n
          The Id of the CleanSpeak application that usernames are sent to for moderation.

        - enabled :: boolean()\n
          True if CleanSpeak username moderation is enabled.

    - data :: map()\n
      An object that can hold any information about the Application that should be persisted.

    - jwtConfiguration :: map()\n

      - accessTokenKeyId :: String.t()\n
        The Id of the signing key used to sign the access token.

      - enabled :: boolean()\n
        Indicates if this application is using the JWT configuration defined here or the global JWT configuration defined by the System Configuration.

      - idTokenKeyId :: String.t()\n
        The Id of the signing key used to sign the Id token.

      - refreshTokenTimeToLiveInMinutes :: integer()\n
        The length of time in minutes the JWT refresh token will live before it is expired and is not able to be exchanged for a JWT.

      - timeToLiveInSeconds :: integer()\n
        The length of time in seconds the JWT will live before it is expired and no longer valid.

    - lambdaConfiguration :: map()\n

      - accessTokenPopulateId :: String.t()\n
        The Id of the Lambda that will be invoked when an access token is generated for this application. This will be utilized during OAuth2 and OpenID Connect authentication requests as well as when an access token is generated for the Login API.

      - idTokenPopulateId :: String.t()\n
        The Id of the Lambda that will be invoked when an Id token is generated for this application during an OpenID Connect authentication request.

      - samlv2PopulateId :: String.t()\n
        The Id of the Lambda that will be invoked when a a SAML response is generated during a SAML authentication request.

    - loginConfiguration :: map()\n

      - allowTokenRefresh :: boolean()\n
        Indicates if a JWT may be refreshed using a Refresh Token for this application. This configuration is separate from issuing new Refresh Tokens which is controlled by the generateRefreshTokens parameter.

      - generateRefreshTokens :: boolean()\n
        Indicates if a Refresh Token should be issued from the Login API.

      - requireAuthentication :: boolean()\n
        Indicates if the Login API should require an API key. If you set this value to false and your FusionAuth API is on a public network, anyone may attempt to use the Login API.

    - name :: String.t()\n
      The name of the Application.

    - oauthConfiguration :: map()\n

      - authorizedOriginURLs :: list()\n
        An array of URLs that are the authorized origins for FusionAuth OAuth.

      - authorizedRedirectURLs :: list()\n
        An array of URLs that are the authorized redirect URLs for FusionAuth OAuth.

      - clientId :: String.t()\n
        The OAuth client Id of the Application.

      - clientSecret :: String.t()\n
        The OAuth client secret.

      - deviceVerificationURL :: String.t()\n
        The device verification URL to be used with the Device Code grant type.

      - enabledGrants :: list()\n
        The enabled grants for this application. Supported values include: authorization_code, implicit, password, refresh_token, device_code

      - generateRefreshTokens :: boolean()\n
        Determines if the OAuth 2.0 Token endpoint will generate a refresh token when the offline_access scope is requested.

      - logoutBehavior :: String.t()\n
        Behavior when /oauth2/logout is called. Valid values: RedirectOnly, AllApplications

      - logoutURL :: String.t()\n
        The logout URL for the Application. FusionAuth will redirect to this URL after the user logs out of OAuth.

      - requireClientAuthentication :: boolean()\n
        Determines if the OAuth 2.0 Token endpoint requires client authentication. If this is enabled, the client must provide client credentials when using the Token endpoint.

    - passwordlessConfiguration :: map()\n

      - enabled :: boolean()\n
        Determines if passwordless login is enabled for this application.

    - registrationConfiguration :: map()\n

      - birthDate :: map()\n

        - enabled :: boolean()\n
          Determines if the birthDate field will be included on the registration form.

        - required :: boolean()\n
          Determines if the birthDate field is required when displayed on the registration form.

      - confirmPassword :: boolean()\n
        Determines if the password should be confirmed during self service registration, this means that the user will be required to type the password twice.

      - enabled :: boolean()\n
        Determines if self service registration is enabled for this application. When this value is false, you may still use the Registration API, this only affects if the self service option is available during the OAuth 2.0 login.

      - firstName :: map()\n

        - enabled :: boolean()\n
          Determines if the firstName field will be included on the registration form.

        - required :: boolean()\n
          Determines if the firstName field is required when displayed on the registration form.

      - fullName :: map()\n

        - enabled :: boolean()\n
          Determines if the fullName field will be included on the registration form.

        - required :: boolean()\n
          Determines if the fullName field is required when displayed on the registration form.

      - lastName :: map()\n

        - enabled :: boolean()\n
          Determines if the lastName field will be included on the registration form.

        - required :: boolean()\n
          Determines if the lastName field is required when displayed on the registration form.

      - loginIdType :: String.t()\n
        The unique login Id that will be collected during registration, this value can be email or username. Leaving the default value of email is preferred because an email address is globally unique.

      - middleName :: map()\n

        - enabled :: boolean()\n
          Determines if the middleName field will be included on the registration form.

        - required :: boolean()\n
          Determines if the middleName field is required when displayed on the registration form.

      - mobilePhone :: map()\n

        - enabled :: boolean()\n
          Determines if the mobilePhone field will be included on the registration form.

        - required :: boolean()\n
          Determines if the mobilePhone field is required when displayed on the registration form.

    - registrationDeletePolicy :: map()\n

      - unverified :: map()\n

        - enabled :: boolean()\n
          Indicates that users without a verified registration for this application will have their registration permanently deleted after application.registrationDeletePolicy.unverified.numberOfDaysToRetain days.

        - numberOfDaysToRetain :: integer()\n
          The number of days from registration a user’s registration will be retained before being deleted for not completing registration verification. Value must be greater than 0.

    - roles :: list()\n
      An array of Role objects

    - samlv2Configuration :: map()\n

      - audience :: String.t()\n
        The audience for the SAML response sent to back to the service provider from FusionAuth. Some service providers require different audience values than the issuer and this configuration option lets you change the audience in the response.

      - callbackURL :: String.t()\n
        The URL of the callback (sometimes called the Assertion Consumer Service or ACS). This is where FusionAuth sends the browser after the user logs in via SAML.

      - debug :: boolean()\n
        Whether or not FusionAuth will log SAML debug messages to the event log. This is useful for debugging purposes.

      - enabled :: boolean()\n
        Whether or not the SAML IdP for this Application is enabled or not.

      - issuer :: String.t()\n
        The issuer that identifies the service provider and allows FusionAuth to load the correct Application and SAML configuration.

      - keyId :: String.t()\n
        The id of the Key used to sign the SAML response.

      - logoutURL :: String.t()\n
        The URL that the browser is taken to after the user logs out of the SAML service provider.

      - xmlSignatureC14nMethod :: String.t()\n
        The XML signature canonicalization method used when digesting and signing the SAML response.

    - verificationEmailTemplateId :: String.t()\n
      The Id of the Email Template that is used to send the Registration Verification emails to users.

    - verifyRegistration :: boolean()\n
      Whether or not registrations to this Application may be verified.

  # Role Fields

    - description :: String.t()\n
      A description for the role.

    - name :: String.t()\n
      The name of the role.

    - isDefault :: boolean()\n
      Whether or not the Role is a default role. A default role is automatically assigned to a user during registration if no roles are provided.

    - isSuperRole :: boolean()\n
      Whether or not the Role is a considered to be a super user role. This is a marker to indicate that it supersedes all other roles. FusionAuth will attempt to enforce this contract when using the web UI, it is not enforced programmatically when using the API.

  ## Examples
      iex> client = FusionAuth.client("http://localhost:9011", "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8", "6b40f9d6-cfd8-4312-bff8-b082ad45e93c")
      iex> FusionAuth.Applications.get_application(client, "8e0c9833-2e6b-4b1c-9665-4c1af7b4f00a")
      {:ok,
        %{
          "application" => %{
            "active" => true,
            "authenticationTokenConfiguration" => %{"enabled" => false},
            "id" => "8e0c9833-2e6b-4b1c-9665-4c1af7b4f00a",
            "jwtConfiguration" => %{
              "enabled" => false,
              "refreshTokenExpirationPolicy" => "Fixed",
              "refreshTokenTimeToLiveInMinutes" => 0,
              "refreshTokenUsagePolicy" => "Reusable",
              "timeToLiveInSeconds" => 0
            },
            "lambdaConfiguration" => %{},
            "loginConfiguration" => %{
              "allowTokenRefresh" => false,
              "generateRefreshTokens" => false,
              "requireAuthentication" => true
            },
            "name" => "Test Application",
            "oauthConfiguration" => %{
              "clientId" => "8e0c9833-2e6b-4b1c-9665-4c1af7b4f00a",
              "clientSecret" => "6Gu2kpFxGN8YF9ztwjDdWy6pRTlsapgnWvIyIEzmGM1",
              "generateRefreshTokens" => false,
              "logoutBehavior" => "AllApplications",
              "requireClientAuthentication" => true
            },
            "passwordlessConfiguration" => %{"enabled" => false},
            "registrationConfiguration" => %{
              "birthDate" => %{"enabled" => false, "required" => false},
              "confirmPassword" => false,
              "enabled" => false,
              "firstName" => %{"enabled" => false, "required" => false},
              "fullName" => %{"enabled" => false, "required" => false},
              "lastName" => %{"enabled" => false, "required" => false},
              "loginIdType" => "email",
              "middleName" => %{"enabled" => false, "required" => false},
              "mobilePhone" => %{"enabled" => false, "required" => false}
            },
            "registrationDeletePolicy" => %{
              "unverified" => %{"enabled" => false, "numberOfDaysToRetain" => 0}
            },
            "roles" => [
              %{
                "id" => "54d363df-373b-4bca-b478-941fcdacb3d0",
                "isDefault" => false,
                "isSuperRole" => false,
                "name" => "Test Role"
              }
            ],
            "samlv2Configuration" => %{
              "debug" => false,
              "enabled" => false,
              "xmlSignatureC14nMethod" => "exclusive_with_comments"
            },
            "tenantId" => "6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
            "verifyRegistration" => false
          }
        },
        %Tesla.Env{...}
      }

      iex> client = FusionAuth.client("http://localhost:9011", "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8", "6b40f9d6-cfd8-4312-bff8-b082ad45e93c")
      iex> FusionAuth.Applications.update_role(client, "8e0c9833-2e6b-4b1c-9665-4c1af7b4f00a", "54d363df-373b-4bca-b478-941fcdacb3d0", %{isSuperRole: true})
      {:ok,
        %{
          "role" => %{
            "id" => "54d363df-373b-4bca-b478-941fcdacb3d0",
            "isDefault" => false,
            "isSuperRole" => true,
            "name" => "Test Role"
          }
        },
        %Tesla.Env{...}
      }
  """

  alias FusionAuth.Utils

  @applications_url "/api/application"

  @doc """
  Create a new application. You must specify an application name.

  For more information visit the FusionAuth API Documentation for [Create an Application](https://fusionauth.io/docs/v1/tech/apis/applications#create-an-application)
  """
  @spec create_application(FusionAuth.client(), map()) :: FusionAuth.result()
  def create_application(client, application) do
    Tesla.post(client, @applications_url, %{application: application}) |> FusionAuth.result()
  end

  @doc """
  List all active or inactive applications.

  ## Parameters

    - inactive :: boolean() :: Optional :: _Defaults to false_\n
    Specifying inactive to true will list all deactivated applications. Not specifying inactive true will list all active applications.


  For more information visit the FusionAuth API Documentation for [Retrieve an Application](https://fusionauth.io/docs/v1/tech/apis/applications#retrieve-an-application)
  """
  @spec list_applications(FusionAuth.client()) :: FusionAuth.result()
  def list_applications(client, parameters \\ []) do
    Tesla.get(client, @applications_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Get an application by the application's ID.

  For more information visit the FusionAuth API Documentation for [Retrieve an Application](https://fusionauth.io/docs/v1/tech/apis/applications#retrieve-an-application)
  """
  @spec get_application(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_application(client, application_id) do
    Tesla.get(client, @applications_url <> "/#{application_id}") |> FusionAuth.result()
  end

  @doc """
  Get an application's OAuth configuration by the application's ID.

  For more information visit the FusionAuth API Documentation for [Retrieve OAuth Configuration](https://fusionauth.io/docs/v1/tech/apis/applications#retrieve-oauth-configuration)
  """
  @spec get_oauth_configuration(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def get_oauth_configuration(client, application_id) do
    Tesla.get(client, @applications_url <> "/#{application_id}" <> "/oauth-configuration")
    |> FusionAuth.result()
  end

  @doc """
  Update an application by the application's ID.

  For more information visit the FusionAuth API Documentation for [Update an Application](https://fusionauth.io/docs/v1/tech/apis/applications#update-an-application)
  """
  @spec update_application(FusionAuth.client(), String.t(), map()) :: FusionAuth.result()
  def update_application(client, application_id, application) do
    Tesla.patch(client, @applications_url <> "/#{application_id}", %{application: application})
    |> FusionAuth.result()
  end

  @doc """
  Reactivate an inactive application by the application's ID.

  For more information visit the FusionAuth API Documentation for [Reactivate an Application](https://fusionauth.io/docs/v1/tech/apis/applications#reactivate-an-application)
  """
  @spec reactivate_application(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def reactivate_application(client, application_id) do
    Tesla.put(client, @applications_url <> "/#{application_id}?reactivate=true", %{})
    |> FusionAuth.result()
  end

  @doc """
  Deactivate or delete an application by the application's ID. Soft deleted Applications are marked as inactive but not deleted from FusionAuth.

  ## Parameters

    - hardDelete :: boolean() :: Optional :: _Defaults to false_\n
    To Permanently delete an application from FusionAuth set this value to `true`. Once an application has been permanently deleted, the action cannot be undone. When this value is set to `false` the application is marked as inactive. This action may be undone by reactivating the application.

  For more information visit the FusionAuth API Documentation for [Delete an Application](https://fusionauth.io/docs/v1/tech/apis/applications#delete-an-application)
  """
  @spec delete_application(FusionAuth.client(), String.t()) :: FusionAuth.result()
  def delete_application(client, application_id, parameters \\ []) do
    Tesla.delete(
      client,
      @applications_url <>
        "/#{application_id}" <> Utils.build_query_parameters(parameters)
    )
    |> FusionAuth.result()
  end

  @doc """
  Create a new role for a given application by the application's ID. You must specify an role name.

  For more information visit the FusionAuth API Documentation for [Create an Application Role](https://fusionauth.io/docs/v1/tech/apis/applications#create-an-application-role)
  """
  @spec create_role(FusionAuth.client(), String.t(), map()) :: FusionAuth.result()
  def create_role(client, application_id, role) do
    Tesla.post(client, @applications_url <> "/#{application_id}" <> "/role", %{role: role})
    |> FusionAuth.result()
  end

  @doc """
  Update a role for an application by the application & role IDs.

  For more information visit the FusionAuth API Documentation for [Update an Application Role](https://fusionauth.io/docs/v1/tech/apis/applications#update-an-application-role)
  """
  @spec update_role(FusionAuth.client(), String.t(), String.t(), map()) :: FusionAuth.result()
  def update_role(client, application_id, role_id, role) do
    Tesla.patch(client, @applications_url <> "/#{application_id}" <> "/role/#{role_id}", %{
      role: role
    })
    |> FusionAuth.result()
  end

  @doc """
  Delete a role for an application by the application & role IDs.

  For more information visit the FusionAuth API Documentation for [Delete an Application Role](https://fusionauth.io/docs/v1/tech/apis/applications#delete-an-application-role)
  """
  @spec delete_role_by_id(FusionAuth.client(), String.t(), String.t()) :: FusionAuth.result()
  def delete_role_by_id(client, application_id, role_id) do
    Tesla.delete(client, @applications_url <> "/#{application_id}" <> "/role/#{role_id}")
    |> FusionAuth.result()
  end

  @doc """
  Delete a role for an application by the application ID & role name.

  For more information visit the FusionAuth API Documentation for [Delete an Application Role](https://fusionauth.io/docs/v1/tech/apis/applications#delete-an-application-role)
  """
  @spec delete_role_by_name(FusionAuth.client(), String.t(), String.t()) :: FusionAuth.result()
  def delete_role_by_name(client, application_id, name) do
    name = String.replace(name, " ", "%20")

    Tesla.delete(client, @applications_url <> "/#{application_id}" <> "/role?name=#{name}")
    |> FusionAuth.result()
  end
end
