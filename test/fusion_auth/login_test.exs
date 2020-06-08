defmodule FusionAuth.LoginTest do
  use ExUnit.Case

  alias FusionAuth.Login
  alias FusionAuth.TestSupport.Helpers

  @login_url "/api/login"
  @two_factor_url "/api/two-factor/login"
  @login_search_url "/api/system/login-record/search"

  @application_id Application.get_env(:fustion_auth, :application_id)
  @api_key Application.get_env(:fustion_auth, :api_key)
  @tenant_id Application.get_env(:fustion_auth, :tenant_id)
  @user_id "84846873-89d2-44f8-91e9-dac80f420cb2"
  @login_id "ckempton@cogility.com"
  @password "Rabitt5955"
  @one_time_password "EjdqQI5YSonlAfur4TgVARQAnhhZC0nqZxiqJrwrDi8"

  @login_response %{
    "refreshToken" => "i4HzwC5NsG7DF-Ca7z_yu8hs8FDGuSRyFR4QyBqSzXL8vq59xIsr6w",
    "token" =>
      "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im53bE0zLUZNdm9jVEFPWWlxVXpadDlZNjE1ayJ9.eyJhdWQiOiI4NjFmNTU1OC0zNGE4LTQzZTQtYWI1MC0zMTdiZGNkNDc2NzEiLCJleHAiOjE1OTE2NTk5MjEsImlhdCI6MTU5MTY1NjMyMSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiI4NDg0Njg3My04OWQyLTQ0ZjgtOTFlOS1kYWM4MGY0MjBjYjIiLCJhdXRoZW50aWNhdGlvblR5cGUiOiJQQVNTV09SRCIsImVtYWlsIjoiY2tlbXB0b25AY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInByZWZlcnJlZF91c2VybmFtZSI6ImNrZW1wdG9uIiwiYXBwbGljYXRpb25JZCI6Ijg2MWY1NTU4LTM0YTgtNDNlNC1hYjUwLTMxN2JkY2Q0NzY3MSIsInJvbGVzIjpbImFkbWluIl19.HAR2yqirM_9ztVIJXHvB53bJNCVXMwuirsaof8YUxYAdjskfmfwNBm9fVzU-F3Bgq-xQcIuav6_FX4EYMUZbj3Y0KPL8BJA0Q6so9apneT3E-HyiHh-xaKou7ZImEepKlgk2swTxjM4imjADpoHUKCBqAcdxsEZEP825NtbXEibXdSwd9ssx29USH1WLVS5Fc3Ro4xyUWdgnTYS9zzE02-gKiNGX6U44VMT-NLEnm-XUCv9LRGvgxNAvpl-U8zzWLxfii9njwRJSRHL6ly9EHQqEjr6ZnYTvIIS1v9J0R42bB48qv_5-9syX0hFnU4nA8z00pUyC_RI40NXGY709lg",
    "user" => %{}
  }

  @search_response %{
    "logins" => [
      %{
        "applicationId" => "861f5558-34a8-43e4-ab50-317bdcd47671",
        "applicationName" => "Development",
        "instant" => 1_591_657_456_684,
        "ipAddress" => "0.0.0.0",
        "loginId" => "ckempton@cogility.com",
        "userId" => "84846873-89d2-44f8-91e9-dac80f420cb2"
      }
    ]
  }

  @invalid_one_time_passord_response %{
    "fieldErrors" => %{
      "oneTimePassword" => [
        %{
          "code" => "[invalid]oneTimePassword",
          "message" => "Invalid [oneTimePassword] property."
        }
      ]
    }
  }

  setup do
    client = FusionAuth.client()
    [client: client]
  end

  describe "login_user/3" do
    test "can login user", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      assert {:ok, @login_response, %Tesla.Env{status: 200}} =
               Login.login_user(client, @login_id, @password)
    end

    test "user not found", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} = Login.login_user(client, @login_id, "test")
    end
  end

  describe "login_user/4" do
    test "can login user with additional options", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      {:ok, @login_response, %Tesla.Env{status: 200}} =
        Login.login_user(client, @login_id, @password, %{ipAddress: "0.0.0.0"})
    end

    test "can login user with application_id", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      {:ok, @login_response, %Tesla.Env{status: 200}} =
        Login.login_user(client, @application_id, @login_id, @password)
    end
  end

  describe "login_user/5" do
    test "nil application_id does not return a refreshToken", %{client: client} do
      modified_response = Map.drop(@login_response, ["refreshToken"])

      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: modified_response
      )

      assert {:ok, ^modified_response, %Tesla.Env{status: 200}} =
               Login.login_user(client, nil, @login_id, @password, %{})
    end

    test "with all valid attributes", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      assert {:ok, @login_response, %Tesla.Env{status: 200}} =
               Login.login_user(client, @application_id, @login_id, @password, %{
                 ipAddress: "0.0.0.0"
               })
    end
  end

  describe "login_one_time_password/2" do
    test "invalid one_time_passowrd", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 400,
        response_body: @invalid_one_time_passord_response
      )

      assert {:error, @invalid_one_time_passord_response, %Tesla.Env{status: 400}} =
               Login.login_one_time_password(client, @one_time_password)
    end

    test "valid one_time_passowrd", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      assert {:ok, @login_response, %Tesla.Env{status: 200}} =
               Login.login_one_time_password(client, @one_time_password)
    end
  end

  describe "two_factor_login/3" do
    test "can login using 2FA", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      assert {:ok, @login_response, %Tesla.Env{status: 200}} =
               Login.two_factor_login(
                 client,
                 "12345",
                 "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
               )
    end

    test "invalid 2FA attempt", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 404,
        response_body: ""
      )

      assert {:error, "", %Tesla.Env{status: 404}} =
               Login.two_factor_login(
                 client,
                 "12345",
                 "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
               )
    end
  end

  describe "two_factor_login/4" do
    test "can login using 2FA with specified application_id", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @login_response
      )

      assert {:ok, @login_response, %Tesla.Env{status: 200}} =
               Login.two_factor_login(
                 client,
                 @application_id,
                 "12345",
                 "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4"
               )
    end
  end

  describe "two_factor_login/5" do
    test "response will not have refresh token in no application_id", %{client: client} do
      modified_response = Map.drop(@login_response, ["refreshToken"])

      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: modified_response
      )

      assert {:ok, ^modified_response, %Tesla.Env{status: 200}} =
               Login.two_factor_login(
                 client,
                 nil,
                 "12345",
                 "YkQY5Gsyo4RlfmDciBGRmvfj3RmatUqrbjoIZ19fmw4",
                 %{}
               )
    end
  end

  describe "update_login_instant/2" do
    test "can record user login manually", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id
               )
    end
  end

  describe "update_login_instant/3" do
    test "can record user login manually", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id,
                 @application_id
               )
    end
  end

  describe "update_login_instant/4" do
    test "can record user login manually", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: ""
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Login.update_login_instant(
                 client,
                 @user_id,
                 @application_id,
                 "0.0.0.0"
               )
    end
  end

  describe "search/2" do
    test "can search logins", %{client: client} do
      Helpers.mock_request(
        path: @login_url,
        method: :post,
        status: 200,
        response_body: @search_response
      )

      assert {:ok, @search_response, %Tesla.Env{status: 200}} =
               Login.search(
                 client,
                 %{
                   userId: @user_id,
                   applicationId: @application_id,
                   start: 1_591_657_456_684,
                   end: 1_591_657_456_685
                 }
               )
    end
  end
end
