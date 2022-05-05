defmodule FusionAuth.OpenIdConnectTest do
  use ExUnit.Case

  alias FusionAuth.OpenIdConnect
  alias FusionAuth.TestUtilities

  @application_id "3b0654ca-6870-4bf0-a0ce-2507c42d9998"
  @connect_url "/api/identity-provider"
  @invalid_id "123"
  @identity_provider_id "320a5cea-6893-42fe-9fba-bd31258a1a27"
  @identity_provider_2_id "32b0a4ed-fe19-4054-b598-3eebe8b1861c"
  @duplicate_name_error %{
    "fieldErrors" => %{
      "identityProvider.name" => [
        %{
          "code" => "[duplicate]identityProvider.name",
          "message" =>
            "An Identity Provider with name [App[Dev] Identity Provider] already exists."
        }
      ]
    }
  }
  @duplicate_id_error %{
    "fieldErrors" => %{
      "identityProviderId" => [
        %{
          "code" => "[duplicate]identityProviderId",
          "message" =>
            "An Identity Provider with Id [320a5cea-6893-42fe-9fba-bd31258a1a27] already exists."
        }
      ]
    }
  }
  @duplicate_domain_error %{
    "fieldErrors" => %{
      "identityProvider.domains" => [
        %{
          "code" => "[duplicate]identityProvider.domains",
          "message" =>
            "Invalid value for property [identityProvider.domains]. The following domain(s) [domain.com] are currently managed by another Identity Provider. A domain may only be managed by a single Identity Provider."
        }
      ]
    }
  }
  @identity_provider %{
    "identityProvider" => %{
      "applicationConfiguration" => %{
        @application_id => %{
          "createRegistration" => true,
          "enabled" => true
        }
      },
      "domains" => ["domain.com"],
      "buttonText" => "test button text",
      "name" => "App[Dev] Identity Provider",
      "debug" => true,
      "enabled" => true,
      "oauth2" => %{
        "client_id" => "af9e0996-48aa-4be3-b2b0-3ee181da2fc2",
        "client_secret" => "Yj!~0jE;BoSWN2N&?sKz@eO(&$K3D",
        "authorization_endpoint" =>
          "https://login.microsoftonline.com/d3ef38df-f3df-4231-911b-9cb4039929e2/oauth2/v2.0/authorize",
        "token_endpoint" =>
          "https://login.microsoftonline.com/d3ef38df-f3df-4231-911b-9cb4039929e2/oauth2/v2.0/token",
        "userinfo_endpoint" => "https://graph.microsoft.com/oidc/userinfo",
        "scope" => "openid email profile"
      },
      "type" => "OpenIDConnect"
    }
  }
  @identity_provider_2 %{
    "identityProvider" => %{
      "domains" => ["second_domain.com"],
      "buttonText" => "test button text",
      "name" => "App[Dev] Second Identity Provider",
      "debug" => true,
      "enabled" => true,
      "oauth2" => %{
        "client_id" => "af9e0996-48aa-4be3-b2b0-3ee181da2fc2",
        "client_secret" => "Yj!~0jE;BoSWN2N&?sKz@e1(&$K3D",
        "authorization_endpoint" =>
          "https://login.microsoftonline.com/d3ef38df-f3df-4231-911b-9cb4039929e2/oauth2/v2.0/authorize",
        "token_endpoint" =>
          "https://login.microsoftonline.com/d3ef38df-f3df-4231-911b-9cb4039929e2/oauth2/v2.0/token",
        "userinfo_endpoint" => "https://graph.microsoft.com/oidc/userinfo",
        "scope" => "openid email profile"
      },
      "type" => "OpenIDConnect"
    }
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
    "token" =>
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo",
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
      "expiry" => 1_571_786_483_322,
      "firstName" => "John",
      "fullName" => "John Doe",
      "id" => "00000000-0000-0001-0000-000000000000",
      "imageUrl" => "http://65.media.tumblr.com/tumblr_l7dbl0MHbU1qz50x3o1_500.png",
      "lastLoginInstant" => 1_471_786_483_322,
      "lastName" => "Doe",
      "middleName" => "William",
      "mobilePhone" => "303-555-1234",
      "passwordChangeRequired" => false,
      "passwordLastUpdateInstant" => 1_471_786_483_322,
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
        "insertInstant" => 1_446_064_706_250,
        "lastLoginInstant" => 1_456_064_601_291,
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
  @headers [
    {"X-Forwarded-For", "127.0.0.1"},
    {"X-FusionAuth-TenantId", "04676cf1-c6d1-49db-8087-75831359fcbd"}
  ]
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
      "expiry" => 1_571_786_483_322,
      "localizedName" => "Prevent Login Action",
      "localizedReason" => "Hard Lock",
      "name" => "Prevent Login Action",
      "reason" => "Hard Lock",
      "reasonCode" => "hard_lock"
    }
  }

  setup do
    fa_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(fa_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(fa_url, api_key, tenant_id)

    TestUtilities.create_application(client_with_tenant, @application_id)

    on_exit(fn ->
      cleanup_identity_providers(client)
      TestUtilities.cleanup_tenant(client, tenant_id)
    end)

    {:ok, %{client: client}}
  end

  describe "Retrieve all identity providers" do
    test "retrieve_all_identity_providers/1 returns a json containing the identity providers",
         %{client: client} do
      {:ok, provider_1, _} =
        OpenIdConnect.create_openid_connect_identity_provider(client, @identity_provider)

      {:ok, provider_2, _} =
        OpenIdConnect.create_openid_connect_identity_provider(client, @identity_provider_2)

      {:ok, retrieved_providers, _} = OpenIdConnect.retrieve_all_identity_providers(client)

      created_ids = [provider_2["identityProvider"]["id"], provider_1["identityProvider"]["id"]]

      retrieved_ids =
        Enum.map(retrieved_providers["identityProviders"], fn provider ->
          provider["id"]
        end)

      assert created_ids == retrieved_ids
    end
  end

  describe "Lookup specific identity provider with given domain" do
    test "lookup_identity_providers/2 returns a json containing an identity provider",
         %{client: client} do
      {:ok, provider, _} =
        OpenIdConnect.create_openid_connect_identity_provider(
          client,
          @identity_provider
        )

      # Sleeping for 5ms to allow ES index
      Process.sleep(5)

      {:ok, lookup_result, _} = OpenIdConnect.lookup_identity_provider(client, "domain.com")

      created_id = provider["identityProvider"]["id"]
      lookup_id = lookup_result["identityProvider"]["id"]

      assert created_id == lookup_id
    end

    test "lookup_identity_providers/2 with an unused domain returns a 404 status code",
         %{client: client} do
      assert {:error, _, %Tesla.Env{status: 404}} =
               OpenIdConnect.lookup_identity_provider(client, "12345")
    end
  end

  describe "create_openid_connect_identity_provider/2" do
    test "creates an identity provider without a uuid",
         %{client: client} do
      {:ok, provider, _} =
        OpenIdConnect.create_openid_connect_identity_provider(
          client,
          @identity_provider
        )

      created_provider_name = provider["identityProvider"]["name"]

      assert created_provider_name == @identity_provider["identityProvider"]["name"]
    end

    test "create_openid_connect_identity_provider/2 uses an identity provier name already in use",
         %{client: client} do
      identity_provider = %{
        "identityProvider" => Map.delete(@identity_provider["identityProvider"], "domains")
      }

      OpenIdConnect.create_openid_connect_identity_provider(client, identity_provider)

      assert {:error, @duplicate_name_error, %Tesla.Env{status: 400}} =
               OpenIdConnect.create_openid_connect_identity_provider(client, identity_provider)
    end
  end

  describe "create_openid_connect_identity_provider_uuid/3" do
    test "creates an identity provider with a uuid",
         %{client: client} do
      assert {:ok, @identity_provider, %Tesla.Env{status: 200}} =
               OpenIdConnect.create_openid_connect_identity_provider_uuid(
                 client,
                 @identity_provider,
                 @identity_provider_id
               )
    end

    test "creates an identity provider with a bad uuid",
         %{client: client} do
      OpenIdConnect.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider,
        @identity_provider_id
      )

      new_identity_provider =
        @identity_provider["identityProvider"]
        |> Map.delete("domains")
        |> Map.put("name", "New unique name")

      assert {:error, @duplicate_id_error, %Tesla.Env{status: 400}} =
               OpenIdConnect.create_openid_connect_identity_provider_uuid(
                 client,
                 new_identity_provider,
                 @identity_provider_id
               )
    end
  end

  describe "retrieve_openid_connect_identity_provider/2" do
    test "retrieves an identity provider",
         %{client: client} do
      {:ok, created_provider, _} =
        OpenIdConnect.create_openid_connect_identity_provider_uuid(
          client,
          @identity_provider,
          @identity_provider_id
        )

      {:ok, retrieved_provider, _} =
        OpenIdConnect.retrieve_openid_connect_identity_provider(
          client,
          @identity_provider_id
        )

      assert retrieved_provider["identityProvider"]["id"] ==
               created_provider["identityProvider"]["id"]
    end

    test "retrieve_openid_connect_identity_provider/2 with an unused identity provider ID returns a 404 status code",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               OpenIdConnect.retrieve_openid_connect_identity_provider(
                 client,
                 @identity_provider_id
               )
    end
  end

  describe "update_openid_connect_identity_provider/3" do
    test "updates an openid identity provider",
         %{client: client} do
      new_identity_provider = %{
        "identityProvider" =>
          Map.put(@identity_provider["identityProvider"], "name", "New Identity Provider name")
      }

      OpenIdConnect.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider,
        @identity_provider_id
      )

      assert {:ok, new_identity_provider, %Tesla.Env{status: 200}} =
               OpenIdConnect.update_openid_connect_identity_provider(
                 client,
                 new_identity_provider,
                 @identity_provider_id
               )
    end

    test "update_openid_connect_identity_provider/3 uses a domain already managed by another provider",
         %{client: client} do
      OpenIdConnect.create_openid_connect_identity_provider(client, @identity_provider)

      OpenIdConnect.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider_2,
        @identity_provider_2_id
      )

      new_identity_provider = %{
        "identityProvider" =>
          Map.put(@identity_provider_2["identityProvider"], "domains", ["domain.com"])
      }

      assert {:error, @duplicate_domain_error, %Tesla.Env{status: 400}} =
               OpenIdConnect.update_openid_connect_identity_provider(
                 client,
                 new_identity_provider,
                 @identity_provider_2_id
               )
    end

    test "update_openid_connect_identity_provider/3 with an invalid provider ID returns a 404 status code",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               OpenIdConnect.update_openid_connect_identity_provider(
                 client,
                 @identity_provider,
                 @identity_provider_id
               )
    end
  end

  describe "delete_openid_connect_identity_provider/2" do
    test "deletes an identity provider",
         %{client: client} do
      OpenIdConnect.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider,
        @identity_provider_id
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               OpenIdConnect.delete_openid_connect_identity_provider(
                 client,
                 @identity_provider_id
               )
    end

    test "delete_openid_connect_identity_provider/2 with an invalid provider ID returns a 404 status code",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               OpenIdConnect.delete_openid_connect_identity_provider(
                 client,
                 @identity_provider_id
               )
    end
  end

  # describe "complete_openid_connect_login/3" do
  #   test "completes an openid connect login",
  #        %{client: client} do
  #     Mock.mock_request(
  #       path: @connect_url <> "/login",
  #       method: :post,
  #       status: 200,
  #       body: @login_request_body,
  #       response_body: @login_response_body
  #     )

  #     assert {:ok, @login_response_body, %Tesla.Env{status: 200}} =
  #              OpenIdConnect.complete_openid_connect_login(client, @login_response_body)
  #   end

  #   test "completes an openid connect login with headers",
  #        %{client: client} do
  #     Mock.mock_request(
  #       path: @connect_url <> "/login",
  #       method: :post,
  #       status: 200,
  #       headers: @headers,
  #       body: @login_request_body,
  #       response_body: @login_response_body
  #     )

  #     assert {:ok, @login_response_body, %Tesla.Env{status: 200}} =
  #              OpenIdConnect.complete_openid_connect_login(client, @login_response_body, @headers)
  #   end

  #   test "completes an openid connect login where the user is required to change their password, returns a 203 status code",
  #        %{client: client} do
  #     response_body = Map.merge(@login_response_body, @change_password_response)

  #     Mock.mock_request(
  #       path: @connect_url <> "/login",
  #       method: :post,
  #       status: 203,
  #       headers: @headers,
  #       body: @login_request_body,
  #       response_body: response_body
  #     )

  #     assert {:ok, ^response_body, %Tesla.Env{status: 203}} =
  #              OpenIdConnect.complete_openid_connect_login(client, response_body, @headers)
  #   end

  #   test "completes an openid connect login where the user is required to change their password, returns a 242 status code",
  #        %{client: client} do
  #     response_body = Map.merge(@login_response_body, @two_factor_enabled_response)

  #     Mock.mock_request(
  #       path: @connect_url <> "/login",
  #       method: :post,
  #       status: 242,
  #       headers: @headers,
  #       body: @login_request_body,
  #       response_body: response_body
  #     )

  #     assert {:ok, ^response_body, %Tesla.Env{status: 242}} =
  #              OpenIdConnect.complete_openid_connect_login(client, response_body, @headers)
  #   end

  #   test "attempts to login, but the request is prevented due to actions preventing a login, returns a 409 status code",
  #        %{client: client} do
  #     response_body = @login_prevented_response

  #     Mock.mock_request(
  #       path: @connect_url <> "/login",
  #       method: :post,
  #       status: 409,
  #       headers: @headers,
  #       body: @login_request_body,
  #       response_body: response_body
  #     )

  #     assert {:error, ^response_body, %Tesla.Env{status: 409}} =
  #              OpenIdConnect.complete_openid_connect_login(client, response_body, @headers)
  #   end
  # end

  defp cleanup_identity_providers(client) do
    {:ok, identity_providers, _} = OpenIdConnect.retrieve_all_identity_providers(client)

    if identity_providers != %{} do
      Enum.map(identity_providers["identityProviders"], fn provider ->
        FusionAuth.OpenIdConnect.delete_openid_connect_identity_provider(client, provider["id"])
      end)
    end
  end

  defp cleanup_tenant(client, tenant_id) do
    Tesla.delete(client, "/api/tenant/" <> tenant_id)
  end

  defp create_tenant(client, tenant_id) do
    tenant = %{
      "tenant" => %{
        "name" => "Test Tenant"
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  defp create_application(client_with_tenant, application_id) do
    application = %{
      "application" => %{
        "name" => "Test Application"
      }
    }

    Tesla.post(client_with_tenant, "/api/application/" <> application_id, application)
  end
end
