defmodule FusionAuth.UsersTest do
  use ExUnit.Case

  import Tesla.Mock

  alias FusionAuth.Users

  doctest FusionAuth.Users

  setup do
    base_url = "http://localhost:9011"
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    client = FusionAuth.client(base_url, api_key, tenant_id)

    mock(fn
      %{method: :get, url: "http://localhost:9011/api/user/06da543e-df3e-4011-b122-a9ff04326599"} ->
        {:ok, %Tesla.Env{status: 200, body: %{}}}

      %{method: :get, url: "http://localhost:9011/api/user?email=cogadmin@cogility.com"} ->
        {:ok, %Tesla.Env{status: 200, body: %{}}}

      %{method: :get, url: "http://localhost:9011/api/user?username=cogadmin"} ->
        {:ok, %Tesla.Env{status: 200, body: %{}}}

      %{method: :get, url: "http://localhost:9011/api/user/12345"} ->
        {:error, %Tesla.Env{status: 404, body: ""}}
    end)

    {:ok, %{client: client, tenant_id: tenant_id}}
  end

  describe "Get User by ID" do
    test "get_user/2 returns the user based on the ID", %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Users.get_user_by_id(client, "06da543e-df3e-4011-b122-a9ff04326599")
    end

    test "get_user/2 returns a 404 status code if the user is not found", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404, body: ""}} =
               Users.get_user_by_id(client, "12345")
    end
  end
end
