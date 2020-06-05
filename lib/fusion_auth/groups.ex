defmodule FusionAuth.Groups do
  @moduledoc """
  The `FusionAuth.Groups` module provides access methods to the [FusionAuth Groups API](https://fusionauth.io/docs/v1/tech/apis/groups).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.

  ## Group Fields
    - id :: String.t()  \n
      The unique Id of this Group. If not specified a secure random UUID will be generated.

    - tenantId :: String.t()  \n
      The tenant of which this Group belongs to.

    - name :: String.t()  \n
      The unique name of the Group.

    - data :: map()  \n
      An object that can hold any information about the Group that should be persisted.

    - roles :: map()  \n
      The roles assigned to this Group. The map key is the Application Id, the value is an array of Application Roles.

  ## Member Fields
    - id :: String.t()  \n
      The unique Id of this Group Member. If not specified a secure random UUID will be generated.

    - userId :: String.t()  \n
      The user of which this Group Member belongs to.

    - data :: map() \n
      An object that can hold any information about the Group Member that should be persisted.

    - insertInstant :: integer()  \n
      Value represents the instant them member was created in epoch time

  ## Examples

    ```
    iex> client = FusionAuth.client(...)
    iex> FusionAuth.Groups.get_group(client, "a4c99f4f-24d5-49bf-921f-ff80fc76b3ef")
    {
      :ok,
      %{
        "group" => %{
          "data" => %{"description" => "My First Group"},
          "id" => "a4c99f4f-24d5-49bf-921f-ff80fc76b3ef",
          "name" => "Group",
          "roles" => %{
            "861f5558-34a8-43e4-ab50-317bdcd47671" => [
              %{
                "description" => "admin",
                "id" => "3ebbc43c-7add-42cd-87b4-c6eca0438c6c",
                "isDefault" => true,
                "isSuperRole" => true,
                "name" => "admin"
              }
            ]
          },
          "tenantId" => "edad5b36-25a2-0631-3694-64ba3d39bce9"
        }
      },
      %Tesla.Env{...}
    }
    ```
    ```
    iex> FusionAuth.Groups.add_member(client, "a4c99f4f-24d5-49bf-921f-ff80fc76b3ef", "84846873-89d2-44f8-91e9-dac80f420cb2")
    {
      :ok,
      %{
        "members" => %{
          "a4c99f4f-24d5-49bf-921f-ff80fc76b3ef" => [
            %{
              "id" => "67c66607-d3ed-4073-adb2-53de8d10ac4e",
              "insertInstant" => 1591306181126,
              "userId" => "84846873-89d2-44f8-91e9-dac80f420cb2"
            }
          ]
        }
      },
      %Tesla.Env{...}
    }
    ```

  """

  @type user_id :: String.t()
  @type group_id :: String.t()
  @type member_id :: String.t()
  @type role_id :: String.t()
  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()
  @type group :: %{name: String.t(), data: map()}
  @type member :: %{userId: user_id(), data: map()}
  @type member_list :: list(member())
  @type member_ids :: list(member_id())
  @type user_ids :: list(user_id())
  @type role_ids :: [role_id()]

  @group_url "/api/group"
  @member_url "#{@group_url}/member"

  @doc """
  For more information visit the FusionAuth API Documentation for [Create a Group](https://fusionauth.io/docs/v1/tech/apis/groups#create-a-group)
  """
  @spec create_group(client(), group(), role_ids()) :: result()
  def create_group(client, group, roles_ids \\ []) do
    Tesla.post(client, @group_url, post_data(group, roles_ids))
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Retrieve a Group](https://fusionauth.io/docs/v1/tech/apis/groups#retrieve-a-group)
  """
  @spec get_groups(client()) :: result()
  def get_groups(client) do
    Tesla.get(client, @group_url)
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Retrieve a Group](https://fusionauth.io/docs/v1/tech/apis/groups#retrieve-a-group)
  """
  @spec get_group(client(), group_id()) :: result()
  def get_group(client, group_id) do
    Tesla.get(client, @group_url <> "/#{group_id}")
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Update a Group](https://fusionauth.io/docs/v1/tech/apis/groups#update-a-group)
  """
  @spec update_group(client(), group_id(), group(), role_ids()) :: result()
  def update_group(client, group_id, group, roles_ids \\ []) do
    Tesla.patch(client, @group_url <> "/#{group_id}", post_data(group, roles_ids))
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Delete a Group](https://fusionauth.io/docs/v1/tech/apis/groups#delete-a-group)
  """
  @spec delete_group(client(), group_id()) :: result()
  def delete_group(client, group_id) do
    Tesla.delete(client, @group_url <> "/#{group_id}")
    |> FusionAuth.result()
  end

  @doc """
  Add member to a group by user_id

  For more information visit the FusionAuth API Documentation for [Add Users to a Group](https://fusionauth.io/docs/v1/tech/apis/groups#add-users-to-a-group)
  """
  @spec add_member(client(), group_id(), user_id()) :: result()
  def add_member(client, group_id, user_id) when is_binary(user_id),
    do: add_members(client, group_id, [%{userId: user_id, data: %{}}])

  @doc """
  Add member to a group.

  For more information visit the FusionAuth API Documentation for [Add Users to a Group](https://fusionauth.io/docs/v1/tech/apis/groups#add-users-to-a-group)
  """
  @spec add_member(client(), group_id(), member()) :: result()
  def add_member(client, group_id, member) when is_map(member),
    do: add_members(client, group_id, [member])

  @doc """
  Add multiple members to a group.

  For more information visit the FusionAuth API Documentation for [Add Users to a Group](https://fusionauth.io/docs/v1/tech/apis/groups#add-users-to-a-group)
  """
  @spec add_members(client(), group_id(), member_list()) :: result()
  def add_members(client, group_id, members) do
    data = %{
      members: %{
        group_id => members
      }
    }

    Tesla.post(client, @member_url, data)
    |> FusionAuth.result()
  end

  @doc """
  Remove member by member_id

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group](https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group)
  """
  @spec remove_member(client(), member_id()) :: result()
  def remove_member(client, member_id) do
    Tesla.delete(client, @member_url <> "/#{member_id}")
    |> FusionAuth.result()
  end

  @doc """
  Remove member by group_id and user_id

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group](https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group)
  """
  @spec remove_member(client(), group_id(), user_id()) :: result()
  def remove_member(client, group_id, user_id) do
    url = Tesla.build_url(@member_url, groupId: group_id, userId: user_id)

    Tesla.delete(client, url)
    |> FusionAuth.result()
  end

  @doc """
  Remove members by member_ids

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group](https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group)
  """
  @spec remove_members(client(), member_ids()) :: result()
  def remove_members(client, member_ids) when is_list(member_ids) do
    Tesla.delete(client, @member_url, body: %{memberIds: member_ids})
    |> FusionAuth.result()
  end

  @doc """
  Remove all members by group_id

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group](https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group)
  """
  @spec remove_members(client(), group_id()) :: result()
  def remove_members(client, group_id) do
    url = Tesla.build_url(@member_url, groupId: group_id)

    Tesla.delete(client, url)
    |> FusionAuth.result()
  end

  @doc """
  Remove members by group_id and user_ids

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group](https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group)
  """
  @spec remove_members(client(), group_id(), user_ids()) :: result()
  def remove_members(client, group_id, user_ids) do
    Tesla.delete(client, @member_url, body: %{members: %{group_id => user_ids}})
    |> FusionAuth.result()
  end

  defp post_data(group, []), do: %{group: group}
  defp post_data(group, roles_ids), do: %{group: group, roleIds: roles_ids}
end
