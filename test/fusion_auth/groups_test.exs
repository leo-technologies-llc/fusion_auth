defmodule FusionAuth.GroupsTest do
  use ExUnit.Case

  alias FusionAuth.Groups
  alias FusionAuth.TestSupport.Helpers

  @groups_url "/api/groups"
  @members_url "/api/groups"

  @application_id "861f5558-34a8-43e4-ab50-317bdcd47671"
  @role_id "3ebbc43c-7add-42cd-87b4-c6eca0438c6c"
  @group_id "8c08f404-3a05-4e60-9d1c-a76766921472"
  @member_id "3abd935a-3fa5-4402-ba5d-bae024a8d5c4"
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"

  @group %{
    "id" => @group_id,
    "name" => "Test Group",
    "data" => %{"description" => "Test Group Description"},
    "tenantId" => "edad5b36-25a2-0631-3694-64ba3d39bce9",
    "roles" => %{
      @application_id => [
        %{
          "description" => "admin",
          "id" => @role_id,
          "isDefault" => true,
          "isSuperRole" => true,
          "name" => "admin"
        }
      ]
    }
  }

  @member %{
    "id" => @member_id,
    "insertInstant" => 1_591_303_565_005,
    "userId" => @user_id
  }

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

  describe "create_group/3" do
    test "creates group with roles", %{client: client} do
      Helpers.mock_request(
        path: @groups_url,
        method: :post,
        status: 200,
        response_body: %{"group" => @group}
      )

      group = %{name: @group["name"], data: %{description: @group["data"]["description"]}}
      roles = [@role_id]

      {:ok, %{"group" => group}, _} = Groups.create_group(client, group, roles)

      assert group["name"] == @group["name"]
      assert group["data"]["description"] == @group["data"]["description"]
    end

    test "creates group without roles", %{client: client} do
      Helpers.mock_request(
        path: @groups_url,
        method: :post,
        status: 200,
        response_body: %{"group" => @group}
      )

      group = %{name: @group["name"], data: %{description: @group["data"]["description"]}}

      {:ok, %{"group" => group}, _} = Groups.create_group(client, group)

      assert group["name"] == @group["name"]
      assert group["data"]["description"] == @group["data"]["description"]
    end

    test "handle duplicate group name", %{client: client} do
      error_response = %{
        "fieldErrors" => %{
          "group.name" => [
            %{
              "code" => "[duplicate]group.name",
              "message" => "A group with name = [Test Group] already exists."
            }
          ]
        }
      }

      Helpers.mock_request(
        path: @groups_url,
        method: :post,
        status: 400,
        response_body: error_response
      )

      group = %{name: @group["name"], data: %{description: @group["data"]["description"]}}

      {:error, error, _} = Groups.create_group(client, group)

      assert error == error_response
    end
  end

  describe "update_group/" do
    test "update group with roles", %{client: client} do
      group = Map.put(@group, "name", "Modified Group")

      Helpers.mock_request(
        path: @groups_url <> "/#{@group_id}",
        method: :patch,
        status: 200,
        response_body: %{"group" => group}
      )

      attrs = %{name: "Modified Group"}

      {:ok, %{"group" => group}, _} = Groups.update_group(client, @group_id, attrs, [@role_id])

      assert group["name"] == "Modified Group"
    end

    test "update group without roles", %{client: client} do
      group = Map.put(@group, "name", "Modified Group")

      Helpers.mock_request(
        path: @groups_url <> "/#{@group_id}",
        method: :patch,
        status: 200,
        response_body: %{"group" => group}
      )

      attrs = %{name: "Modified Group"}

      {:ok, %{"group" => group}, _} = Groups.update_group(client, @group_id, attrs)

      assert group["name"] == "Modified Group"
    end
  end

  describe "delete_group/2" do
    test "can delete group", %{client: client} do
      Helpers.mock_request(
        path: @groups_url <> "/#{@group_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      {:ok, response, _} = Groups.delete_group(client, @group_id)

      assert response == ""
    end
  end

  describe "add_member/3" do
    test "add member by user_id", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :post,
        status: 200,
        response_body: %{
          "members" => %{
            @group_id => [@member]
          }
        }
      )

      {:ok, %{"members" => %{@group_id => [member]}}, _} =
        Groups.add_member(client, @group_id, @user_id)

      assert member["userId"] == @user_id
    end

    test "add member by member map", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :post,
        status: 200,
        response_body: %{
          "members" => %{
            @group_id => [@member]
          }
        }
      )

      member = %{userId: @user_id}

      {:ok, %{"members" => %{@group_id => [member]}}, _} =
        Groups.add_member(client, @group_id, member)

      assert member["userId"] == @user_id
    end
  end

  describe "add_members/3" do
    test "add member by user_id", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :post,
        status: 200,
        response_body: %{
          "members" => %{
            @group_id => [@member]
          }
        }
      )

      member = %{userId: @user_id}

      {:ok, %{"members" => %{@group_id => [member]}}, _} =
        Groups.add_members(client, @group_id, [member])

      assert member["userId"] == @user_id
    end
  end

  describe "remove_member/2" do
    test "remove member by member_id", %{client: client} do
      Helpers.mock_request(
        path: @members_url <> "/#{@member_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      {:ok, response, _} = Groups.remove_member(client, @member_id)

      assert response == ""
    end
  end

  describe "remove_member/3" do
    test "remove member by group_id and user_id", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :delete,
        status: 200,
        response_body: ""
      )

      {:ok, response, _} = Groups.remove_member(client, @group_id, @user_id)

      assert response == ""
    end
  end

  describe "remove_members/2" do
    test "when list of member_ids", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :delete,
        status: 200,
        response_body: ""
      )

      {:ok, response, _} = Groups.remove_members(client, [@member_id])

      assert response == ""
    end

    test "when group_id", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :delete,
        status: 200,
        response_body: ""
      )

      {:ok, response, _} = Groups.remove_members(client, @group_id)

      assert response == ""
    end
  end

  describe "remove_members/3" do
    test "remove member from group with user_ids", %{client: client} do
      Helpers.mock_request(
        path: @members_url,
        method: :delete,
        status: 200,
        response_body: ""
      )

      {:ok, response, _} = Groups.remove_members(client, @group_id, [@user_id])

      assert response == ""
    end
  end
end
