# defmodule FusionAuth.RegistrationsTest do
#   use ExUnit.Case

#   alias FusionAuth.Registrations
#   alias FusionAuth.TestSupport.Helpers

#   @registrations_url "/api/user/registration"
#   @verify_registration_url "/api/user/verify-registration"

#   setup do
#     api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
#     tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
#     client = FusionAuth.client(Helpers.base_url(), api_key, tenant_id)
#     app_id = "42b54a1a-e285-41c8-9be0-7fb070c4e3b2"
#     user_id = "06da543e-df3e-4011-b122-a9ff04326599"
#     [client: client, app_id: app_id, user_id: user_id]
#   end

#   describe "Create a user registration for an existing user" do
#     test "create_user_registration/3 returns a 200 status code based on an existing user id", %{
#       client: client,
#       app_id: app_id,
#       user_id: user_id
#     } do
#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheIronManStark"}
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/#{user_id}",
#         method: :post,
#         status: 200,
#         body: data,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#                Registrations.create_user_registration(
#                  client,
#                  user_id,
#                  data
#                )
#     end

#     test "create_user_registration/3 returns a 400 status code if the applicationId is invalid or not passed",
#          %{client: client, user_id: user_id} do
#       data = %{
#         registration: %{
#           data: %{displayName: "TonyTheIronManStark"}
#         }
#       }

#       response_body = %{
#         "fieldErrors" => %{
#           "registration.applicationId" => [
#             %{
#               "code" => "[missing]registration.applicationId",
#               "message" => "You must specify the [registration.applicationId] property."
#             }
#           ]
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/#{user_id}",
#         method: :post,
#         status: 400,
#         data: data,
#         response_body: response_body
#       )

#       assert {:error, response_body, %Tesla.Env{status: 400, body: response_body}} ==
#                Registrations.create_user_registration(
#                  client,
#                  user_id,
#                  data
#                )
#     end

#     test "create_user_registration/3 returns a 500 status code for general errors",
#          %{client: client, app_id: app_id} do
#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheIronManStark"}
#         }
#       }

#       response_body = %{
#         "generalErrors" => [
#           %{
#             "code" => "[Exception]",
#             "message" =>
#               "FusionAuth encountered an unexpected error. Please contact support for assistance."
#           }
#         ]
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/123456",
#         method: :post,
#         status: 500,
#         data: data,
#         response_body: response_body
#       )

#       assert {:error, response_body, %Tesla.Env{status: 500, body: response_body}} ==
#                Registrations.create_user_registration(
#                  client,
#                  "123456",
#                  data
#                )
#     end
#   end

#   describe "Create a user and registration" do
#     test "create_user_and_registration/2 creates the user and registration", %{
#       client: client,
#       app_id: app_id
#     } do
#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheIronManStark"}
#         },
#         user: %{
#           username: "tony_stark",
#           password: "ironmanRIP2019",
#           email: "tonystark@stark.com"
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url,
#         method: :post,
#         status: 200,
#         body: data,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#                Registrations.create_user_and_registration(
#                  client,
#                  data
#                )
#     end

#     test "create_user_and_registration/3 creates the user and registration given a self provided UUID",
#          %{
#            client: client,
#            app_id: app_id,
#            user_id: user_id
#          } do
#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheIronManStark"}
#         },
#         user: %{
#           username: "tony_stark",
#           password: "ironmanRIP2019",
#           email: "tonystark@stark.com"
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/#{user_id}",
#         method: :post,
#         status: 200,
#         body: data,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#                Registrations.create_user_and_registration(
#                  client,
#                  data,
#                  user_id
#                )
#     end

#     test "create_user_and_registration/2 returns status code 400 if user object is not in the request body",
#          %{client: client, app_id: app_id} do
#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheIronManStark"}
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url,
#         method: :post,
#         status: 400,
#         body: data,
#         response_body: %{}
#       )

#       assert {:error, %{}, %Tesla.Env{status: 400}} =
#                Registrations.create_user_and_registration(
#                  client,
#                  data
#                )
#     end
#   end

#   describe "Retrive a user registration" do
#     test "get_user_registration/3 returns 200 status code for a successful request", %{
#       client: client,
#       app_id: app_id,
#       user_id: user_id
#     } do
#       Helpers.mock_request(
#         path: @registrations_url <> "/#{user_id}/#{app_id}",
#         method: :get,
#         status: 200,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#                Registrations.get_user_registration(
#                  client,
#                  user_id,
#                  app_id
#                )
#     end

#     test "get_user_registration/3 returns 400 status code for invalid application id", %{
#       client: client,
#       user_id: user_id
#     } do
#       resp_body = %{
#         "fieldErrors" => %{
#           "applicationId" => [
#             %{
#               "code" => "[couldNotConvert]applicationId",
#               "message" =>
#                 "Invalid applicationId [12345]. This must be a valid UUID String (e.g. 25a872da-bb44-4af8-a43d-e7bcb5351ebc)."
#             },
#             %{
#               "code" => "[missing]applicationId",
#               "message" => "The Id of the Application was not specified on the URL."
#             }
#           ]
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/#{user_id}/12345",
#         method: :get,
#         status: 400,
#         response_body: resp_body
#       )

#       assert {:error, resp_body, %Tesla.Env{status: 400, body: resp_body}} ==
#                Registrations.get_user_registration(
#                  client,
#                  user_id,
#                  "12345"
#                )
#     end

#     test "get_user_registration/3 returns 400 status code for invalid user id", %{
#       client: client,
#       app_id: app_id
#     } do
#       resp_body = %{
#         "fieldErrors" => %{
#           "userId" => [
#             %{
#               "code" => "[couldNotConvert]userId",
#               "message" =>
#                 "Invalid userId [12345]. This must be a valid UUID String (e.g. 25a872da-bb44-4af8-a43d-e7bcb5351ebc)."
#             },
#             %{
#               "code" => "[missing]userId",
#               "message" => "The Id of the User was not specified on the URL."
#             }
#           ]
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/12345/#{app_id}",
#         method: :get,
#         status: 400,
#         response_body: resp_body
#       )

#       assert {:error, resp_body, %Tesla.Env{status: 400, body: resp_body}} ==
#                Registrations.get_user_registration(
#                  client,
#                  "12345",
#                  app_id
#                )
#     end
#   end

#   describe "Update a user registration" do
#     test "update_user_registration/3 returns 200 status code for a successful request", %{
#       client: client,
#       app_id: app_id,
#       user_id: user_id
#     } do
#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheRIPIronManStark"}
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url,
#         method: :put,
#         status: 200,
#         body: data,
#         response_body: %{}
#       )

#       assert {:ok, %{}, %Tesla.Env{status: 200}} =
#                Registrations.update_user_registration(
#                  client,
#                  user_id,
#                  data
#                )
#     end

#     test "update_user_registration/3 returns 404 status code for user that is not found", %{
#       client: client,
#       app_id: app_id
#     } do
#       not_found_user_id = "fd7857a7-166a-4043-a1ee-026499d0cce6"

#       data = %{
#         registration: %{
#           applicationId: app_id,
#           data: %{displayName: "TonyTheRIPIronManStark"}
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url,
#         method: :put,
#         status: 404,
#         body: data,
#         response_body: ""
#       )

#       assert {:error, "", %Tesla.Env{status: 404}} =
#                Registrations.update_user_registration(
#                  client,
#                  not_found_user_id,
#                  data
#                )
#     end

#     test "update_user_registration/3 returns 400 status code for malformed request", %{
#       client: client,
#       user_id: user_id
#     } do
#       resp_body = %{
#         "fieldErrors" => %{
#           "registration.applicationId" => [
#             %{
#               "code" => "[missing]registration.applicationId",
#               "message" => "You must specify the [registration.applicationId] property."
#             }
#           ]
#         }
#       }

#       data = %{
#         registration: %{
#           data: %{displayName: "TonyTheRIPIronManStark"}
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url,
#         method: :put,
#         status: 400,
#         body: data,
#         response_body: resp_body
#       )

#       assert {:error, resp_body, %Tesla.Env{status: 400, body: resp_body}} ==
#                Registrations.update_user_registration(
#                  client,
#                  user_id,
#                  data
#                )
#     end
#   end

#   describe "Delete a user registration" do
#     test "delete_user_registration/3 returns 200 status code for successful request", %{
#       client: client,
#       app_id: app_id,
#       user_id: user_id
#     } do
#       Helpers.mock_request(
#         path: @registrations_url <> "/#{user_id}/#{app_id}",
#         method: :delete,
#         status: 200,
#         response_body: ""
#       )

#       assert {:ok, "", %Tesla.Env{status: 200, body: ""}} ==
#                Registrations.delete_user_registration(
#                  client,
#                  user_id,
#                  app_id
#                )
#     end

#     test "delete_user_registration/3 returns 404 status code for user not found request", %{
#       client: client,
#       app_id: app_id
#     } do
#       not_found_user_id = "fd7857a7-166a-4043-a1ee-026499d0cce6"

#       Helpers.mock_request(
#         path: @registrations_url <> "/#{not_found_user_id}/#{app_id}",
#         method: :delete,
#         status: 404,
#         response_body: ""
#       )

#       assert {:error, "", %Tesla.Env{status: 404, body: ""}} ==
#                Registrations.delete_user_registration(
#                  client,
#                  not_found_user_id,
#                  app_id
#                )
#     end

#     test "delete_user_registration/3 returns 400 status code for malformed request", %{
#       client: client,
#       app_id: app_id
#     } do
#       resp_body = %{
#         "fieldErrors" => %{
#           "userId" => [
#             %{
#               "code" => "[couldNotConvert]userId",
#               "message" =>
#                 "Invalid userId [12345]. This must be a valid UUID String (e.g. 25a872da-bb44-4af8-a43d-e7bcb5351ebc)."
#             },
#             %{
#               "code" => "[missing]userId",
#               "message" => "The Id of the User was not specified on the URL."
#             }
#           ]
#         }
#       }

#       Helpers.mock_request(
#         path: @registrations_url <> "/12345/#{app_id}",
#         method: :delete,
#         status: 400,
#         response_body: resp_body
#       )

#       assert {:error, resp_body, %Tesla.Env{status: 400, body: resp_body}} ==
#                Registrations.delete_user_registration(
#                  client,
#                  "12345",
#                  app_id
#                )
#     end
#   end

#   describe "Verify a user registration" do
#     test "verify_user_registration/2 returns 200 status code for successful request", %{
#       client: client
#     } do
#       Helpers.mock_request(
#         path: @verify_registration_url,
#         method: :post,
#         status: 200,
#         response_body: ""
#       )

#       assert {:ok, "", %Tesla.Env{status: 200, body: ""}} ==
#                Registrations.verify_user_registration(
#                  client,
#                  "good-code"
#                )
#     end

#     test "verify_user_registration/2 returns 404 status code for invalid request", %{
#       client: client
#     } do
#       Helpers.mock_request(
#         path: @verify_registration_url,
#         method: :post,
#         status: 404,
#         response_body: ""
#       )

#       assert {:error, "", %Tesla.Env{status: 404, body: ""}} ==
#                Registrations.verify_user_registration(
#                  client,
#                  "bad-code"
#                )
#     end
#   end

#   describe "Resend a user registration verification email" do
#     test "resend_user_registration_verification_email/3 returns 200 status code for successful request",
#          %{
#            client: client,
#            app_id: app_id
#          } do
#       resp_body = %{
#         "verificationId" => "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
#       }

#       Helpers.mock_request(
#         path: @verify_registration_url,
#         method: :post,
#         status: 200,
#         response_body: resp_body
#       )

#       assert {:ok, resp_body, %Tesla.Env{status: 200, body: resp_body}} ==
#                Registrations.resend_user_registration_verification_email(
#                  client,
#                  app_id,
#                  "tonystark@stark.com"
#                )
#     end

#     test "resend_user_registration_verification_email/3 returns 400 status code for malformed request",
#          %{
#            client: client
#          } do
#       resp_body = %{
#         "fieldErrors" => %{
#           "applicationId" => [
#             %{
#               "code" => "[couldNotConvert]applicationId",
#               "message" => "Invalid UUID"
#             },
#             %{
#               "code" => "[missing]applicationId",
#               "message" => "You must specify the [applicationId] as a parameter."
#             }
#           ]
#         }
#       }

#       Helpers.mock_request(
#         path: @verify_registration_url,
#         method: :post,
#         status: 400,
#         response_body: resp_body
#       )

#       assert {:error, resp_body, %Tesla.Env{status: 400, body: resp_body}} ==
#                Registrations.resend_user_registration_verification_email(
#                  client,
#                  "invalid-app-id",
#                  "tonystark@stark.com"
#                )
#     end
#   end
# end
