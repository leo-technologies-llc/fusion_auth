defmodule FusionAuth.UsersTest do
  use FusionAuth.DataCase

  alias FusionAuth.Users
  alias FusionAuth.TestUtilities

  @invalid_id "d6624a85-f006-4f61-825f-0cf3df9ca140"

  @user %{username: "johndoe", password: "password", email: "test@email.com"}
  @user2 %{username: "janedoe", password: "password", email: "second_test@email.com"}

  setup do
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant_with_email_template(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    {:ok, %{client: client_with_tenant}}
  end

  describe "Get User by ID" do
    test "get_user_by_id/2 returns a 200 status code with the user based on the ID", %{
      client: client
    } do
      {:ok, user, _} = Users.create_user(client, @user)

      user_id = user["user"]["id"]

      {:ok, retrieved_user, _} = Users.get_user_by_id(client, user_id)

      retrieved_user_id = retrieved_user["user"]["id"]

      assert user_id == retrieved_user_id
    end

    test "get_user_by_id/2 returns a 404 status code if the user is not found", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404, body: ""}} =
               Users.get_user_by_id(client, @invalid_id)
    end
  end

  describe "Get User by login ID" do
    test "get_user_by_login_id/2 returns a 200 status code with the user based on the login ID",
         %{
           client: client
         } do
      {:ok, user, _} = Users.create_user(client, @user)
      username = user["user"]["username"]

      {:ok, retrieved_user, _} = Users.get_user_by_login_id(client, username)
      retrieved_username = retrieved_user["user"]["username"]

      assert username == retrieved_username
    end

    test "get_user_by_login_id/2 returns a 404 status code if the user is not found", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Users.get_user_by_login_id(client, "invalid@invalid.com")
    end
  end

  describe "Get User by Email" do
    test "get_user_by_email/2 returns a 200 status code with the user based on the email", %{
      client: client
    } do
      {:ok, user, _} = Users.create_user(client, @user)
      email = user["user"]["email"]

      {:ok, retrieved_user, _} = Users.get_user_by_email(client, email)
      retrieved_email = retrieved_user["user"]["email"]

      assert email == retrieved_email
    end

    test "get_user_by_email/2 returns a 404 status code if the user is not found", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Users.get_user_by_email(client, "invalid@invalid.com")
    end
  end

  describe "Get User by Username" do
    test "get_user_by_username/2 returns a 200 status code with the user based on the username",
         %{client: client} do
      {:ok, user, _} = Users.create_user(client, @user)
      username = user["user"]["username"]

      {:ok, retrieved_user, _} = Users.get_user_by_username(client, username)
      retrieved_username = retrieved_user["user"]["username"]

      assert username == retrieved_username
    end

    test "get_user_by_username/2 returns a 404 status code if the user is not found", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} = Users.get_user_by_username(client, "invalid")
    end
  end

  describe "Create User" do
    test "create_user/2 returns the newly created user", %{client: client} do
      {:ok, user, _} = Users.create_user(client, @user)
      username = user["user"]["username"]

      assert username == @user[:username]
    end

    test "create_user/2 returns a 400 status code if the request to create a user was invalid and/or malformed",
         %{client: client} do
      user = %{}

      response_body = %{
        "fieldErrors" => %{
          "user.email" => [
            %{
              "code" => "[blank]user.email",
              "message" =>
                "You must specify either the [user.email] or [user.username] property. If you are emailing the user you must specify the [user.email]."
            }
          ],
          "user.password" => [
            %{
              "code" => "[blank]user.password",
              "message" => "You must specify the [user.password] property."
            }
          ],
          "user.username" => [
            %{
              "code" => "[blank]user.username",
              "message" =>
                "You must specify either the [user.email] or [user.username] property. If you are emailing the user you must specify the [user.email]."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} = Users.create_user(client, user)
    end
  end

  describe "Update User" do
    test "update_user/3 returns a 200 status code with the updated user", %{client: client} do
      new_username = %{username: "updatedjohndoe"}

      {:ok, user, _} = Users.create_user(client, @user)
      user_id = user["user"]["id"]

      {:ok, updated_user, _} = Users.update_user(client, user_id, new_username)
      updated_username = updated_user["user"]["username"]

      assert new_username[:username] == updated_username
    end

    test "update_user/3 returns a 400 status code if the request to update a user was invalid and/or malformed",
         %{client: client} do
      updated_user = %{}

      response_body = %{
        "fieldErrors" => %{
          "user.email" => [
            %{
              "code" => "[blank]user.email",
              "message" =>
                "You must specify either the [user.email] or [user.username] property. If you are emailing the user you must specify the [user.email]."
            }
          ],
          "user.username" => [
            %{
              "code" => "[blank]user.username",
              "message" =>
                "You must specify either the [user.email] or [user.username] property. If you are emailing the user you must specify the [user.email]."
            }
          ]
        }
      }

      {:ok, user, _} = Users.create_user(client, @user)
      user_id = user["user"]["id"]

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Users.update_user(client, user_id, updated_user)
    end
  end

  describe "Delete User" do
    test "delete_user/2 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      {:ok, user, _} = Users.create_user(client, @user)
      user_id = user["user"]["id"]

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.delete_user(client, user_id)
    end

    test "delete_user/2 returns a 404 status code if the user is not found", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} = Users.delete_user(client, @invalid_id)
    end
  end

  describe "Bulk Delete Users" do
    test "bulk_delete_users/3 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      {:ok, user_one, _} = Users.create_user(client, @user)
      {:ok, user_two, _} = Users.create_user(client, @user2)
      user_ids = [user_one["user"]["id"], user_two["user"]["id"]]

      {:ok, response, %Tesla.Env{status: 200}} =
        Users.bulk_delete_users(client, user_ids, hardDelete: true)

      deleted_ids = response["userIds"]

      assert Enum.sort(deleted_ids) == Enum.sort(user_ids)
    end
  end

  describe "Reactivate User" do
    test "reactivate_user/2 returns a 200 status code with the reactivated user", %{
      client: client
    } do
      {:ok, user, _} = Users.create_user(client, @user)
      user_id = user["user"]["id"]

      {:ok, _, _} = Users.delete_user(client, user_id)

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.reactivate_user(client, user_id)
    end
  end

  describe "Import Users" do
    test "import_users/2 returns a 200 status code with an empty body if the request is successful",
         %{client: client} do
      user_one = @user
      user_two = @user2
      users = [user_one, user_two]

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.import_users(client, users)
    end

    test "import_users/2 returns a 400 status code if the request was invalid and/or malformed",
         %{client: client} do
      user_one = %{}
      user_two = %{}
      users = [user_one, user_two]

      response_body = %{
        "fieldErrors" => %{
          "user.email" => [
            %{
              "code" => "[blank]user.email",
              "message" =>
                "You must specify either the [user.email] or [user.username] property for each user."
            }
          ],
          "user.password" => [
            %{
              "code" => "[blank]user.password",
              "message" => "You must specify the [user.password] property for each user."
            }
          ],
          "user.username" => [
            %{
              "code" => "[blank]user.username",
              "message" =>
                "You must specify either the [user.email] or [user.username] property for each user."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} = Users.import_users(client, users)
    end
  end

  describe "Search Users" do
    test "search_users/2 returns a 200 status code with the list of users based on the search criteria",
         %{client: client} do
      Process.sleep(1000)

      query = %{
        "query" => %{
          "match_all" => %{}
        }
      }

      client2 =
        FusionAuth.client("http://172.30.243.114:29200", "", "", [:disable_authorization_headers])

      # Tesla.post(client2, "/fusionauth_user/_refresh", "")
      # Tesla.get(client2, "/fusionauth_user/_search", body: query)
      # Tesla.post(client2, "/fusionauth_user/_delete_by_query", query)
      # Tesla.post(client2, "/fusionauth_user/_refresh", "")
      # Tesla.get(client2, "/fusionauth_user/_search", body: query)

      Users.create_user(client, @user)
      Users.create_user(client, @user2)

      Process.sleep(1000)

      search = %{
        numberOfResults: 10,
        queryString: "",
        sortFields: [
          %{
            name: "username",
            order: "asc"
          }
        ],
        startRow: 0
      }

      {:ok, response, %Tesla.Env{status: 200}} = Users.search_users(client, search)
      assert response["total"] == 2
    end

    test "search_users/2 returns a 400 status code if the request was invalid and/or malformed",
         %{client: client} do
      search = %{
        invalidBody: "invalid"
      }

      response_body = %{
        "generalErrors" => [
          %{
            "code" => "[invalid]",
            "message" => "You must specify either the [ids], [queryString], or [query] property."
          }
        ]
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Users.search_users(client, search)
    end
  end

  describe "Get Recent Logins" do
    test "get_recent_logins/1-4 returns the recent logins for the specified user or all users", %{
      client: client
    } do
      {:ok, user, _} = Users.create_user(client, @user)
      user_id = user["user"]["id"]

      {:ok, recent_logins, %Tesla.Env{status: 200}} =
        Users.get_recent_logins(client, userId: user_id)

      assert Enum.at(recent_logins["logins"], 0)["userId"] == user_id
    end

    test "get_recent_logins/1-4 returns a 404 status code if the user is not found", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Users.get_recent_logins(client, userId: @invalid_id)
    end
  end

  # describe "Verify User Email" do
  #   test "verify_user_email/2 with a verification_id returns a 200 status code with an empty body if the request to verify a user email was successful",
  #        %{client: client} do
  #     verification_id = "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"

  #     Mock.mock_request(
  #       path: @users_url <> "/verify-email/#{verification_id}",
  #       method: :post,
  #       status: 200,
  #       response_body: ""
  #     )

  #     assert {:ok, "", %Tesla.Env{status: 200}} = Users.verify_user_email(client, verification_id)
  #   end

  #   test "verify_user_email/2 returns a 400 status code if the request to verify a user email was invalid and/or malformed",
  #        %{client: client} do
  #     verification_id = "abcd"

  #     Mock.mock_request(
  #       path: @users_url <> "/verify-email/#{verification_id}",
  #       method: :post,
  #       status: 400,
  #       response_body: ""
  #     )

  #     assert {:error, "", %Tesla.Env{status: 400}} =
  #              Users.verify_user_email(client, verification_id)
  #   end
  # end

  # describe "Resend Verification Email" do
  #   test "resend_verification_email/2 with an email returns a 200 status code with a verification_id if the request to resend a verification email was successful",
  #        %{client: client} do
  #     email = "cogadmin@cogility.com"

  #     response_body = %{
  #       "verificationId" => "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
  #     }

  #     Mock.mock_request(
  #       path: @users_url <> "/verify-email?email=#{email}",
  #       method: :put,
  #       status: 200,
  #       response_body: response_body
  #     )

  #     assert {:ok, ^response_body, %Tesla.Env{status: 200}} =
  #              Users.resend_verification_email(client, email)
  #   end

  #   test "verify_user_email/2 returns a 400 status code if the request to resend a verification email was invalid and/or malformed",
  #        %{client: client} do
  #     email = "cogadmin@cogility.com"

  #     response_body = %{
  #       "fieldErrors" => %{}
  #     }

  #     Mock.mock_request(
  #       path: @users_url <> "/verify-email?email=#{email}",
  #       method: :put,
  #       status: 400,
  #       response_body: response_body
  #     )

  #     assert {:error, ^response_body, %Tesla.Env{status: 400}} =
  #              Users.resend_verification_email(client, email)
  #   end
  # end

  describe "Forgot Password" do
    test "forgot_password/2returns a 200 status code with a token and sends a changePasswordID to the user's email if the request was successful",
         %{client: client} do
      Users.create_user(client, @user)

      assert {:ok, %{"changePasswordId" => _}, %Tesla.Env{status: 200}} =
               Users.forgot_password(client, @user[:email])
    end

    test "forgot_password/2 with a username as the login_id returns a 200 status code with a change_password_id if the request was successful",
         %{client: client} do
      Users.create_user(client, @user)

      assert {:ok, %{"changePasswordId" => _}, %Tesla.Env{status: 200}} =
               Users.forgot_password(client, @user[:username])
    end

    test "forgot_password/2 returns a 400 status code if the request was invalid and/or malformed",
         %{client: client} do
      login_id = %{}

      error = %{
        "fieldErrors" => %{
          "loginId" => [
            %{
              "code" => "[invalidJSON]",
              "message" =>
                "Invalid JSON in the request body. The property was [loginId]. The error was [Possible conversion error]. The detailed exception was [Cannot deserialize value of type `java.lang.String` from Object value (token `JsonToken.START_OBJECT`)\n at [Source: (org.apache.catalina.connector.CoyoteInputStream); line: 1, column: 12] (through reference chain: io.fusionauth.domain.api.user.ForgotPasswordRequest[\"loginId\"])]."
            }
          ]
        }
      }

      assert {:error, ^error, %Tesla.Env{status: 400}} = Users.forgot_password(client, login_id)
    end
  end

  describe "Change Password" do
    test "change_password/3 with a change_password_id returns a 200 status code and a one time password if the request was successful",
         %{client: client} do
      Users.create_user(client, @user)

      {:ok, %{"changePasswordId" => change_password_id}, %Tesla.Env{status: 200}} =
        Users.forgot_password(client, @user[:username])

      password_data = %{password: "updated_password"}

      assert {:ok, %{"oneTimePassword" => _}, %Tesla.Env{status: 200}} =
               Users.change_password(client, change_password_id, password_data)
    end

    test "change_password/3 returns a 400 status code if the request was invalid and/or malformed",
         %{client: client} do
      Users.create_user(client, @user)

      {:ok, %{"changePasswordId" => change_password_id}, %Tesla.Env{status: 200}} =
        Users.forgot_password(client, @user[:username])

      password_data = %{}

      error = %{
        "fieldErrors" => %{
          "password" => [
            %{
              "code" => "[blank]password",
              "message" => "You must specify the [password] property."
            }
          ]
        }
      }

      assert {:error, ^error, %Tesla.Env{status: 400}} =
               Users.change_password(client, change_password_id, password_data)
    end
  end

  describe "Change Password by Identity" do
    test "change_password_by_identity/3 with a login_id returns a 200 status code with an empty body if the request was successful",
         %{client: client} do
      Users.create_user(client, @user)

      password_data = %{
        current_password: "password",
        password: "updated_password",
        loginId: "johndoe"
      }

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Users.change_password_by_identity(client, password_data)
    end

    test "change_password_by_identity/3 returns a 400 status code if the request was invalid and/or malformed",
         %{client: client} do
      password_data = %{}

      error = %{
        "generalErrors" => [
          %{
            "code" => "[invalid]",
            "message" =>
              "Your request is invalid. You must call the API with a valid JSON body that includes a changePasswordId, with a valid JWT in the Authorization header or with an API key."
          }
        ]
      }

      assert {:error, ^error, %Tesla.Env{status: 400}} =
               Users.change_password_by_identity(client, password_data)
    end
  end
end
