defmodule FusionAuth.AuditLogsTest do
  use FusionAuth.DataCase

  alias FusionAuth.AuditLogs
  alias FusionAuth.TestUtilities

  @audit_log %{insertUser: "john.doe@email.com", message: "This is an audit log."}

  setup do
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    {:ok, %{client: client_with_tenant}}
  end

  describe "Add an Entry to the Audit Log" do
    test "create_audit_log/2 returns a 200 status code with the newly created audit log", %{
      client: client
    } do
      {:ok, created_audit_log, _} = AuditLogs.create_audit_log(client, @audit_log)

      assert created_audit_log["auditLog"]["message"] == @audit_log[:message]
      assert created_audit_log["auditLog"]["insertUser"] == @audit_log[:insertUser]
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

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               AuditLogs.create_audit_log(client, audit_log)
    end
  end

  describe "Retrieve an Audit Log" do
    test "get_audit_log/2 returns a 200 status code with the audit log", %{client: client} do
      {:ok, created_audit_log, _} = AuditLogs.create_audit_log(client, @audit_log)
      created_audit_log_id = created_audit_log["auditLog"]["id"]

      {:ok, retrieved_audit_log, _} = AuditLogs.get_audit_log(client, created_audit_log_id)

      assert retrieved_audit_log == created_audit_log
    end

    test "get_audit_log/2 returns a 404 status code if the audit_log is not found", %{
      client: client
    } do
      audit_log_id = "-1"

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

      audit_log = %{
        insertUser: "john.doe@email.com",
        message:
          "Deleted user registration for user with Id [12345] and the application with Id [67892]",
        reason: "FusionAuth User Interface"
      }

      {:ok, created_audit_log, _} = AuditLogs.create_audit_log(client, audit_log)
      created_audit_log_id = created_audit_log["auditLog"]["id"]

      {:ok, result, _} = AuditLogs.search_audit_logs(client, search)

      assert Enum.at(result["auditLogs"], 0)["id"] == created_audit_log_id
    end
  end

  describe "Export Audit Logs" do
    test "export_audit_logs/2 returns a 200 status code with a compressed archive byte stream based on the export criteria",
         %{client: client} do
      criteria = %{user: "john.doe@email.com"}
      {:ok, byte_stream, %Tesla.Env{status: 200}} = AuditLogs.export_audit_logs(client, criteria)

      assert is_bitstring(byte_stream)
    end
  end
end
