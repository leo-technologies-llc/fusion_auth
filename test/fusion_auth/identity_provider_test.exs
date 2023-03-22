defmodule FusionAuth.IdentityProviderTest do
  use FusionAuth.DataCase

  alias FusionAuth.IdentityProvider
  alias FusionAuth.TestUtilities

  @application_id "3b0654ca-6870-4bf0-a0ce-2507c42d9998"
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

  setup do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    TestUtilities.create_application_with_id(client_with_tenant, @application_id)

    {:ok, %{client: client}}
  end

  describe "Retrieve all identity providers" do
    test "retrieve_all_identity_providers/1 returns a json containing the identity providers",
         %{client: client} do
      {:ok, provider_1, _} =
        IdentityProvider.create_openid_connect_identity_provider(client, @identity_provider)

      {:ok, provider_2, _} =
        IdentityProvider.create_openid_connect_identity_provider(client, @identity_provider_2)

      {:ok, retrieved_providers, _} = IdentityProvider.retrieve_all_identity_providers(client)

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
      {:ok, _, _} =
        IdentityProvider.create_openid_connect_identity_provider(
          client,
          @identity_provider
        )

      assert TestUtilities.wait_for_process(fn ->
               {status, _, _} = IdentityProvider.lookup_identity_provider(client, "domain.com")

               if status == :ok, do: :continue, else: :wait
             end)
    end

    test "lookup_identity_providers/2 with an unused domain returns a 404 status code",
         %{client: client} do
      assert {:error, _, %Tesla.Env{status: 404}} =
               IdentityProvider.lookup_identity_provider(client, "12345")
    end
  end

  describe "create_openid_connect_identity_provider/2" do
    test "creates an identity provider without a uuid",
         %{client: client} do
      {:ok, provider, _} =
        IdentityProvider.create_openid_connect_identity_provider(
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

      IdentityProvider.create_openid_connect_identity_provider(client, identity_provider)

      assert {:error, @duplicate_name_error, %Tesla.Env{status: 400}} =
               IdentityProvider.create_openid_connect_identity_provider(client, identity_provider)
    end
  end

  describe "create_openid_connect_identity_provider_uuid/3" do
    test "creates an identity provider with a uuid",
         %{client: client} do
      assert {:ok, @identity_provider, %Tesla.Env{status: 200}} =
               IdentityProvider.create_openid_connect_identity_provider_uuid(
                 client,
                 @identity_provider,
                 @identity_provider_id
               )
    end

    test "creates an identity provider with a bad uuid",
         %{client: client} do
      IdentityProvider.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider,
        @identity_provider_id
      )

      new_identity_provider =
        @identity_provider["identityProvider"]
        |> Map.delete("domains")
        |> Map.put("name", "New unique name")

      assert {:error, @duplicate_id_error, %Tesla.Env{status: 400}} =
               IdentityProvider.create_openid_connect_identity_provider_uuid(
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
        IdentityProvider.create_openid_connect_identity_provider_uuid(
          client,
          @identity_provider,
          @identity_provider_id
        )

      {:ok, retrieved_provider, _} =
        IdentityProvider.retrieve_openid_connect_identity_provider(
          client,
          @identity_provider_id
        )

      assert retrieved_provider["identityProvider"]["id"] ==
               created_provider["identityProvider"]["id"]
    end

    test "retrieve_openid_connect_identity_provider/2 with an unused identity provider ID returns a 404 status code",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               IdentityProvider.retrieve_openid_connect_identity_provider(
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

      IdentityProvider.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider,
        @identity_provider_id
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               IdentityProvider.update_openid_connect_identity_provider(
                 client,
                 new_identity_provider,
                 @identity_provider_id
               )
    end

    test "update_openid_connect_identity_provider/3 uses a domain already managed by another provider",
         %{client: client} do
      IdentityProvider.create_openid_connect_identity_provider(client, @identity_provider)

      IdentityProvider.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider_2,
        @identity_provider_2_id
      )

      new_identity_provider = %{
        "identityProvider" =>
          Map.put(@identity_provider_2["identityProvider"], "domains", ["domain.com"])
      }

      assert {:error, @duplicate_domain_error, %Tesla.Env{status: 400}} =
               IdentityProvider.update_openid_connect_identity_provider(
                 client,
                 new_identity_provider,
                 @identity_provider_2_id
               )
    end

    test "update_openid_connect_identity_provider/3 with an invalid provider ID returns a 404 status code",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               IdentityProvider.update_openid_connect_identity_provider(
                 client,
                 @identity_provider,
                 @identity_provider_id
               )
    end
  end

  describe "delete_openid_connect_identity_provider/2" do
    test "deletes an identity provider",
         %{client: client} do
      IdentityProvider.create_openid_connect_identity_provider_uuid(
        client,
        @identity_provider,
        @identity_provider_id
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               IdentityProvider.delete_openid_connect_identity_provider(
                 client,
                 @identity_provider_id
               )
    end

    test "delete_openid_connect_identity_provider/2 with an invalid provider ID returns a 404 status code",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               IdentityProvider.delete_openid_connect_identity_provider(
                 client,
                 @identity_provider_id
               )
    end
  end
end
