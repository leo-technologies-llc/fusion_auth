defmodule FusionAuth.UsersTest do
  use ExUnit.Case

  import Tesla.Mock

  alias FusionAuth.Users

  doctest FusionAuth.Users

  setup do
    base_url = "http://localhost:9011"
    api_key = "123456"
    tenant_id = "234567"
    client = FusionAuth.client(base_url, api_key, tenant_id)

    mock(fn
      %{method: :get, url: "http://localhost:9011/api/user/12345"} ->
        {:ok, %Tesla.Env{status: 200, body: %{"user" => %{}}}}
    end)

    {:ok, %{client: client}}
  end

  describe "Retrieve a User by ID" do
    test "get_user/2 returns the user based on the ID", %{client: client} do
      assert {:ok, %{"user" => %{}}, %Tesla.Env{status: 200, body: _}} =
               Users.get_user_by_id(client, "12345")
    end
  end
end
