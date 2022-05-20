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
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)
    client = FusionAuth.client(base_url, api_key, "")

    TestUtilities.cleanup_groups(client)
    TestUtilities.cleanup_identity_providers(client)
    TestUtilities.cleanup_users(client)
    TestUtilities.cleanup_tenant(client, tenant_id)
  end
end
