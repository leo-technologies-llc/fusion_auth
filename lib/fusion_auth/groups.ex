defmodule FusionAuth.Groups do
  @moduledoc """
  The `FusionAuth.Groups` module provides access methods to the [FusionAuth Groups API](https://fusionauth.io/docs/v1/tech/apis/groups).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.

  ## Examples


  """

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()
  @type group :: %{name: String.t(), data: map()}
  @type member :: %{userId: String.t(), data: map()}

  @group_url "/api/group"
  @member_url "#{@group_url}/member"

  @doc """
  For more information visit the FusionAuth API Documentation for [Create a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#create-a-group)
  """
  @spec create_group(client(), group, [String.t()]) :: result()
  def create_group(client, group, roles \\ []) do
    Tesla.post(client, @group_url, post_data(group, roles))
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Retrieve a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#retrieve-a-group)
  """
  @spec get_groups(client()) :: result()
  def get_groups(client) do
    Tesla.get(client, @group_url)
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Retrieve a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#retrieve-a-group)
  """
  @spec get_group(client(), String.t()) :: result()
  def get_group(client, group_id) do
    Tesla.get(client, @group_url <> "/#{group_id}")
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Update a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#update-a-group)
  """
  @spec update_group(client(), String.t(), group(), [String.t()]) :: result()
  def update_group(client, group_id, group, roles \\ []) do
    Tesla.patch(client, @group_url <> "/#{group_id}", post_data(group, roles))
    |> FusionAuth.result()
  end

  @doc """
  For more information visit the FusionAuth API Documentation for [Delete a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#delete-a-group)
  """
  @spec delete_group(client(), String.t()) :: result()
  def delete_group(client, group_id) do
    Tesla.delete(client, @group_url <> "/#{group_id}")
    |> FusionAuth.result()
  end

  @doc """
  Add member to a group by user_id

  For more information visit the FusionAuth API Documentation for [Add Users to a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#add-users-to-a-group)
  """
  @spec add_member(client(), String.t(), String.t()) :: result()
  def add_member(client, group_id, user_id) when is_binary(user_id),
    do: add_members(client, group_id, [%{userId: user_id, data: %{}}])

  @doc """
  Add member to a group.

  ## Parameters
    - member :: map() :: Required
      - userId :: String.t() :: Required
      - data :: map() :: Optional

  For more information visit the FusionAuth API Documentation for [Add Users to a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#add-users-to-a-group)
  """
  @spec add_member(client(), String.t(), member()) :: result()
  def add_member(client, group_id, member) when is_map(member),
    do: add_members(client, group_id, [member])

  @doc """
  Add multiple members to a group.

  ## Parameters
    - members :: list() :: Required
      - member :: map() :: required
        - userId :: String.t() :: Required
        - data :: map() :: Optional

  For more information visit the FusionAuth API Documentation for [Add Users to a Group]
  (https://fusionauth.io/docs/v1/tech/apis/groups#add-users-to-a-group)
  """
  @spec add_members(client(), String.t(), [member()]) :: result()
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

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group]
  https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group
  """
  @spec remove_member(client(), String.t()) :: result()
  def remove_member(client, member_id) do
    Tesla.delete(client, @member_url <> "/#{member_id}")
    |> FusionAuth.result()
  end

  @doc """
  Remove member by group_id and user_id

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group]
  https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group
  """
  @spec remove_member(client(), String.t(), String.t()) :: result()
  def remove_member(client, group_id, user_id) do
    url = Tesla.build_url(@member_url, groupId: group_id, userId: user_id)

    Tesla.delete(client, url)
    |> FusionAuth.result()
  end

  @doc """
  Remove members by member_ids

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group]
  https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group
  """
  @spec remove_members(client(), [String.t()]) :: result()
  def remove_members(client, member_ids) when is_list(member_ids) do
    Tesla.delete(client, @member_url, body: %{memberIds: member_ids})
    |> FusionAuth.result()
  end

  @doc """
  Remove all members by group_id

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group]
  https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group
  """
  @spec remove_members(client(), String.t()) :: result()
  def remove_members(client, group_id) do
    url = Tesla.build_url(@member_url, groupId: group_id)

    Tesla.delete(client, url)
    |> FusionAuth.result()
  end

  @doc """
  Remove members by group_id and user_ids

  For more information visit the FusionAuth API Documentation for [Remove Users from a Group]
  https://fusionauth.io/docs/v1/tech/apis/groups#remove-users-from-a-group
  """
  @spec remove_members(client(), String.t(), [String.t()]) :: result()
  def remove_members(client, group_id, user_ids) do
    Tesla.delete(client, @member_url, body: %{members: %{group_id => user_ids}})
    |> FusionAuth.result()
  end

  defp post_data(group, []), do: %{group: group}
  defp post_data(group, roles), do: %{group: group, roleIds: roles}
end
