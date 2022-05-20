defmodule FusionAuth.ApplicationsTest do
  use FusionAuth.DataCase

  alias FusionAuth.Applications
  alias FusionAuth.TestUtilities

  @invalid_application_id "32c54ee1-3d5a-4085-9ec5-4731d9e0f752"
  @valid_role_id "8bd3db07-8d98-455a-bd86-b802263114b1"
  @invalid_role_id "67890"

  @role %{
    "id" => @valid_role_id,
    "description" => "Test role description.",
    "name" => "Test Role",
    "is_default" => true,
    "is_super_role" => true
  }

  @application %{
    "active" => true,
    "name" => "Test Application",
    "roles" => [@role],
    "is_super_role" => true
  }

  @application_2 %{
    "active" => true,
    "name" => "Second Test Application"
  }

  setup do
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    {:ok, %{client: client_with_tenant}}
  end

  describe "Create Application" do
    test "create_application/2 returns the newly created application", %{client: client} do
      {:ok, created_app, _} = Applications.create_application(client, @application)
      assert created_app["application"]["name"] == @application["name"]
    end

    test "create_application/2 returns a 400 status code if the request to create an application was invalid and/or malformed",
         %{client: client} do
      application = %{}

      response_body = %{
        "fieldErrors" => %{
          "application.name" => [
            %{
              "code" => "[blank]application.name",
              "message" => "You must specify the [application.name] property."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Applications.create_application(client, application)
    end
  end

  describe "List Applications" do
    test "list_applications/2 returns a 200 status code with a list of active applications", %{
      client: client
    } do
      {:ok, application_1, _} = Applications.create_application(client, @application)

      {:ok, application_2, _} = Applications.create_application(client, @application_2)

      {:ok, retrieved_applications, _} = Applications.list_applications(client, active: true)

      created_ids = [application_2["application"]["id"], application_1["application"]["id"]]

      retrieved_ids =
        Enum.map(retrieved_applications["applications"], fn application ->
          application["id"]
        end)

      assert created_ids == retrieved_ids
    end

    test "list_applications/2 returns a 200 status code with a list of inactive applications when inactive is true",
         %{client: client} do
      application = Map.put(@application, "active", false)
      application_2 = Map.put(@application_2, "active", false)

      {:ok, created_application_1, _} = Applications.create_application(client, application)

      {:ok, created_application_2, _} = Applications.create_application(client, application_2)

      {:ok, retrieved_applications, _} = Applications.list_applications(client, active: false)

      created_ids = [
        created_application_2["application"]["id"],
        created_application_1["application"]["id"]
      ]

      retrieved_ids =
        Enum.map(retrieved_applications["applications"], fn application ->
          application["id"]
        end)

      assert created_ids == retrieved_ids
    end
  end

  describe "Get Application" do
    test "get_application/2 returns a 200 status code with the application based on the ID", %{
      client: client
    } do
      {:ok, created_application, _} = Applications.create_application(client, @application)
      created_id = created_application["application"]["id"]

      {:ok, retrieved_application, _} = Applications.get_application(client, created_id)
      retrieved_id = retrieved_application["application"]["id"]

      assert created_id == retrieved_id
    end

    test "get_application/2 returns a 404 status code if the application is not found", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.get_application(client, @invalid_application_id)
    end
  end

  describe "Get OAuth Configuration" do
    test "get_oauth_configuration/2 returns a 200 status code with oauth configs for the ID passed",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      created_id = application["application"]["id"]
      created_oauth_config_id = application["application"]["oauthConfiguration"]["id"]

      {:ok, retrieved_oauth_config, _} = Applications.get_oauth_configuration(client, created_id)
      retrieved_oauth_config_id = retrieved_oauth_config["oauthConfiguration"]["id"]

      assert created_oauth_config_id == retrieved_oauth_config_id
    end

    test "get_oauth_configuration/2 returns a 404 status code if application is not found",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.get_oauth_configuration(client, @invalid_application_id)
    end
  end

  describe "Update Application" do
    test "update_application/3 returns a 200 status code with the updated application", %{
      client: client
    } do
      {:ok, initial_application, _} = Applications.create_application(client, @application)
      initial_application_id = initial_application["application"]["id"]

      new_application_name = "Updated Test Application"
      updated_application = Map.put(@application, "name", new_application_name)

      {:ok, updated_application, _} =
        Applications.update_application(client, initial_application_id, updated_application)

      updated_application_id = updated_application["application"]["id"]
      updated_application_name = updated_application["application"]["name"]

      assert initial_application_id == updated_application_id
      assert new_application_name == updated_application_name
    end

    test "update_application/3 returns a 400 status code if the request to update an application was invalid and/or malformed",
         %{client: client} do
      response_body = %{
        "fieldErrors" => %{
          "application.name" => [
            %{
              "code" => "[blank]application.name",
              "message" => "You must specify the [application.name] property."
            }
          ]
        }
      }

      {:ok, initial_application, _} = Applications.create_application(client, @application)
      initial_application_id = initial_application["application"]["id"]

      new_application_name = ""
      updated_application = Map.put(@application, "name", new_application_name)

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Applications.update_application(
                 client,
                 initial_application_id,
                 updated_application
               )
    end

    test "update_application/3 returns a 404 status code if the application is not found",
         %{client: client} do
      updated_application = Map.put(@application, "name", "Updated Test Application")

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.update_application(
                 client,
                 @invalid_application_id,
                 updated_application
               )
    end
  end

  describe "Reactivate Application" do
    test "reactivate_application/2 returns a 200 status code with the reactivated application", %{
      client: client
    } do
      application = Map.put(@application, "active", false)

      {:ok, created_application, _} = Applications.create_application(client, application)
      created_application_id = created_application["application"]["id"]

      {:ok, activated_application, _} =
        Applications.reactivate_application(client, created_application_id)

      assert activated_application["application"]["active"] == true
    end

    test "reactivate_application/2 returns a 404 status code if the application is not found",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.reactivate_application(client, @invalid_application_id)
    end
  end

  describe "Delete Application" do
    test "delete_application/3 returns a 200 status code with an empty body if the deactivate request is successful",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_application(client, application_id)
    end

    test "delete_application/3 returns a 200 status code with an empty body if a hard delete request is successful",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_application(client, application_id, hardDelete: true)
    end

    test "delete_application/3 returns a 404 status code if the application is not found",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_application(client, @invalid_application_id)
    end
  end

  describe "Create Role" do
    test "create_role/3 returns the newly created role", %{client: client} do
      role_name = "new role name"
      new_role = Map.put(@role, "name", role_name)

      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      {:ok, created_role, _} = Applications.create_role(client, application_id, new_role)

      assert role_name == created_role["role"]["name"]
    end

    test "create_role/3 returns a 400 status code if the request to create a role was invalid and/or malformed",
         %{client: client} do
      role = %{}

      response_body = %{
        "fieldErrors" => %{
          "role.name" => [
            %{
              "code" => "[blank]role.name",
              "message" => "You must specify the [role.name] property."
            }
          ]
        }
      }

      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Applications.create_role(client, application_id, role)
    end

    test "create_role/3 returns a 400 status code if the application is not found",
         %{client: client} do
      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [
            %{
              "code" => "[invalid]applicationId",
              "message" =>
                "Invalid [applicationId] on the URL. No Application exists for Id [#{@invalid_application_id}]."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Applications.create_role(client, @invalid_application_id, @role)
    end
  end

  describe "Update Role" do
    test "update_role/4 returns a 200 status code with the updated role", %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      new_role_description = "hello this is an updated role description"
      role = Map.put(@role, "description", new_role_description)
      role_id = role["id"]

      {:ok, updated_role, _} = Applications.update_role(client, application_id, role_id, role)

      assert new_role_description == updated_role["role"]["description"]
    end

    test "update_role/4 returns a 400 status code if the request to update a role was invalid and/or malformed",
         %{client: client} do
      updated_role = %{isSuperRole: "bogus"}

      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]
      role_id = Enum.at(application["application"]["roles"], 0)["id"]

      response_body = %{
        "fieldErrors" => %{
          "role.isSuperRole" => [
            %{
              "code" => "[invalidJSON]",
              "message" =>
                "Invalid JSON in the request body. The property was [role.isSuperRole]. The error was [Possible conversion error]. The detailed exception was [Cannot deserialize value of type `boolean` from String \"bogus\": only \"true\"/\"True\"/\"TRUE\" or \"false\"/\"False\"/\"FALSE\" recognized\n at [Source: (org.apache.catalina.connector.CoyoteInputStream); line: 1, column: 24] (through reference chain: io.fusionauth.domain.api.ApplicationRequest[\"role\"]->io.fusionauth.domain.ApplicationRole[\"isSuperRole\"])]."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Applications.update_role(
                 client,
                 application_id,
                 role_id,
                 updated_role
               )
    end

    test "udpate_role/4 returns a 400 status code if the application is not found",
         %{client: client} do
      updated_role = %{isSuperRole: false}

      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [
            %{
              "code" => "[invalid]applicationId",
              "message" =>
                "Invalid [applicationId] on the URL. No Application exists for Id [32c54ee1-3d5a-4085-9ec5-4731d9e0f752]."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Applications.update_role(
                 client,
                 @invalid_application_id,
                 @valid_role_id,
                 updated_role
               )
    end

    test "udpate_role/4 returns a 404 status code if the role is not found",
         %{client: client} do
      updated_role = %{name: "Updated Test Role"}

      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.update_role(
                 client,
                 application_id,
                 @invalid_role_id,
                 updated_role
               )
    end
  end

  describe "Delete Role by ID" do
    test "delete_role_by_id/3 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]
      role_id = Enum.at(application["application"]["roles"], 0)["id"]

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_role_by_id(client, application_id, role_id)
    end

    test "delete_role_by_id/3 returns a 404 status code if the application is not found",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_role_by_id(client, @invalid_application_id, @valid_role_id)
    end

    test "delete_role_by_id/3 returns a 404 status code if the role is not found",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_role_by_id(client, application_id, @invalid_role_id)
    end
  end

  describe "Delete Role by Name" do
    test "delete_role_by_name/3 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]
      role_name = Enum.at(application["application"]["roles"], 0)["name"]

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_role_by_name(client, application_id, role_name)
    end

    test "delete_role_by_name/3 returns a 404 status code if the application is not found",
         %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_role_by_name(client, @invalid_application_id, "Role name")
    end

    test "delete_role_by_name/3 returns a 404 status code if the role is not found by name",
         %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_role_by_name(client, application_id, "unused role name")
    end
  end
end
