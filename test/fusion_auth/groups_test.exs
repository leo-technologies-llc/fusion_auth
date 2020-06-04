defmodule FusionAuth.GroupsTest do
  use ExUnit.Case

  alias FusionAuth.Groups
  alias FusionAuth.TestSupport.Helpers

  @groups_url "/api/groups"
  @members_url "/api/groups"

  setup do
    # api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    # tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    # client = FusionAuth.client(Helpers.base_url(), api_key, tenant_id)
    client = FusionAuth.client()
    {:ok, %{client: client}}
  end

  describe "get_groups/1" do
    test "returns list of groups", %{client: client} do
      Helpers.mock_request(
        path: @groups_url,
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Groups.get_groups(client)
    end
  end

  describe "get_group/2" do
    test "returns a 200 status code with the group based on the ID", %{client: client} do
      group_id = "06da543e-df3e-4011-b122-a9ff04326599"

      Helpers.mock_request(
        path: @groups_url <> "/#{group_id}",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Groups.get_group(client, group_id)
    end

    test "returns a 404 status code if the user is not found", %{client: client} do
      Helpers.mock_request(
        path: @groups_url <> "/12345",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404, body: ""}} = Groups.get_group(client, "12345")
    end
  end
end
