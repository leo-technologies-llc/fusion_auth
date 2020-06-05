defmodule FusionAuth.Applications do
  @moduledoc """
  The `FusionAuth.Applications` module provides access methods to the [FusionAuth Applications API](https://fusionauth.io/docs/v1/tech/apis/applications).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.

  # Application Fields

    - active :: boolean()\n
      Whether or not the Application is active.

    - cleanSpeakConfiguration :: map()\n
      Configuration for CleanSpeak.

    - data :: map()\n
      An object that can hold any information about the Application that should be persisted.

    - jwtConfiguration :: map()\n
      Configuration for JWT.

    - lambdaConfiguration :: map()\n
      Lambda configuration.

    - name :: String.t()\n
      The name of the Application.

    - loginConfiguration :: map()\n
      Configuration for login.

    - oauthConfiguration :: map()\n
      Configuration for OAuth.

    - registrationDeletePolicy :: map()\n
      Settings for deleting a registration after a set timeout.

    - roles :: list()\n
      An array of Role objects

    - samlv2Configuration
      SAML configuration settings.

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
        headers: [
          {"content-type", "application/json;charset=UTF-8"},
          {"content-length", "1495"},
          {"date", "Fri, 05 Jun 2020 21:06:15 GMT"}
        ],
        method: :get,
        opts: [],
        query: [],
        status: 200,
        url: "http://localhost:9011/api/application/8e0c9833-2e6b-4b1c-9665-4c1af7b4f00a"
      }}

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
          "role" => %{
            "id" => "54d363df-373b-4bca-b478-941fcdacb3d0",
            "isDefault" => false,
            "isSuperRole" => true,
            "name" => "Test Role"
          }
        },
        headers: [
          {"content-type", "application/json;charset=UTF-8"},
          {"content-length", "110"},
          {"date", "Fri, 05 Jun 2020 21:13:31 GMT"}
        ],
        method: :patch,
        opts: [],
        query: [],
        status: 200,
        url: "http://localhost:9011/api/application/8e0c9833-2e6b-4b1c-9665-4c1af7b4f00a/role/54d363df-373b-4bca-b478-941fcdacb3d0"
      }}
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
