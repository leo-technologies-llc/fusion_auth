defmodule FusionAuth.AuditLogsTest do
  use ExUnit.Case

  alias FusionAuth.AuditLogs
  alias FusionAuth.Helpers.Mock

  @audit_logs_url "/api/system/audit-log"

  setup do
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    client = FusionAuth.client(Mock.base_url(), api_key, tenant_id)

    {:ok, %{client: client}}
  end

  describe "Add an Entry to the Audit Log" do
    test "create_audit_log/2 returns a 200 status code with the newly created audit log", %{
      client: client
    } do
      audit_log = %{user: "john.doe@email.com", message: "This is an audit log."}

      response_body = %{
        "auditLog" => %{
          "id" => 212,
          "insertInstant" => 1_594_942_979_998,
          "insertUser" => "john.doe@email.com",
          "message" => "This is a new audit log."
        }
      }

      Mock.mock_request(
        path: @audit_logs_url,
        method: :post,
        status: 200,
        body: audit_log,
        response_body: response_body
      )

      assert {:ok, ^response_body, %Tesla.Env{status: 200}} =
               AuditLogs.create_audit_log(client, audit_log)
    end

    test "create_audit_log/2 returns a 400 status code if the request to creatre a new audit log was invalid and/or malformed",
         %{client: client} do
      audit_log = %{}

      response_body = %{
        "fieldErrors" => %{
          "auditLog.insertUser" => [
            %{
              "code" => "[blank]auditLog.insertUser",
              "message" => "You must specify the [auditLog.insertUser] property."
            }
          ],
          "auditLog.message" => [
            %{
              "code" => "[blank]auditLog.message",
              "message" => "You must specify the [auditLog.message] property."
            }
          ]
        }
      }

      Mock.mock_request(
        path: @audit_logs_url,
        method: :post,
        status: 400,
        body: audit_log,
        response_body: response_body
      )

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               AuditLogs.create_audit_log(client, audit_log)
    end
  end

  describe "Retrieve an Audit Log" do
    test "get_audit_log/2 returns a 200 status code with the audit log", %{client: client} do
      audit_log_id = 211

      response_body = %{
        "auditLog" => %{
          "id" => audit_log_id,
          "insertInstant" => 1_594_922_276_379,
          "insertUser" => "john.doe@email.com",
          "message" =>
            "Deleted user registration for user with Id [12345] and the application with Id [67892]",
          "reason" => "FusionAuth User Interface"
        }
      }

      Mock.mock_request(
        path: @audit_logs_url <> "/#{audit_log_id}",
        method: :get,
        status: 200,
        response_body: response_body
      )

      assert {:ok, ^response_body, %Tesla.Env{status: 200, body: ^response_body}} =
               AuditLogs.get_audit_log(client, audit_log_id)
    end

    test "get_audit_log/2 returns a 404 status code if the audit_log is not found", %{
      client: client
    } do
      audit_log_id = "not-found"

      Mock.mock_request(
        path: @audit_logs_url <> "/#{audit_log_id}",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404, body: ""}} =
               AuditLogs.get_audit_log(client, audit_log_id)
    end
  end

  describe "Search the Audit Log" do
    test "search_audit_logs/2 returns a 200 status code with the list of audit logs based on the search criteria",
         %{client: client} do
      search = %{
        numberOfResults: 1,
        message: "Deleted*"
      }

      response_body = %{
        "auditLogs" => [
          %{
            "id" => 211,
            "insertInstant" => 1_594_922_276_379,
            "insertUser" => "john.doe@email.com",
            "message" =>
              "Deleted user registration for user with Id [12345] and the application with Id [67892]",
            "reason" => "FusionAuth User Interface"
          }
        ],
        "total" => 62
      }

      Mock.mock_request(
        path: @audit_logs_url <> "/search",
        method: :post,
        status: 200,
        body: search,
        response_body: response_body
      )

      assert {:ok, ^response_body, %Tesla.Env{status: 200, body: ^response_body}} =
               AuditLogs.search_audit_logs(client, search)
    end
  end

  describe "Export Audit Logs" do
    test "export_audit_logs/2 returns a 200 status code with a compressed archive byte stream based on the export criteria",
         %{client: client} do
      criteria = %{start: 1_594_922_276_379, user: "john.doe@email.com"}

      Mock.mock_request(
        path: @audit_logs_url <> "/export",
        method: :post,
        status: 200,
        body: criteria,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = AuditLogs.export_audit_logs(client, criteria)
    end
  end
end
