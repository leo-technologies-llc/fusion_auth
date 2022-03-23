defmodule FusionAuth.OpenIdConnectTest do
  use ExUnit.Case

  alias FusionAuth.OpenIdConnect
  alias FusionAuth.Helpers.Mock

  @connect_url "/api/identity-provider"
  @invalid_id "123"
  @duplicate_name_error %{
    "fieldErrors" => %{
        "identityProvider.name" => %{
          "code" => "[duplicate]identityProvider.name",
          "message" => "An Identity Provider with name App [Production] - <Location> - Azure AD already exists."
        }
    }
  }
  @duplicate_id_error %{
    "fieldErrors" => %{
        "identityProviderId" => %{
          "code" => "[duplicate]identityProviderId",
          "message" => "An Identity Provider with Id [646a7418-0686-4f7e-80e0-e9d4ce62425c] already exists."
        }
    }
  }
  @duplicate_domain_error %{
    "fieldErrors" => %{
        "identityProvider.domains" => %{
          "code" => "[duplicate]identityProvider.domains",
          "message" => "Invalid value for property [identityProvider.domains]. The following domain(s) [2qcx2y.onmicrosoft.com] are currently managed by another Identity Provider. A domain may only be managed by a single Identity Provider."
        }
    }
  }
  @oauth2 %{
      "authorization_endpoint" => "https://login.microsoftonline.com/5ce44ebe-8c6f-4b00-a27e-d5c6965b605b/oauth2/v2.0/authorize?client_id=584a838e-777c-4593-889b-41751509f907&redirect_uri=https%3A%2F%2Ffusionauth.io%2Foauth2%2Fcallback&response_type=code&scope=openid&state=Y2xpZW50X2lkPTNjMjE5ZTU4LWVkMGUtNGIxOC1hZDQ4LWY0ZjkyNzkzYWUzMiZjb2RlX2NoYWxsZW5nZT0mY29kZV9jaGFsbGVuZ2VfbWV0aG9kPSZtZXRhRGF0YS5kZXZpY2UubmFtZT1tYWNPUyUyMENocm9tZSZtZXRhRGF0YS5kZXZpY2UudHlwZT1CUk9XU0VSJm5vbmNlPSZyZWRpcmVjdF91cmk9JTJGbG9naW4mcmVzcG9uc2VfbW9kZT0mcmVzcG9uc2VfdHlwZT1jb2RlJnNjb3BlPW9mZmxpbmVfYWNjZXNzJnN0YXRlPXBmci1Xc2VRUVRPcS1hNmx3LXc0WEpSRnN2ZVd0NUNKSU95RUNIVjNrSjQmdGVuYW50SWQ9ZmZmNGVkY2MtYjVkNC0wNjBjLTU2OGMtOTA5NmFiOGE3N2M2JnRpbWV6b25lPUFtZXJpY2ElMkZMb3NfQW5nZWxlcyZ1c2VyX2NvZGU9JmlkZW50aXR5UHJvdmlkZXJJZD1lZThkZWI2Ni0yZjdmLTRmMmEtOTgxNi0yNGM1ZGEwMjA2NzY",
      "clientAuthenticationMethod" => "client_secret_basic",
      "client_id" => "584a838e-777c-4593-889b-41751509f907",
      "client_secret" => "<client secret>",
      "emailClaim" => "email",
      "scope" => "openid",
      "token_endpoint" => "https://login.microsoftonline.com/5ce44ebe-8c6f-4b00-a27e-d5c6965b605b/oauth2/v2.0/token",
      "userinfo_endpoint" => "https://graph.microsoft.com/oidc/userinfo"
  }
  @all_identity_providers %{
      "applicationConfiguration" => %{
        "417087a2-c396-4c6a-987c-78e65345aa20" => %{
          "createRegistration" => false,
          "enabled" => false,
          "oauth2" => %{}
        },
        "7f37d9dd-6176-404d-b2dc-7c0d958ffa14" => %{
          "createRegistration" => false,
          "enabled" => false,
          "oauth2" => %{}
        }
      },
      "buttonImageURL" => "https://swimburger.net/media/0zcpmk1b/azure.jpg",
      "buttonText" => "<location> AD",
      "debug" => true,
      "domains" => [
        "<website>.com"
      ],
      "enabled" => true,
      "id" => "2b44ab5c-2035-4db3-85f5-a5100589204e",
      "insertInstant" => 1646687339331,
      "lambdaConfiguration" => %{
        "reconcileId" => "2f3ab35f-267e-417f-948c-4091aac11ba7"
      },
      "lastUpdateInstant" => 1646937984225,
      "name" => "App [Production] - <Location> - Azure AD",
      "oauth2" => @oauth2,
      "type" => "OpenIDConnect"
  }
  @identity_provider %{
    "applicationIds" => ["38e4bd66-6378-460d-b7ac-ce43def5cac3"],
    "id" => "2b44ab5c-2035-4db3-85f5-a5100589204e",
    "name" => "App [Production] - <Location> - Azure AD",
    "oauth2" => @oauth2,
    "type" => "OpenIDConnect"
  }
  @login_request_body %{
    "applicationId" => "10000000-0000-0002-0000-000000000001",
    "data" => %{
      "code" => "1179659262-VUvqmPjPcGC9BxwHdVxMGs0ka5Gmz91G0svPp2Z",
      "redirect_uri" => "https://login.piedpiper.com/oauth2/callback"
    },
    "identityProviderId" => "19544aa2-d634-4859-b193-e57af82b5d12",
    "ipAddress" => "192.168.1.42"
  }
  @login_response_body %{
    "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo",
    "user" => %{
      "active" => true,
      "birthDate" => "1976-05-30",
      "connectorId" => "e3306678-a53a-4964-9040-1c96f36dda72",
      "data" => %{
        "displayName" => "Johnny Boy",
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
      "middleName" => "William",
      "mobilePhone" => "303-555-1234",
      "passwordChangeRequired" => false,
      "passwordLastUpdateInstant" => 1471786483322,
      "preferredLanguages" => [
        "en",
        "fr"
      ],
      "registrations" => %{
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
          "username" => "johnny123",
          "usernameStatus" => "ACTIVE"
      },
      "timezone" => "America/Denver",
      "tenantId" => "f24aca2b-ce4a-4dad-951a-c9d690e71415",
      "twoFactorEnabled" => false,
      "usernameStatus" => "ACTIVE",
      "username" => "johnny123",
      "verified" => true
    }
  }
  @headers [{"X-Forwarded-For", "127.0.0.1"}, {"X-FusionAuth-TenantId", "04676cf1-c6d1-49db-8087-75831359fcbd"}]
  @two_factor_enabled_response %{
    "methods" => [
      %{
        "authenticator" => %{
          "algorithm" => "HmacSHA1",
          "codeLength" => 6,
          "timeStep" => 30
        },
        "id" => "2KSZ",
        "method" => "authenticator"
      },
      %{
        "email" => "richard@fusionauth.io",
        "id" => "KLRT",
        "method" => "email"
      }
    ],
    "twoFactorId" => "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
  }
  @change_password_response %{
    "changePasswordId" => "XOgai4Ro68xfGiex0ngXiJ2bbhduM4Pm7h3lvF0xibQ",
    "changePasswordReason" => "Expired"
  }
  @login_prevented_response %{
    "actions" => %{
      "actionId" => "00000000-0000-0000-0000-000000000042",
      "actionerUserId" => "00000000-0000-0001-0000-000000000000",
      "expiry" => 1571786483322,
      "localizedName" => "Prevent Login Action",
      "localizedReason" => "Hard Lock",
      "name" => "Prevent Login Action",
      "reason" => "Hard Lock",
      "reasonCode" => "hard_lock"
    }
  }


  setup do
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    client = FusionAuth.client(Mock.base_url(), api_key, "")
    {:ok, %{client: client}}
  end

  describe "Retrieve all identity providers" do
    test "retrieve_all_identity_providers/1 returns a json containing the identity providers",
        %{client: client} do

      Mock.mock_request(
        path: @connect_url,
        method: :get,
        status: 200,
        response_body:  %{"all_identity_providers" => @all_identity_providers}
      )

      assert {:ok,  %{"all_identity_providers" => all_identity_providers}, %Tesla.Env{status: 200}} =
                OpenIdConnect.retrieve_all_identity_providers(client)
      assert all_identity_providers == @all_identity_providers
    end
  end

  describe "Lookup specific identity provider with given domain" do
    test "lookup_identity_providers/2 returns a json containing an identity provider",
      %{client: client} do
      domain = "domain.com"
      Mock.mock_request(
        path: @connect_url <> "/lookup?domain=#{domain}",
        method: :get,
        status: 200,
        response_body: %{"identity_provider" => @identity_provider}
      )

      assert {:ok, %{"identity_provider" => @identity_provider}, %Tesla.Env{status: 200}} =
                OpenIdConnect.lookup_identity_provider(client, domain)
    end

    test "lookup_identity_providers/2 with an invalid domain returns a 404 status code",
      %{client: client} do
      Mock.mock_request(
        path: @connect_url <> "/lookup?domain=12345",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404, body: ""}} =
                OpenIdConnect.lookup_identity_provider(client, "12345")
    end
  end

  describe "create_openid_connect_identity_provider/2" do
    test "creates an identity provider without a uuid",
      %{client: client} do
      request_body = Map.delete(@identity_provider, "id")
      Mock.mock_request(
        path: @connect_url,
        method: :post,
        status: 200,
        body: request_body,
        response_body: %{"identity_provider" => @identity_provider}
      )

      assert {:ok, %{"identity_provider" => @identity_provider}, %Tesla.Env{status: 200}} =
        OpenIdConnect.create_openid_connect_identity_provider(client, request_body)
    end


    test "create_openid_connect_identity_provider/2 uses an identity provier name already in use",
      %{client: client} do
      request_body = Map.delete(@identity_provider, "id")
      Mock.mock_request(
        path: @connect_url,
        method: :post,
        status: 400,
        body: request_body,
        response_body: @duplicate_name_error
      )

      assert {:error, @duplicate_name_error, %Tesla.Env{status: 400}} =
        OpenIdConnect.create_openid_connect_identity_provider(client, request_body)
    end
  end

  describe "create_openid_connect_identity_provider_uuid/3" do
    test "creates an identity provider with a uuid",
      %{client: client} do
      new_identity_provider_id = @identity_provider["id"]
      request_body = Map.delete(@identity_provider, "id")
      Mock.mock_request(
        path: @connect_url <> "/#{new_identity_provider_id}",
        method: :post,
        status: 200,
        body: request_body,
        response_body: %{"identity_provider" => @identity_provider}
      )

      assert {:ok, %{"identity_provider" => @identity_provider}, %Tesla.Env{status: 200}} =
        OpenIdConnect.create_openid_connect_identity_provider_uuid(client, request_body, new_identity_provider_id)
    end

    test "creates an identity provider with a bad uuid",
      %{client: client} do
      new_identity_provider_id = @identity_provider["id"]
      request_body = Map.delete(@identity_provider, "id")
      Mock.mock_request(
        path: @connect_url <> "/#{new_identity_provider_id}",
        method: :post,
        status: 400,
        body: request_body,
        response_body: @duplicate_id_error
      )

      assert {:error, @duplicate_id_error, %Tesla.Env{status: 400}} =
        OpenIdConnect.create_openid_connect_identity_provider_uuid(client, request_body, new_identity_provider_id)
    end
  end

  describe "retrieve_openid_connect_identity_provider/2" do
    test "retrieves an identity provider",
      %{client: client} do
      identity_provider_id = @identity_provider["id"]
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :get,
        status: 200,
        response_body: %{"identity_provider" => @identity_provider}
      )

      assert {:ok, %{"identity_provider" => @identity_provider}, %Tesla.Env{status: 200}} =
        OpenIdConnect.retrieve_openid_connect_identity_provider(client, identity_provider_id)
    end

    test "retrieve_openid_connect_identity_provider/2 with an invalid provider ID returns a 404 status code",
      %{client: client} do
      identity_provider_id = @invalid_id
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
        OpenIdConnect.retrieve_openid_connect_identity_provider(client, identity_provider_id)
    end
  end

  describe "update_openid_connect_identity_provider/3" do
    test "updates an openid identity provider",
      %{client: client} do
      identity_provider_id = @identity_provider["id"]
      request_body = @identity_provider
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :patch,
        status: 200,
        body: request_body,
        response_body: %{"identity_provider" => @identity_provider}
      )

      assert {:ok, %{"identity_provider" => @identity_provider}, %Tesla.Env{status: 200}} =
        OpenIdConnect.update_openid_connect_identity_provider(client, request_body, identity_provider_id)
    end

    test "update_openid_connect_identity_provider/3 uses a domain already managed by another provider",
      %{client: client} do
      identity_provider_id = @identity_provider["id"]
      request_body = @identity_provider
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :patch,
        status: 400,
        body: request_body,
        response_body: @duplicate_domain_error
      )

      assert {:error, @duplicate_domain_error, %Tesla.Env{status: 400}} =
        OpenIdConnect.update_openid_connect_identity_provider(client, request_body, identity_provider_id)
    end

    test "update_openid_connect_identity_provider/3 with an invalid provider ID returns a 404 status code",
      %{client: client} do
      identity_provider_id = @invalid_id
      request_body = @identity_provider
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :patch,
        status: 404,
        body: request_body,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
        OpenIdConnect.update_openid_connect_identity_provider(client, request_body, identity_provider_id)
    end

  end

  describe "delete_openid_connect_identity_provider/2" do
    test "deletes an identity provider",
      %{client: client} do
      identity_provider_id = @identity_provider["id"]
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
        OpenIdConnect.delete_openid_connect_identity_provider(client, identity_provider_id)
    end

    test "delete_openid_connect_identity_provider/2 with an invalid provider ID returns a 404 status code",
      %{client: client} do
      identity_provider_id = @identity_provider["id"]
      Mock.mock_request(
        path: @connect_url <> "/#{identity_provider_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
        OpenIdConnect.delete_openid_connect_identity_provider(client, identity_provider_id)
    end
  end

  describe "complete_openid_connect_login/3" do
    test "completes an openid connect login",
      %{client: client} do
      Mock.mock_request(
        path: @connect_url <> "/login",
        method: :post,
        status: 200,
        body: @login_request_body,
        response_body: @login_response_body
      )

      assert {:ok, @login_response_body, %Tesla.Env{status: 200}} =
        OpenIdConnect.complete_openid_connect_login(client, @login_response_body)
    end

    test "completes an openid connect login with headers",
      %{client: client} do
      Mock.mock_request(
        path: @connect_url <> "/login",
        method: :post,
        status: 200,
        headers: @headers,
        body: @login_request_body,
        response_body: @login_response_body
      )

      assert {:ok, @login_response_body, %Tesla.Env{status: 200}} =
        OpenIdConnect.complete_openid_connect_login(client, @login_response_body, @headers)
    end

    test "completes an openid connect login where the user is required to change their password, returns a 203 status code",
      %{client: client} do
      response_body = Map.merge(@login_response_body, @change_password_response)
      Mock.mock_request(
        path: @connect_url <> "/login",
        method: :post,
        status: 203,
        headers: @headers,
        body: @login_request_body,
        response_body: response_body
      )

      assert {:ok, ^response_body, %Tesla.Env{status: 203}} =
        OpenIdConnect.complete_openid_connect_login(client, response_body, @headers)
    end

    test "completes an openid connect login where the user is required to change their password, returns a 242 status code",
      %{client: client} do
      response_body = Map.merge(@login_response_body, @two_factor_enabled_response)
      Mock.mock_request(
        path: @connect_url <> "/login",
        method: :post,
        status: 242,
        headers: @headers,
        body: @login_request_body,
        response_body: response_body
      )

      assert {:ok, ^response_body, %Tesla.Env{status: 242}} =
        OpenIdConnect.complete_openid_connect_login(client, response_body, @headers)
    end

    test "attempts to login, but the request is prevented due to actions preventing a login, returns a 409 status code",
      %{client: client} do
      response_body = @login_prevented_response
      Mock.mock_request(
        path: @connect_url <> "/login",
        method: :post,
        status: 409,
        headers: @headers,
        body: @login_request_body,
        response_body: response_body
      )

      assert {:error, ^response_body, %Tesla.Env{status: 409}} =
        OpenIdConnect.complete_openid_connect_login(client, response_body, @headers)
    end


  end




end
