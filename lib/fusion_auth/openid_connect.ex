defmodule FusionAuth.OpenIdConnect do
  @moduledoc """
  The `FusionAuth.OpenIdConnect` module provides access methods to the [FusionAuth OpenID Connect API](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect).
  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.
  """

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()
  @type domain :: String.t()
  @type headers :: list()
  @type identity_provider_id :: String.t()
  @type application_id :: String.t()
  @type tenant_id :: String.t()
  @type identity_provider :: %{
          application_configuration: %{
            application_id() => application_configuration()
          },
          button_image_url: String.t(),
          button_text: String.t(),
          debug: boolean(),
          domains: [String.t()],
          lambda_configuration_reconciled: String.t(),
          linking_strategy: String.t(),
          name: String.t(),
          oauth_configuration: oauth_configuration(),
          post_request: boolean(),
          tenant_configuration_map: %{
            tenant_id() => tenant_configuration()
          },
          type: String.t()
        }
  @type application_configuration :: %{
          button_image_url: String.t(),
          button_text: String.t(),
          oauth_client_id: String.t(),
          oauth_client_secret: String.t(),
          create_registration: boolean(),
          enabled: boolean(),
          oauth_scope: String.t()
        }
  @type oauth_configuration :: %{
          authorization_endpoint: String.t(),
          client_id: String.t(),
          client_secret: String.t(),
          client_authentication_method: String.t(),
          email_claim: String.t(),
          issuer: String.t(),
          scope: String.t(),
          token_endpoint: String.t(),
          userinfo_endpoint: String.t()
        }
  @type tenant_configuration :: %{
          limit_user_link_count: %{
            enabled: integer(),
            maximum_links: integer()
          }
        }

  @type login_request_body :: %{
          application_id: String.t(),
          identity_provider_id: String.t(),
          ipAddress: String.t(),
          data: %{
            code: String.t(),
            redirect_uri: String.t()
          },
          metadata: %{
            device: %{
              description: String.t(),
              lastAccessedAddress: String.t(),
              name: String.t(),
              type: String.t()
            }
          },
          no_jwt: boolean(),
          no_link: boolean()
        }
  @connect_url "/api/identity-provider"

  @doc """
  Retrieves all identity providers

  For more information, visit the FusionAuth API documentation for [Retrieve all identity providers](https://fusionauth.io/docs/v1/tech/apis/identity-providers/#retrieve-all-identity-providers)
  """
  @spec retrieve_all_identity_providers(client()) :: FusionAuth.result()
  def retrieve_all_identity_providers(client) do
    Tesla.get(client, @connect_url)
    |> FusionAuth.result()
  end

  @doc """
  Looks up a specific identity provider using the domain, note: example@domain.com and domain.com are functionally equivalent

  For more information, visit the FusionAuth API documentation for [Lookup an identity provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/#lookup-an-identity-provider)
  """
  @spec lookup_identity_provider(client(), domain()) :: result()
  def lookup_identity_provider(client, domain) do
    Tesla.get(client, @connect_url <> "/lookup?domain=#{domain}")
    |> FusionAuth.result()
  end

  @doc """
  Creates an OpenID identity provider with the given identity provider configurations

  For more information, visit the FusionAuth API documentation for [Create an OpenID connect identity provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#create-an-openid-connect-identity-provider)
  """
  @spec create_openid_connect_identity_provider(client(), identity_provider()) :: result()
  def create_openid_connect_identity_provider(client, identity_provider) do
    Tesla.post(client, @connect_url, identity_provider)
    |> FusionAuth.result()
  end

  @doc """
  Creates an OpenID identity provider with the given identity provider configurations and uses the given UUID as the provider's ID

  For more information, visit the FusionAuth API documentation for [Create an OpenID connect identity provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#create-an-openid-connect-identity-provider)
  """
  @spec create_openid_connect_identity_provider_uuid(
          client(),
          identity_provider(),
          identity_provider_id()
        ) :: result()
  def create_openid_connect_identity_provider_uuid(
        client,
        identity_provider,
        identity_provider_id
      ) do
    Tesla.post(client, @connect_url <> "/#{identity_provider_id}", identity_provider)
    |> FusionAuth.result()
  end

  @doc """
  Retrieves an OpenID identity provider with the given identity provider ID

  For more information, visit the FusionAuth API documentation for [Retrieve an OpenID connect identity provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#retrieve-an-openid-connect-identity-provider)
  """
  @spec retrieve_openid_connect_identity_provider(client(), identity_provider_id()) :: result()
  def retrieve_openid_connect_identity_provider(client, identity_provider_id) do
    Tesla.get(client, @connect_url <> "/#{identity_provider_id}")
    |> FusionAuth.result()
  end

  @doc """
  Updates an OpenID identity provider with the given ID using the identity provider configuration in the request body. This function implements the API call via `PATCH`.

  Note: > When using the PATCH method, use the same request body documentation that is provided for the PUT request. The PATCH method will merge the provided request parameters into the existing object, this means all parameters are optional when using the PATCH method and you only provide the values you want changed. A null value can be used to remove a value. Patching an Array will result in all values from the new list being appended to the existing list, this is a known limitation to the current implementation of PATCH.

  For more information, visit the FusionAuth API documentation for [Update an OpenID connect identity provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#update-an-openid-connect-identity-provider)
  """
  @spec update_openid_connect_identity_provider(
          client(),
          identity_provider(),
          identity_provider_id()
        ) :: result()
  def update_openid_connect_identity_provider(client, identity_provider, identity_provider_id) do
    Tesla.patch(client, @connect_url <> "/#{identity_provider_id}", identity_provider)
    |> FusionAuth.result()
  end

  @doc """
  Deletes an OpenID identity provider with the given identity provider ID

  For more information, visit the FusionAuth API documentation for [Delete an OpenID connect identity provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#delete-an-openid-connect-identity-provider)
  """
  @spec delete_openid_connect_identity_provider(client(), identity_provider_id()) :: result()
  def delete_openid_connect_identity_provider(client, identity_provider_id) do
    Tesla.delete(client, @connect_url <> "/#{identity_provider_id}")
    |> FusionAuth.result()
  end

  @doc """
  Completes an OpenID connect login using a login request, this function allows for optional headers to be passed. *Must* at least contain the following values
  - applicationId :: String.t()\n
    The Id of the Application the user is to be logged into.

  - data
    - code :: String.t()\n
    The `code` parameter that was returned to the Authorization redirect URI.

    -redirect_uri :: String.t()\n
    The redirect URI that was provided to the OpenID Connect Authorization endpoint

  - identityProviderId :: String.t()\n
    The Id of the identity provider to process this login request.

  For more information, visit the FusionAuth API documentation for [Complete an OpenID connect login](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#complete-an-openid-connect-login)
  """
  @spec complete_openid_connect_login(client(), login_request_body()) :: result()
  def complete_openid_connect_login(client, login_request_body) do
    Tesla.post(client, @connect_url <> "/login", login_request_body)
    |> FusionAuth.result()
  end

  @doc """
  Completes an OpenID connect login using a login request, this function allows for optional headers to be passed. *Must* at least contain the following values
  - applicationId :: String.t()\n
    The Id of the Application the user is to be logged into.

  - data
    - code :: String.t()\n
    The `code` parameter that was returned to the Authorization redirect URI.

    -redirect_uri :: String.t()\n
    The redirect URI that was provided to the OpenID Connect Authorization endpoint

  - identityProviderId :: String.t()\n
    The Id of the identity provider to process this login request.

  - headers :: list()\n
    list of headers in the form of tuples

  - header :: tuple()\n
    header in the form of {"header-name", "header-value"}

  Headers available\n
    - `X-Forwarded-For`
      The IP address of a client requesting authentication. If the IP address is provided it will be
      stored in the user’s login record. It is generally preferred to specify the IP address in the
      request body. If it is not provided in the request body this header value will be used if available.
      However, the request body value takes precedence.
    - `X-FusionAuth-TenantId`
      The unique Id of the tenant used to scope this API request.

  For more information, visit the FusionAuth API documentation for [Complete an OpenID connect login](https://fusionauth.io/docs/v1/tech/apis/identity-providers/openid-connect#complete-an-openid-connect-login)
  """
  @spec complete_openid_connect_login(client(), login_request_body(), headers()) :: result()
  def complete_openid_connect_login(client, login_request_body, headers) do
    Tesla.post(client, @connect_url <> "/login", login_request_body, headers: headers)
    |> FusionAuth.result()
  end
end
