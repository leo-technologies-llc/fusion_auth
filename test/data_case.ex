defmodule FusionAuth.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use FusionAuth.DataCase, async: true`, although
  this option is not recommended for other databases.
  """
  import Ecto.Query, only: [from: 2]

  use ExUnit.CaseTemplate

  using do
    quote do
      alias FusionAuth.Repo
      import Ecto
      import Ecto.Changeset
      import FusionAuth.DataCase
    end
  end

  setup do
    on_exit(fn ->
      cleanup_groups()
      cleanup_users()
      cleanup_identity_providers()
      cleanup_applications()
      cleanup_tenant()
      cleanup_audit_logs()
      cleanup_keys()
    end)

    :ok
  end

  defp cleanup_identity_providers() do
    query = from(x in "federated_domains", select: x.domain)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "identity_providers_applications", select: x.data)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "identity_providers_tenants", select: x.data)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "identity_providers", select: x.id)
    FusionAuth.Repo.delete_all(query)
  end

  defp cleanup_groups() do
    query = from(x in "group_members", select: x.id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "group_application_roles", select: x.groups_id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "groups", select: x.id)
    FusionAuth.Repo.delete_all(query)
  end

  defp cleanup_audit_logs() do
    query = from(x in "audit_logs", select: x.id)
    FusionAuth.Repo.delete_all(query)
  end

  def cleanup_applications() do
    query = from(x in "application_daily_active_users", select: x.count)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_application_daily_active_users", select: x.day)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_global_daily_active_users", select: x.day)
    FusionAuth.Repo.delete_all(query)

    query = from(x in "application_monthly_active_users", select: x.count)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_application_monthly_active_users", select: x.month)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_global_monthly_active_users", select: x.month)
    FusionAuth.Repo.delete_all(query)

    query = from(x in "application_registration_counts", select: x.count)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_application_registration_counts", select: x.count)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_global_registration_counts", select: x.count)
    FusionAuth.Repo.delete_all(query)

    query = from(x in "hourly_logins", select: x.data)
    FusionAuth.Repo.delete_all(query)

    query =
      from(x in "application_roles",
        select: x.applications_id,
        where:
          x.applications_id !=
            any(from(x in "applications", select: x.id, where: x.name == "FusionAuth"))
      )

    FusionAuth.Repo.delete_all(query)
    query = from(x in "applications", select: x.name, where: x.name != "FusionAuth")
    FusionAuth.Repo.delete_all(query)
  end

  defp cleanup_tenant() do
    query =
      from(x in "connectors_tenants",
        select: x.data,
        where:
          x.tenants_id !=
            any(from(x in "tenants", select: x.id, where: x.name == "Default"))
      )

    FusionAuth.Repo.delete_all(query)
    query = from(x in "tenants", select: x.id, where: x.name != "Default")
    FusionAuth.Repo.delete_all(query)
  end

  defp cleanup_users() do
    query = from(x in "refresh_tokens", select: x.users_id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "user_registrations", select: x.id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "external_identifiers", select: x.users_id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "previous_passwords", select: x.users_id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "identities", select: x.users_id)
    FusionAuth.Repo.delete_all(query)
    query = from(x in "raw_logins", select: x.users_id)
    FusionAuth.Repo.delete_all(query)
    query = from(u in "users", select: u.id)
    FusionAuth.Repo.delete_all(query)

    query = %{
      "query" => %{
        "match_all" => %{}
      }
    }

    client =
      FusionAuth.client("http://172.30.243.114:29200", "", "", [:disable_authorization_headers])

    # Tesla.get(client, "/fusionauth_user/_search", body: query) |> IO.inspect()
    Tesla.post(client, "/fusionauth_user/_delete_by_query?refresh=true", query)

    # Tesla.post(client, "/fusionauth_user/_delete_by_query?refresh=true", query)

    # Tesla.post(client, "/fusionauth_user/_refresh", "")

    # FusionAuth.Repo.all(query) |> Enum.map(fn x -> Ecto.UUID.load(x) |> IO.inspect() end)
  end

  defp cleanup_keys() do
    query = from(x in "keys", select: x.id, where: not is_nil(x.issuer))
    FusionAuth.Repo.delete_all(query)
  end
end
