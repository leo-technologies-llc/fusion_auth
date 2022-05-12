# defmodule FusionAuth.TwoFactorTest do
#   use ExUnit.Case

#   alias FusionAuth.TwoFactor
#   alias FusionAuth.Helpers.Mock

#   @api_key "jnx6HeVRrLkulpwiUNh9s52qlJqp5dox77NcDVkf9YI"
#   @tenant_id "d577a020-30cb-85de-bf30-785cb65997d6"
#   @application_id "42b54a1a-e285-41c8-9be0-7fb070c4e3b2"

#   @user_id "fffc8648-bab2-4bdd-b2eb-a48e853d9217"
#   @token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.6hqLDc7-PxHpQRjsdDVt0NcDLcs6ZcoUy5hbwSzMcLM"
#   @code "819169"
#   @delivery "TextMessage"
#   @secret "SP2m6K2Dg/x2JN9DyQvZ"
#   @mobile_phone "2015960074"
#   @two_factor_id "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"

#   @invalid_user_id "123-4567-890"
#   @invalid_token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiIxMjMtNDU2Ny04OTAiLCJleHAiOjE1OTIwMDI4MTQsImlhdCI6MTU5MTk5OTIxNCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJpbnZhbGlkX3VzZXJAZnVzaW9uYXV0aC5pbyIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiYXBwbGljYXRpb25JZCI6IjA5OC03NjU0LTMyMSIsInJvbGVzIjpbXX0.ep-dNlrZrYtI-ogue1T7wZViS0qwtDDj91sUk0CJk2s"
#   @invalid_code "aBcDeFg"

#   @two_factor_url "/api/user/two-factor"
#   @two_factor_send_url "/api/two-factor/send"
#   @two_factor_secret_url "/api/two-factor/secret"

#   setup do
#     application_id = Application.get_env(:fusion_auth, :application_id)
#     client = FusionAuth.client(Mock.base_url(), @api_key, @tenant_id)

#     on_exit(fn ->
#       Application.put_env(:fusion_auth, :application_id, application_id)
#     end)

#     Application.put_env(:fusion_auth, :application_id, @application_id)

#     [client: client]
#   end

#   describe "Enable Two Factor Authentication by User Id" do
#     test "enable_two_factor_by_user_id/5 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "/#{@user_id}",
#         method: :post,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.enable_two_factor_by_user_id(
#                 client,
#                 @user_id,
#                 @code,
#                 @delivery,
#                 @secret
#               )
#     end

#     test "enable_two_factor_by_user_id/5 send a 404 when the user does not exist", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "/#{@invalid_user_id}",
#         method: :post,
#         status: 404,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 404}} =
#               TwoFactor.enable_two_factor_by_user_id(
#                 client,
#                 @invalid_user_id,
#                 @code,
#                 @delivery,
#                 @secret
#               )
#     end

#     test "enable_two_factor_by_user_id/5 send a 421 when code request parameter is not valid", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "/#{@user_id}",
#         method: :post,
#         status: 421,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 421}} =
#               TwoFactor.enable_two_factor_by_user_id(
#                 client,
#                 @user_id,
#                 @invalid_code,
#                 @delivery,
#                 @secret
#               )
#     end
#   end

#   describe "Enable Two Factor Authentication by JWT" do
#     test "enable_two_factor_by_jwt/5 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url,
#         method: :post,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.enable_two_factor_by_jwt(
#                 client,
#                 @token,
#                 @code,
#                 @delivery,
#                 @secret
#               )
#     end

#     test "enable_two_factor_by_jwt/5 send a 404 when the user does not exist", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url,
#         method: :post,
#         status: 404,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 404}} =
#               TwoFactor.enable_two_factor_by_jwt(
#                 client,
#                 @invalid_token,
#                 @code,
#                 @delivery,
#                 @secret
#               )
#     end

#     test "enable_two_factor_by_jwt/5 send a 421 when code request parameter is not valid", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url,
#         method: :post,
#         status: 421,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 421}} =
#               TwoFactor.enable_two_factor_by_jwt(
#                 client,
#                 @token,
#                 @invalid_code,
#                 @delivery,
#                 @secret
#               )
#     end
#   end

#   describe "Disable Two Factor by User Id" do
#     test "disable_two_factor_by_user_id/3 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "/#{@user_id}?code=#{@code}",
#         method: :delete,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.disable_two_factor_by_user_id(
#                 client,
#                 @user_id,
#                 @code
#               )
#     end

#     test "disable_two_factor_by_user_id/3 send a 404 when the user does not exist", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "/#{@invalid_user_id}?code=#{@code}",
#         method: :delete,
#         status: 404,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 404}} =
#               TwoFactor.disable_two_factor_by_user_id(
#                 client,
#                 @invalid_user_id,
#                 @code
#               )
#     end

#     test "disable_two_factor_by_user_id/3 send a 421 when code request parameter is not valid", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "/#{@user_id}?code=#{@invalid_code}",
#         method: :delete,
#         status: 421,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 421}} =
#               TwoFactor.disable_two_factor_by_user_id(
#                 client,
#                 @user_id,
#                 @invalid_code
#               )
#     end
#   end

#   describe "Disable Two Factor by JWT" do
#     test "disable_two_factor_by_jwt/3 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "?code=#{@code}",
#         method: :delete,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.disable_two_factor_by_jwt(
#                 client,
#                 @token,
#                 @code
#               )
#     end

#     test "disable_two_factor_by_jwt/3 send a 404 when the user does not exist", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "?code=#{@code}",
#         method: :delete,
#         status: 404,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 404}} =
#               TwoFactor.disable_two_factor_by_jwt(
#                 client,
#                 @invalid_token,
#                 @code
#               )
#     end

#     test "disable_two_factor_by_jwt/3 send a 421 when code request parameter is not valid", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_url <> "?code=#{@invalid_code}",
#         method: :delete,
#         status: 421,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 421}} =
#               TwoFactor.disable_two_factor_by_jwt(
#                 client,
#                 @token,
#                 @invalid_code
#               )
#     end
#   end

#   describe "Send a Two Factor code to an existing User by Id" do
#     test "send_two_factor_code_by_user_id/3 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_send_url,
#         method: :post,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.send_two_factor_code_by_user_id(
#                 client,
#                 @user_id
#               )
#     end
#   end

#   describe "Send a Two Factor code to a mobile phone" do
#     test "send_two_factor_code_to_mobile_phone/3 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_send_url,
#         method: :post,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.send_two_factor_code_to_mobile_phone(
#                 client,
#                 @mobile_phone,
#                 @secret
#               )
#     end
#   end

#   describe "Send a Two Factor code to complete Two Factor Login" do
#     test "send_two_factor_code_to_complete_login/2 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_send_url <> "/#{@two_factor_id}",
#         method: :post,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.send_two_factor_code_to_complete_login(
#                 client,
#                 @two_factor_id
#               )
#     end
#   end

#   describe "Send a Two Factor code to an authenticated User using a JWT" do
#     test "send_two_factor_code_by_jwt/2 send a 200 on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_send_url,
#         method: :post,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#               TwoFactor.send_two_factor_code_by_jwt(
#                 client,
#                 @token
#               )
#     end
#   end

#   describe "Generate a Two Factor Secret" do
#     test "generate_secret/1 send a 200 along with a JSON body on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_secret_url,
#         method: :get,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} = TwoFactor.generate_secret(client)
#     end
#   end

#   describe "Generate a Two Factor Secret by JWT" do
#     test "generate_secret_for_jwt/2 send a 200 along with a JSON body on successful request", %{client: client} do
#       Mock.mock_request(
#         path: @two_factor_secret_url,
#         method: :get,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} = TwoFactor.generate_secret_for_jwt(client, @token)
#     end
#   end
# end
