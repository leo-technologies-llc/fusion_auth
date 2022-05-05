defmodule FusionAuth.TestUtilities do
  def cleanup_tenant(client, tenant_id) do
    Tesla.delete(client, "/api/tenant/" <> tenant_id)
  end

  def create_tenant(client, tenant_id) do
    tenant = %{
      "tenant" => %{
        "name" => "Test Tenant"
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  def create_application(client_with_tenant, application_id) do
    application = %{
      "application" => %{
        "name" => "Test Application"
      }
    }

    Tesla.post(client_with_tenant, "/api/application/" <> application_id, application)
  end
end
