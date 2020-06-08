defmodule FusionAuth.ApplicationsTest do
  use ExUnit.Case

  alias FusionAuth.Applications
  alias FusionAuth.TestSupport.Helpers

  @applications_url "/api/application"
  @valid_application_id "0dd9f903-7874-4a91-ab7d-000b8cc159eb"
  @invalid_application_id "12345"
  @valid_role_id "8bd3db07-8d98-455a-bd86-b802263114b1"
  @invalid_role_id "67890"

  setup do
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    client = FusionAuth.client(Helpers.base_url(), api_key, tenant_id)

    {:ok, %{client: client}}
  end

  describe "Create Application" do
    test "create_application/2 returns the newly created application", %{client: client} do
      application = %{name: "Test Application"}

      Helpers.mock_request(
        path: @applications_url,
        method: :post,
        status: 200,
        body: application,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.create_application(client, application)
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

      Helpers.mock_request(
        path: @applications_url,
        method: :post,
        status: 400,
        body: application,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
               Applications.create_application(client, application)
    end
  end

  describe "List Applications" do
    test "list_applications/2 returns a 200 status code with a list of active applications", %{
      client: client
    } do
      Helpers.mock_request(
        path: @applications_url,
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Applications.list_applications(client)
    end

    test "list_applications/2 returns a 200 status code with a list of inactive applications when inactive is true",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "?inactive=true",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Applications.list_applications(client, inactive: true)
    end

    test "list_applications/2 returns a 400 status code if the request was invalid and/or malformed",
         %{client: client} do
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @applications_url <> "?invalidQp=invalid",
        method: :get,
        status: 400,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
               Applications.list_applications(client, inactive: true)
    end
  end

  describe "Get Application" do
    test "get_application/2 returns a 200 status code with the application based on the ID", %{
      client: client
    } do
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.get_application(client, @valid_application_id)
    end

    test "get_application/2 returns a 404 status code if the application is not found", %{
      client: client
    } do
      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.get_application(client, @invalid_application_id)
    end
  end

  describe "Get OAuth Configuration" do
    test "get_oauth_configuration/2 returns a 200 status code with oauth configs for the ID passed",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/oauth-configuration",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.get_oauth_configuration(client, @valid_application_id)
    end

    test "get_oauth_configuration/2 returns a 500 status code if application is not found",
         %{client: client} do
      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [%{"code" => "[couldNotConvert]applicationId"}]
        },
        "generalErrors" => [
          %{
            "code" => "[Exception]",
            "message" =>
              "FusionAuth encountered an unexpected error. Please contact support for assistance."
          }
        ]
      }

      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}" <> "/oauth-configuration",
        method: :get,
        status: 500,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 500}} =
               Applications.get_oauth_configuration(client, @invalid_application_id)
    end
  end

  describe "Update Application" do
    test "update_application/3 returns a 200 status code with the updated application", %{
      client: client
    } do
      updated_application = %{name: "Updated Test Application"}

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}",
        method: :patch,
        status: 200,
        body: updated_application,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.update_application(client, @valid_application_id, updated_application)
    end

    test "update_application/3 returns a 400 status code if the request to update an application was invalid and/or malformed",
         %{client: client} do
      updated_application = %{name: ""}

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

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}",
        method: :patch,
        status: 400,
        body: updated_application,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
               Applications.update_application(client, @valid_application_id, updated_application)
    end

    test "update_application/3 returns a 404 status code if the user is not found",
         %{client: client} do
      updated_application = %{name: "Updated Test Application"}

      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}",
        method: :patch,
        status: 404,
        body: updated_application,
        response_body: ""
      )

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
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}?reactivate=true",
        method: :put,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.reactivate_application(client, @valid_application_id)
    end

    test "reactivate_application/2 returns a 404 status code if the user is not found",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}?reactivate=true",
        method: :put,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.reactivate_application(client, @invalid_application_id)
    end
  end

  describe "Delete Application" do
    test "delete_application/3 returns a 200 status code with an empty body if a deactivation request is successful",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_application(client, @valid_application_id)
    end

    test "delete_application/3 returns a 200 status code with an empty body if a hard delete request is successful",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}?hardDelete=true",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_application(client, @valid_application_id)
    end

    test "delete_application/3 returns a 404 status code if the application is not found",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}",
        method: :delete,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_application(client, @invalid_application_id)
    end
  end

  describe "Create Role" do
    test "create_role/3 returns the newly created role", %{client: client} do
      role = %{name: "Test Role"}

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role",
        method: :post,
        status: 200,
        body: role,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.create_role(client, @valid_application_id, role)
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

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role",
        method: :post,
        status: 400,
        body: role,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
               Applications.create_role(client, @valid_application_id, role)
    end

    test "create_role/3 returns a 400 status code if the application is not found",
         %{client: client} do
      role = %{name: "Test Role"}

      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [
            %{"code" => "[couldNotConvert]applicationId"},
            %{
              "code" => "[invalid]applicationId",
              "message" =>
                "Invalid [applicationId] on the URL. No Application exists for id = [null]."
            }
          ]
        }
      }

      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}" <> "/role",
        method: :post,
        status: 400,
        body: role,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
               Applications.create_role(client, @invalid_application_id, role)
    end
  end

  describe "Update Role" do
    test "update_role/4 returns a 200 status code with the updated role", %{client: client} do
      updated_role = %{name: "Updated Test Role"}

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role/#{@valid_role_id}",
        method: :patch,
        status: 200,
        body: updated_role,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Applications.update_role(
                 client,
                 @valid_application_id,
                 @valid_role_id,
                 updated_role
               )
    end

    test "update_role/4 returns a 400 status code if the request to update a role was invalid and/or malformed",
         %{client: client} do
      updated_role = %{isSuperRole: "bogus"}

      response_body = %{
        "fieldErrors" => %{
          "role.isSuperRole" => [
            %{
              "code" => "[invalidJSON]",
              "message" =>
                "Invalid JSON in the request body. The property was [role.isSuperRole]. The error was [Possible conversion error]. The detailed exception was [Cannot deserialize value of type `boolean` from String \"bogus\": only \"true\" or \"false\" recognized\n at [Source: (org.apache.catalina.connector.CoyoteInputStream); line: 1, column: 24] (through reference chain: io.fusionauth.domain.api.ApplicationRequest[\"role\"]->io.fusionauth.domain.ApplicationRole[\"isSuperRole\"])]."
            }
          ]
        }
      }

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role/#{@valid_role_id}",
        method: :patch,
        status: 400,
        body: updated_role,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
               Applications.update_role(
                 client,
                 @valid_application_id,
                 @valid_role_id,
                 updated_role
               )
    end

    test "udpate_role/4 returns a 400 status code if the application is not found",
         %{client: client} do
      updated_role = %{isSuperRole: true}

      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [
            %{"code" => "[couldNotConvert]applicationId"},
            %{
              "code" => "[invalid]applicationId",
              "message" =>
                "Invalid [applicationId] on the URL. No Application exists for id = [null]."
            }
          ]
        }
      }

      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}" <> "/role/#{@valid_role_id}",
        method: :patch,
        status: 400,
        body: updated_role,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} =
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

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role/#{@invalid_role_id}",
        method: :patch,
        status: 404,
        body: updated_role,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.update_role(
                 client,
                 @valid_application_id,
                 @invalid_role_id,
                 updated_role
               )
    end
  end

  describe "Delete Role by ID" do
    test "delete_role_by_id/3 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role/#{@valid_role_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_role_by_id(client, @valid_application_id, @valid_role_id)
    end

    test "delete_role_by_id/3 returns a 500 status code if the application is not found",
         %{client: client} do
      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [%{"code" => "[couldNotConvert]applicationId"}]
        },
        "generalErrors" => [
          %{
            "code" => "[Exception]",
            "message" =>
              "FusionAuth encountered an unexpected error. Please contact support for assistance."
          }
        ]
      }

      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}" <> "/role/#{@valid_role_id}",
        method: :delete,
        status: 500,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 500}} =
               Applications.delete_role_by_id(client, @invalid_application_id, @valid_role_id)
    end

    test "delete_role_by_id/3 returns a 404 status code if the role is not found",
         %{client: client} do
      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role/#{@invalid_role_id}",
        method: :delete,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_role_by_id(client, @valid_application_id, @invalid_role_id)
    end
  end

  describe "Delete Role by Name" do
    test "delete_role_by_name/3 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      name = "Test Role"

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role?name=#{name}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Applications.delete_role_by_name(client, @valid_application_id, name)
    end

    test "delete_role_by_name/3 returns a 500 status code if the application is not found",
         %{client: client} do
      name = "Test Role"

      response_body = %{
        "fieldErrors" => %{
          "applicationId" => [%{"code" => "[couldNotConvert]applicationId"}]
        },
        "generalErrors" => [
          %{
            "code" => "[Exception]",
            "message" =>
              "FusionAuth encountered an unexpected error. Please contact support for assistance."
          }
        ]
      }

      Helpers.mock_request(
        path: @applications_url <> "/#{@invalid_application_id}" <> "/role?name=#{name}",
        method: :delete,
        status: 500,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 500}} =
               Applications.delete_role_by_name(client, @invalid_application_id, name)
    end

    test "delete_role_by_name/3 returns a 404 status code if the role is not found by name",
         %{client: client} do
      name = "Does not exist"

      Helpers.mock_request(
        path: @applications_url <> "/#{@valid_application_id}" <> "/role?name=#{name}",
        method: :delete,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Applications.delete_role_by_name(client, @valid_application_id, name)
    end
  end
end
