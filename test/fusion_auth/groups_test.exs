defmodule FusionAuth.GroupsTest do
  use FusionAuth.DataCase

  alias FusionAuth.Groups
  alias FusionAuth.Applications
  alias FusionAuth.Users
  alias FusionAuth.TestUtilities

  @role %{
    "description" => "Test role description.",
    "name" => "Test Role",
    "is_default" => true,
    "is_super_role" => true
  }

  @application %{
    "active" => true,
    "name" => "Test Application",
    "roles" => [@role],
    "is_super_role" => true
  }

  @group %{
    "data" => %{
      "description" => "This is a group created for tests."
    },
    "name" => "Test Group"
  }

  setup do
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    # on_exit(fn ->
    #   TestUtilities.cleanup_users(client)
    #   TestUtilities.cleanup_tenant(client, tenant_id)
    #   cleanup_groups(client)
    # end)

    {:ok, %{client: client_with_tenant}}
  end

  describe "get_groups/1" do
    test "returns list of groups", %{client: client} do
      {:ok, group_1, _} = Groups.create_group(client, @group)
      group_1_id = group_1["group"]["id"]

      group_2 = Map.put(@group, "name", "New Test Group")
      {:ok, group_2, _} = Groups.create_group(client, group_2)
      group_2_id = group_2["group"]["id"]

      {:ok, all_groups, _} = Groups.get_groups(client)

      assert Enum.map(all_groups["groups"], fn group ->
               group["id"] in [group_1_id, group_2_id]
             end)
    end
  end

  describe "get_group/2" do
    test "returns a 200 status code with the group based on the ID", %{client: client} do
      {:ok, group, _} = Groups.create_group(client, @group)
      group_id = group["group"]["id"]

      {:ok, retrieved_group, _} = Groups.get_group(client, group_id)

      assert group == retrieved_group
    end

    test "returns a 404 status code if the user is not found", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404, body: ""}} = Groups.get_group(client, "12345")
    end
  end

  describe "create_group/3" do
    test "creates group with roles", %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      application_id = application["application"]["id"]
      role_id = Enum.at(application["application"]["roles"], 0)["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group, [role_id])

      assert created_group["group"]["name"] == @group["name"]
      assert Enum.at(created_group["group"]["roles"][application_id], 0)["id"] == role_id
    end

    test "creates group without roles", %{client: client} do
      {:ok, created_group, _} = Groups.create_group(client, @group)
      assert created_group["group"]["name"] == @group["name"]
    end

    test "handle duplicate group name", %{client: client} do
      error_response = %{
        "fieldErrors" => %{
          "group.name" => [
            %{
              "code" => "[duplicate]group.name",
              "message" => "A group with the name [Test Group] already exists."
            }
          ]
        }
      }

      Groups.create_group(client, @group)

      {:error, error, _} = Groups.create_group(client, @group)

      assert error == error_response
    end
  end

  describe "update_group/" do
    test "update group with roles", %{client: client} do
      {:ok, application, _} = Applications.create_application(client, @application)
      role_id = Enum.at(application["application"]["roles"], 0)["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group, [role_id])
      group_id = created_group["group"]["id"]

      updated_attrs = %{name: "Modified Group"}

      {:ok, updated_group, _} = Groups.update_group(client, group_id, updated_attrs)

      assert updated_group["group"]["name"] == updated_attrs[:name]
    end

    test "update group without roles", %{client: client} do
      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      updated_attrs = %{name: "Modified Group"}

      {:ok, updated_group, _} = Groups.update_group(client, group_id, updated_attrs)

      assert updated_group["group"]["name"] == updated_attrs[:name]
    end
  end

  describe "delete_group/2" do
    test "can delete group", %{client: client} do
      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]
      {:ok, response, _} = Groups.delete_group(client, group_id)
      assert response == ""
    end
  end

  describe "add_member/3" do
    test "add member by user_id", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, member_object, _} = Groups.add_member(client, group_id, created_user_id)

      assert Enum.at(member_object["members"][group_id], 0)["userId"] == created_user_id
    end

    test "add member by member map", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, member_object, _} = Groups.add_member(client, group_id, %{userId: created_user_id})

      assert Enum.at(member_object["members"][group_id], 0)["userId"] == created_user_id
    end
  end

  describe "add_members/3" do
    test "add member by user_id", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, member_object, _} = Groups.add_member(client, group_id, %{userId: created_user_id})

      assert Enum.at(member_object["members"][group_id], 0)["userId"] == created_user_id
    end
  end

  describe "remove_member/2" do
    test "remove member by member_id", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, member_object, _} = Groups.add_member(client, group_id, %{userId: created_user_id})
      member_id = Enum.at(member_object["members"][group_id], 0)["id"]

      {:ok, response, _} = Groups.remove_member(client, member_id)

      assert response == ""
    end
  end

  describe "remove_member/3" do
    test "remove member by group_id and user_id", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, _, _} = Groups.add_member(client, group_id, %{userId: created_user_id})
      {:ok, response, _} = Groups.remove_member(client, group_id, created_user_id)

      assert response == ""
    end
  end

  describe "remove_members/2" do
    test "when list of member_ids", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, member_object, _} = Groups.add_member(client, group_id, %{userId: created_user_id})
      member_id = Enum.at(member_object["members"][group_id], 0)["id"]

      {:ok, response, _} = Groups.remove_members(client, [member_id])

      assert response == ""
    end

    test "when group_id", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, _, _} = Groups.add_member(client, group_id, %{userId: created_user_id})
      {:ok, response, _} = Groups.remove_members(client, group_id)

      assert response == ""
    end
  end

  describe "remove_members/3" do
    test "remove member from group with user_ids", %{client: client} do
      user = %{username: "johndoe", password: "password"}
      {:ok, created_user, _} = Users.create_user(client, user)
      created_user_id = created_user["user"]["id"]

      {:ok, created_group, _} = Groups.create_group(client, @group)
      group_id = created_group["group"]["id"]

      {:ok, _, _} = Groups.add_member(client, group_id, %{userId: created_user_id})
      {:ok, response, _} = Groups.remove_members(client, group_id, [created_user_id])

      assert response == ""
    end
  end

  def cleanup_groups(client) do
    {:ok, groups, _} = Groups.get_groups(client)

    if groups != %{} do
      Enum.map(groups["groups"], fn group ->
        Groups.delete_group(client, group["id"])
      end)
    end
  end
end
