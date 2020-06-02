defmodule FusionAuth.UsersTest do
  use ExUnit.Case

  alias FusionAuth.Users
  alias FusionAuth.TestSupport.Helpers

  @users_url "/api/user"

  setup do
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    client = FusionAuth.client(Helpers.base_url(), api_key, tenant_id)

    {:ok, %{client: client}}
  end

  describe "Get User by ID" do
    test "get_user_by_id/2 returns a 200 status code with the user based on the ID", %{client: client} do
      Helpers.mock_request(
        path: @users_url <> "/06da543e-df3e-4011-b122-a9ff04326599",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Users.get_user_by_id(client, "06da543e-df3e-4011-b122-a9ff04326599")
    end

    test "get_user_by_id/2 returns a 404 status code if the user is not found", %{client: client} do
      Helpers.mock_request(
        path: @users_url <> "/12345",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404, body: ""}} =
               Users.get_user_by_id(client, "12345")
    end
  end

  describe "Get User by Email" do
    test "get_user_by_email/2 returns a 200 status code with the user based on the email", %{client: client} do
      Helpers.mock_request(
        path: @users_url <> "?email=cogadmin@cogility.com",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Users.get_user_by_email(client, "cogadmin@cogility.com")
    end

    test "get_user_by_email/2 returns a 404 status code if the user is not found", %{
      client: client
    } do
      Helpers.mock_request(
        path: @users_url <> "?email=invalid@invalid.com",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Users.get_user_by_email(client, "invalid@invalid.com")
    end
  end

  describe "Get User by Username" do
    test "get_user_by_username/2 returns a 200 status code with the user based on the username", %{client: client} do
      Helpers.mock_request(
        path: @users_url <> "?username=cogadmin",
        method: :get,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.get_user_by_username(client, "cogadmin")
    end

    test "get_user_by_username/2 returns a 404 status code if the user is not found", %{
      client: client
    } do
      Helpers.mock_request(
        path: @users_url <> "?username=invalid",
        method: :get,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} = Users.get_user_by_username(client, "invalid")
    end
  end

  describe "Create User" do
    test "create_user/2 returns the newly created user", %{client: client} do
      user = %{username: "johndoe", password: "password"}

      Helpers.mock_request(
        path: @users_url,
        method: :post,
        status: 200,
        body: user,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.create_user(client, user)
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

      Helpers.mock_request(
        path: @users_url,
        method: :post,
        status: 400,
        body: user,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.create_user(client, user)
    end
  end

  describe "Update User" do
    test "update_user/3 returns a 200 status code with the updated user", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"
      updated_user = %{username: "updatedjohndoe"}

      Helpers.mock_request(
        path: @users_url <> "/#{user_id}",
        method: :patch,
        status: 200,
        body: updated_user,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.update_user(client, user_id, updated_user)
    end

    test "update_user/3 returns a 400 status code if the request to update a user was invalid and/or malformed", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"
      updated_user = %{}
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @users_url <> "/#{user_id}",
        method: :patch,
        status: 400,
        body: updated_user,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.update_user(client, user_id, updated_user)
    end
  end

  describe "Delete User" do
    test "delete_user/2 returns a 200 status code with an empty body if the request is successful", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"

      Helpers.mock_request(
        path: @users_url <> "/#{user_id}",
        method: :delete,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.delete_user(client, user_id)
    end

    test "delete_user/2 returns a 404 status code if the user is not found", %{client: client} do
      user_id = "abcde"

      Helpers.mock_request(
        path: @users_url <> "/#{user_id}",
        method: :delete,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} = Users.delete_user(client, user_id)
    end
  end

  describe "Bulk Delete Users" do
    test "bulk_delete_users/2 returns a 200 status code with an empty body if the request is successful", %{client: client} do
      user_one = "00000000-0000-0001-0000-000000000000"
      user_two = "00000000-0000-0001-0000-000000000001"
      user_ids = [user_one, user_two]
      response_body = %{
        "dryRun" => false,
        "hardDelete" => false,
        "total" => 2,
        "userIds" => user_ids
      }

      Helpers.mock_request(
        path: @users_url <> "/bulk?userId=#{user_one}&userId=#{user_two}",
        method: :delete,
        status: 200,
        response_body: response_body
      )

      assert {:ok, response_body, %Tesla.Env{status: 200}} = Users.bulk_delete_users(client, user_ids)
    end

    test "bulk_delete_users/2 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      user_one = "00000000-0000-0001-0000-000000000000"
      user_two = "00000000-0000-0001-0000-000000000001"
      user_ids = [user_one, user_two]
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @users_url <> "/bulk?invalidQp=invalid",
        method: :delete,
        status: 400,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.bulk_delete_users(client, user_ids)
    end
  end

  describe "Reactivate User" do
    test "reactivate_user/2 returns a 200 status code with the reactivated user", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"

      Helpers.mock_request(
        path: @users_url <> "/#{user_id}?reactivate=true",
        method: :put,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.reactivate_user(client, user_id)
    end

    test "reactivate_user/2 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @users_url <> "/#{user_id}?invalidQp=invalid",
        method: :put,
        status: 400,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.reactivate_user(client, user_id)
    end
  end

  describe "Import Users" do
    test "import_users/2 returns a 200 status code with an empty body if the request is successful", %{client: client} do
      user_one = %{username: "userone"}
      user_two = %{username: "usertwo"}
      users = [user_one, user_two]

      Helpers.mock_request(
        path: @users_url <> "/import",
        method: :post,
        status: 200,
        body: users,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.import_users(client, users)
    end

    test "import_users/2 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      user_one = %{}
      user_two = %{}
      users = [user_one, user_two]
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @users_url <> "/import",
        method: :post,
        status: 400,
        body: users,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.import_users(client, users)
    end
  end

  describe "Search Users" do
    test "search_users/2 returns a 200 status code with the list of users based on the search criteria", %{client: client} do
      search = %{
        numberOfResults: 10,
        queryString: "tenantId:6b40f9d6-cfd8-4312-bff8-b082ad45e93c",
        sortFields: [
          %{
            missing: "_first",
            name: "email",
            order: "asc"
          }
        ],
        startRow: 0
      }

      Helpers.mock_request(
        path: @users_url <> "/search",
        method: :post,
        status: 200,
        body: search,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.search_users(client, search)
    end

    test "search_users/2 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      search = %{
        invalidBody: "invalid"
      }
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @users_url <> "/search",
        method: :post,
        status: 400,
        body: search,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.search_users(client, search)
    end
  end

  describe "Get Recent Logins" do
    test "get_recent_logins/1-4 returns the recent logins for the specified user or all users", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"

      Helpers.mock_request(
        path: @users_url <> "/recent-login?userId=#{user_id}",
        method: :get,
        response: :ok,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.get_recent_logins(client, user_id)
    end

    test "get_recent_logins/1-4 returns a 404 status code if the user is not found", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"

      Helpers.mock_request(
        path: @users_url <> "/recent-login?userId=#{user_id}",
        method: :get,
        response: :ok,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} = Users.get_recent_logins(client, user_id)
    end
  end

  describe "Verify User Email" do
    test "verify_user_email/2 with a verification_id returns a 200 status code with an empty body if the request to verify a user email was successful", %{client: client} do
      verification_id = "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"

      Helpers.mock_request(
        path: @users_url <> "/verify_email/#{verification_id}",
        method: :post,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.verify_user_email(client, verification_id)
    end

    test "verify_user_email/2 returns a 400 status code if the request to verify a user email was invalid and/or malformed", %{client: client} do
      verification_id = "abcd"

      Helpers.mock_request(
        path: @users_url <> "/verify_email/#{verification_id}",
        method: :post,
        status: 400,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 400}} = Users.verify_user_email(client, verification_id)
    end
  end

  describe "Resend Verification Email" do
    test "resend_verification_email/2 with an email returns a 200 status code with a verification_id if the request to resend a verification email was successful", %{client: client} do
      email = "cogadmin@cogility.com"
      response_body = %{
        "verificationId" => "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
      }

      Helpers.mock_request(
        path: @users_url <> "/verify-email?email=#{email}",
        method: :put,
        status: 200,
        response_body: response_body
      )

      assert {:ok, response_body, %Tesla.Env{status: 200}} = Users.resend_verification_email(client, email)
    end

    test "verify_user_email/2 returns a 400 status code if the request to resend a verification email was invalid and/or malformed", %{client: client} do
      email = "cogadmin@cogility.com"
      response_body = %{
        "fieldErrors" => %{}
      }

      Helpers.mock_request(
        path: @users_url <> "/verify-email?email=#{email}",
        method: :put,
        status: 400,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.resend_verification_email(client, email)
    end
  end

  describe "Forgot Password" do
    test "forgot_password/2 with an email as the login_id returns a 200 status code with a change_password_id if the request was successful", %{client: client} do
      login_id = "cogadmin@cogility.com"
      response_body = %{
        "changePasswordId" => "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
      }

      Helpers.mock_request(
        path: @users_url <> "/forgot-password",
        method: :post,
        status: 200,
        response_body: response_body
      )

      assert {:ok, response_body, %Tesla.Env{status: 200}} = Users.forgot_password(client, login_id)
    end

    test "forgot_password/2 with a username as the login_id returns a 200 status code with a change_password_id if the request was successful", %{client: client} do
      login_id = "cogadmin"
      response_body = %{
        "changePasswordId" => "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
      }

      Helpers.mock_request(
        path: @users_url <> "/forgot-password",
        method: :post,
        status: 200,
        response_body: response_body
      )

      assert {:ok, response_body, %Tesla.Env{status: 200}} = Users.forgot_password(client, login_id)
    end

    test "forgot_password/2 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      login_id = "12345"

      Helpers.mock_request(
        path: @users_url <> "/forgot-password",
        method: :post,
        status: 400,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 400}} = Users.forgot_password(client, login_id)
    end
  end

  describe "Change Password" do
    test "change_password/3 with a change_password_id returns a 200 status code with an empty body if the request was successful", %{client: client} do
      change_password_id = "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
      password_data = %{current_password: "hello", password: "updated"}

      Helpers.mock_request(
        path: @users_url <> "/change-password/#{change_password_id}",
        method: :post,
        status: 200,
        body: password_data,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.change_password(client, change_password_id, password_data)
    end

    test "change_password/3 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      change_password_id = "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
      password_data = %{}

      Helpers.mock_request(
        path: @users_url <> "/change-password/#{change_password_id}",
        method: :post,
        status: 400,
        body: password_data,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 400}} = Users.change_password(client, change_password_id, password_data)
    end
  end

  describe "Change Password by Identity" do
    test "change_password_by_identity/3 with a login_id returns a 200 status code with an empty body if the request was successful", %{client: client} do
      password_data = %{current_password: "hello", password: "updated", loginId: "cogadmin@cogility.com"}

      Helpers.mock_request(
        path: @users_url <> "/change-password",
        method: :post,
        status: 200,
        body: password_data,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.change_password_by_identity(client, password_data)
    end

    test "change_password_by_identity/3 returns a 400 status code if the request was invalid and/or malformed", %{client: client} do
      password_data = %{}

      Helpers.mock_request(
        path: @users_url <> "/change-password",
        method: :post,
        status: 400,
        body: password_data,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 400}} = Users.change_password_by_identity(client, password_data)
    end
  end
end
