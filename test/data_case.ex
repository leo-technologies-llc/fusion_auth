defmodule FusionAuth.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.
  """

  use ExUnit.CaseTemplate
  alias FusionAuth.TestUtilities

  using do
    quote do
      import FusionAuth.DataCase
    end
  end

  setup do
    clean_data()

    on_exit(fn ->
      clean_data()
    end)

    :ok
  end

  defp clean_data() do
    base_url = Application.get_env(:fusion_auth, :api_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)
    client = FusionAuth.client(base_url, api_key, "")

    TestUtilities.cleanup_groups(client)
    TestUtilities.cleanup_identity_providers(client)
    TestUtilities.cleanup_users(client)
    TestUtilities.cleanup_tenant(client, tenant_id)
  end
end
