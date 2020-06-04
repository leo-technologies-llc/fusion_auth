defmodule FusionAuth.JWT do
  @moduledoc """
  The `FusionAuth.JWT` module provides access functions to the [FusionAuth JWT API](https://fusionauth.io/docs/v1/tech/apis/jwt).

  All functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key)`.
  """
  alias FusionAuth.Utils

  @jwt_url "/api/jwt"

  @spec get_jwt_by_application_id(FusionAuth.client(), String.t(), String.t() | nil) :: FusionAuth.request()
  def get_jwt_by_application_id(client, application_id, refresh_token \\ nil) do
    Tesla.get(
      client,
      @jwt_url <>
        "/issue" <>
        Utils.build_query_parameters(applicationId: application_id, refreshToken: refresh_token)
    )
    |> FusionAuth.result()
  end

  @spec reconcile_jwt(FusionAuth.client(), String.t(), String.t(), map(), String.t()) :: FusionAuth.request()
  def reconcile_jwt(client, application_id, encoded_JWT, data, identity_provider_id) do
    Tesla.post(
      client,
      @jwt_url <> "/reconcile",
      %{
        applicationId: application_id,
        encodedJWT: encoded_JWT,
        data: data,
        identityProviderId: identity_provider_id
      }
    ) |> FusionAuth.result()
  end

  @spec get_public_keys(FusionAuth.client()) :: FusionAuth.request()
  def get_public_keys(client) do
    Tesla.get(client, @jwt_url <> "/public-key") |> FusionAuth.result()
  end

  @spec get_public_key_by_application_id(FusionAuth.client(), String.t() | nil) :: FusionAuth.request()
  def get_public_key_by_application_id(client, application_id \\ nil) do
    Tesla.get(
      client,
      @jwt_url <> "/public-key?applicationId=#{application_id}"
    )
    |> FusionAuth.result()
  end

  @spec get_public_key_by_key_id(FusionAuth.client(), String.t() | nil) :: FusionAuth.request()
  def get_public_key_by_key_id(client, k_id \\ nil) do
    Tesla.get(client, @jwt_url <> "/public-key?kid=#{k_id}") |> FusionAuth.result()
  end

  @spec refresh_jwt(FusionAuth.client(), String.t() | nil, String.t() | nil) :: FusionAuth.request()
  def refresh_jwt(client, refresh_token \\ nil, token \\ nil) do
    Tesla.post(
      client,
      @jwt_url <> "/refresh",
      %{
        refreshToken: refresh_token,
        token: token
      }
    )
  end

  @spec get_user_refresh_tokens_by_user_id(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def get_user_refresh_tokens_by_user_id(client, user_id) do
    Tesla.get(client, @jwt_url <> "/refresh?userId=#{user_id}") |> FusionAuth.result()
  end

  @spec get_user_refresh_tokens(FusionAuth.client()) :: FusionAuth.request()
  def get_user_refresh_tokens(client) do
    Tesla.get(client, @jwt_url <> "/refresh") |> FusionAuth.result()
  end

  @spec delete_refresh_tokens_by_application_id(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def delete_refresh_tokens_by_application_id(client, application_id) do
    Tesla.delete(client, @jwt_url <> "/refresh?applicationId=#{application_id}")
  end

  @spec delete_refresh_tokens_by_user_id(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def delete_refresh_tokens_by_user_id(client, user_id) do
    Tesla.delete(client, @jwt_url <> "/refresh?userId=#{user_id}")
  end

  @spec delete_refresh_token(FusionAuth.client(), String.t()) :: FusionAuth.request()
  def delete_refresh_token(client, token) do
    Tesla.delete(client, @jwt_url <> "/refresh?token=#{token}")
  end

  @spec validate_jwt(FusionAuth.client()) :: FusionAuth.request()
  def validate_jwt(client) do
    Tesla.get(client, @jwt_url <> "/validate") |> FusionAuth.result()
  end
end
