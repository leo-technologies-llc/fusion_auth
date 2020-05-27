defmodule FusionAuth.UsersTest do
  use ExUnit.Case
  import Tesla.Mock

  doctest FusionAuth.Users

  setup do
    base_url = "http://localhost:9011"
    api_key = "123456"
    tenant_id = "234567"
    client = FusionAuth.client(base_url, api_key, tenant_id)

    {:ok, %{client: client}}
  end

  describe "Retrieve a User by ID" do
    test "get_user/2 returns the user based on the ID", %{client: client} do
      IO.inspect(client, label: "CLIENT")
    end
  end
end
