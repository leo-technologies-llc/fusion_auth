defmodule FusionAuth.UsersTest do
  use ExUnit.Case

  alias FusionAuth.Users
  alias FusionAuth.TestSupport.Helpers

  setup do
    api_key = "sQ9wwELaI0whHQqyQUxAJmZvVzZqUL-hpfmAmPgbIu8"
    tenant_id = "6b40f9d6-cfd8-4312-bff8-b082ad45e93c"
    client = FusionAuth.client(Helpers.base_url(), api_key, tenant_id)

    {:ok, %{client: client}}
  end

  describe "Get User by ID" do
    test "get_user_by_id/2 returns the user based on the ID", %{client: client} do
      Helpers.mock_request(
        path: "/api/user/06da543e-df3e-4011-b122-a9ff04326599",
        method: :get,
        response: :ok,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Users.get_user_by_id(client, "06da543e-df3e-4011-b122-a9ff04326599")
    end

    test "get_user_by_id/2 returns a 404 status code if the user is not found", %{client: client} do
      Helpers.mock_request(
        path: "/api/user/12345",
        method: :get,
        response: :ok,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404, body: ""}} =
               Users.get_user_by_id(client, "12345")
    end
  end

  describe "Get User by Email" do
    test "get_user_by_email/2 returns the user based on the email", %{client: client} do
      Helpers.mock_request(
        path: "/api/user?email=cogadmin@cogility.com",
        method: :get,
        response: :ok,
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
        path: "/api/user?email=invalid@invalid.com",
        method: :get,
        response: :ok,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Users.get_user_by_email(client, "invalid@invalid.com")
    end
  end

  describe "Get User by Username" do
    test "get_user_by_username/2 returns the user based on the username", %{client: client} do
      Helpers.mock_request(
        path: "/api/user?username=cogadmin",
        method: :get,
        response: :ok,
        status: 200,
        response_body: %{}
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} = Users.get_user_by_username(client, "cogadmin")
    end

    test "get_user_by_username/2 returns a 404 status code if the user is not found", %{
      client: client
    } do
      Helpers.mock_request(
        path: "/api/user?username=invalid",
        method: :get,
        response: :ok,
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
        path: "/api/user",
        method: :post,
        response: :ok,
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
        path: "/api/user",
        method: :post,
        response: :ok,
        status: 400,
        body: user,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.create_user(client, user)
    end
  end

  describe "Update User" do
  end

  describe "Delete User" do
  end

  describe "Bulk Delete Users" do
  end

  describe "Reactivate User" do
  end

  describe "Import Users" do
  end

  describe "Search Users" do
  end

  describe "Get Recent Logins" do
    test "get_recent_logins/1-4 returns the recent logins for the specified user or all users", %{client: client} do
      user_id = "06da543e-df3e-4011-b122-a9ff04326599"

      Helpers.mock_request(
        path: "/api/user/recent-login?userId=#{user_id}",
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
        path: "/api/user/recent-login?userId=#{user_id}",
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
        path: "/api/user/verify_email/#{verification_id}",
        method: :post,
        response: :ok,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} = Users.verify_user_email(client, verification_id)
    end

    test "verify_user_email/2 returns a 400 status code if the request to verify a user email was invalid and/or malformed", %{client: client} do
      verification_id = "abcd"

      Helpers.mock_request(
        path: "/api/user/verify_email/#{verification_id}",
        method: :post,
        response: :ok,
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
        path: "/api/user/verify-email?email=#{email}",
        method: :put,
        response: :ok,
        status: 200,
        response_body: response_body
      )

      assert {:ok, response_body, %Tesla.Env{status: 200}} = Users.resend_verification_email(client, email)
    end

    test "verify_user_email/2 returns a 400 status code if the request to resend a verification email was invalid and/or malformed", %{client: client} do
      email = "cogadmin@cogility.com"
      response_body = %{
        "ERRORS" => "ERRORS"
      }

      Helpers.mock_request(
        path: "/api/user/verify-email?email=#{email}",
        method: :put,
        response: :ok,
        status: 400,
        response_body: response_body
      )

      assert {:error, response_body, %Tesla.Env{status: 400}} = Users.resend_verification_email(client, email)
    end
  end

  describe "Forgot Password" do
  end

  describe "Change Password" do
  end

  describe "Change Password by Identity" do
  end
end
