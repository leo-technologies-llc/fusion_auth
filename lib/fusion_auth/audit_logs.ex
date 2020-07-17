defmodule FusionAuth.AuditLogs do
  @moduledoc """
  The `FusionAuth.AuditLogs` module provides access functions to the [FusionAuth Audit Logs API](https://fusionauth.io/docs/v1/tech/apis/audit-logs).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.

  ## Audit Log Fields

    - data :: map()\n
    Additional details of an audit log.

    - newValue :: String.t()\n
    The new value of the changed object.

    - oldValue :: String.t()\n
    The previous value of the changed object.

    - reason :: String.t()\n
    The reason why the audit log was created.

    - id :: integer()\n
    The Audit Log unique id.

    - insertInstant :: integer()\n
    The instant when the Audit Log was created.

    - insertUser :: String.t()\n
    The user that created the Audit Log.

    - message :: String.t()\n
    The message of the Audit Log.

  """
  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()
  @type audit_log :: %{
          data: map() | nil,
          newValue: String.t() | nil,
          oldValue: String.t() | nil,
          reason: String.t() | nil,
          insertUser: String.t(),
          message: String.t()
        }
  @type search_criteria :: %{
          end: integer() | nil,
          message: String.t() | nil,
          numberOfResults: integer() | nil,
          orderBy: String.t() | nil,
          start: integer() | nil,
          startRow: integer() | nil,
          user: String.t() | nil
        } | map()
  @type export_criteria :: %{
          end: integer() | nil,
          message: String.t() | nil,
          start: integer() | nil,
          user: String.t() | nil,
          dateTimeSecondsFormat: String.t() | nil,
          zoneId: String.t()
        }

  @audit_logs_url "/api/system/audit-log"

  @doc """
  Create an audit log.

  ## Examples

      iex> client = FusionAuth.client(...)
      iex> FusionAuth.AuditLogs.create_audit_log(client, %{insertUser: "john.doe@email.com", message: "This is a new audit log."})
      {
        :ok,
        %{
          "auditLog" => %{
            "id" => 212,
            "insertInstant" => 1594942979998,
            "insertUser" => "john.doe@email.com",
            "message" => "This is a new audit log."
          }
        },
        %Tesla.Env{...}
      }

  For more information visit the FusionAuth API Documentation for [Add an Entry to the Audit Log](https://fusionauth.io/docs/v1/tech/apis/audit-logs#add-an-entry-to-the-audit-log).
  """
  @spec create_audit_log(client(), audit_log()) :: result()
  def create_audit_log(client, audit_log) do
    Tesla.post(client, @audit_logs_url, %{auditLog: audit_log}) |> FusionAuth.result()
  end

  @doc """
  Get an audit log by ID.

  ## Examples

      iex> client = FusionAuth.client(...)
      iex> FusionAuth.AuditLogs.get_audit_log(client, 211)
      {
        :ok,
        %{
          "auditLog" => %{
            "id" => 211,
            "insertInstant" => 1594922276379,
            "insertUser" => "john.doe@email.com",
            "message" => "Deleted user registration for user with Id [12345] and the application with Id [67892]",
            "reason" => "FusionAuth User Interface"
          }
        },
        %Tesla.Env{...}
      }

  For more information visit the FusionAuth API Documentation for [Retrieve an Audit Log](https://fusionauth.io/docs/v1/tech/apis/audit-logs#retrieve-an-audit-log).
  """
  @spec get_audit_log(client(), integer()) :: result()
  def get_audit_log(client, audit_log_id) do
    Tesla.get(client, @audit_logs_url <> "/#{audit_log_id}") |> FusionAuth.result()
  end

  @doc """
  Search and paginate through audit logs.

  ## Examples

      iex> client = FusionAuth.client(...)
      iex> FusionAuth.AuditLogs.search(client, %{message: "Deleted*", numberOfResults: 2, user: "john.doe@email.com"})
      {
        :ok,
        %{
          "auditLogs" => [
            %{
              "id" => 211,
              "insertInstant" => 1594922276379,
              "insertUser" => "john.doe@email.com",
              "message" => "Deleted user registration for user with Id [12345] and the application with Id [67892]",
              "reason" => "FusionAuth User Interface"
            },
            %{
              "id" => 208,
              "insertInstant" => 1594920876552,
              "insertUser" => "john.doe@email.com",
              "message" => "Deleted user with Id [12345]",
              "reason" => "FusionAuth User Interface"
            }
          ],
          "total" => 62
        },
        %Tesla.Env{...}
      }

  For more information visit the FusionAuth API Documentation for [Search the Audit Log](https://fusionauth.io/docs/v1/tech/apis/audit-logs#search-the-audit-log).
  """
  @spec search_audit_logs(client(), search_criteria()) :: result()
  def search_audit_logs(client, search) do
    Tesla.post(client, @audit_logs_url <> "/search", %{search: search}) |> FusionAuth.result()
  end

  @doc """
  Export the audit logs. The response will be a compressed archive byte stream with a `Content-Type` of `application/zip`.

  ## Examples

      iex> client = FusionAuth.client(...)
      iex> FusionAuth.AuditLogs.export(client, %{start: 1594922276379, user: "john.doe@email.com"})
      {
        :ok,
        <<80, 75, 3, 4, 20, 0, 8, 8, 8, 0, 77, 188, 240, 80, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 13, 0, 0, 0, 97, 117, 100, 105, 116, 95, 108, 111, 103, 46, 99, 115,
        118, 237, 125, 107, 115, 19, ...>>,
        %Tesla.Env{...}
      }

  For more information visit the FusionAuth API Documentation for [Export Audit Logs](https://fusionauth.io/docs/v1/tech/apis/audit-logs#export-audit-logs).
  """
  @spec export_audit_logs(client(), export_criteria()) :: result()
  def export_audit_logs(client, criteria) do
    Tesla.post(client, @audit_logs_url <> "/export", %{criteria: criteria}) |> FusionAuth.result()
  end
end
