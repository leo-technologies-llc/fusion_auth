defmodule FusionAuth.Groups do
  @moduledoc """
  The `FusionAuth.Groups` module provides access methods to the [FusionAuth Groups API](https://fusionauth.io/docs/v1/tech/apis/groups).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.

  ## Examples
  """

  @type group ::  %{
    role_ids: [String.t()],
    group: %{
      data: map(),
      name: String.t()
    }
  }

  @type member ::  %{
    user_id: String.t(),
    data: map()
  }

  alias FusionAuth.Utils

  @group_url "/api/group"
  @member_url "#{@group_url}/member"

  @spec create_group(FusionAuth.client(), map()) :: FusionAuth.request()
  def create_group(client, group) do
  end

  @spec create_group(FusionAuth.client(), String.t(), map()) :: FusionAuth.request()
  def create_group(client, group_id, group) do
  end

  @spec get_groups(FusionAuth.client()) :: FusionAuth.request()
  def get_groups(client) do
  end

  @spec get_group(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def get_group(client, group_id) do
  end

  @spec update_group(FusionAuth.client(), String.t(), map()) :: FusionAuth.request()
  def update_group(client, group_id, group) do
  end

  @spec delete_group(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def delete_group(client, group_id) do
  end

  @spec add_members(FusionAuth.client(), map()) :: FusionAuth.request()
  def add_members(client, members) do
  end

  @spec add_members(FusionAuth.client(), String.t(), map()) :: FusionAuth.request()
  def add_member(client, group_id, member) do
  end

  @spec remove_member(FusionAuth.client(), list()) :: FusionAuth.request()
  def remove_members(client, members) when is_list(members) do
  end

  @spec remove_member(FusionAuth.client(), map()) :: FusionAuth.request()
  def remove_members(client, members) when is_map(members) do
  end

  @spec remove_members(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def remove_members(client, group_id) do
  end

  @spec remove_member(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def remove_member(client, member_id) do
  end

  @spec remove_member(FusionAuth.client(), String.t(), String.t()) :: FusionAuth.request()
  def remove_member(client, group_id, user_id) do
  end
end
