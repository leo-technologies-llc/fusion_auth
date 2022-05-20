defmodule FusionAuth.RegistrationsTest do
  use FusionAuth.DataCase

  alias FusionAuth.Registrations
  alias FusionAuth.TestUtilities
  alias FusionAuth.Users

  @application_id "7d47523b-057d-4f91-b159-f196f9dbe7c9"
  @user_id "12104852-f534-475e-9332-9fc3c37432b8"
  @template_id "9422d384-de6f-4890-8ff0-de139f6aaebd"
  @user %{
    username: "TonyTheIronManStark",
    password: "pepperpotts",
    email: "ironman@avengers.com"
  }

  setup do
    base_url = Application.get_env(:fusion_auth, :test_url)
    api_key = Application.get_env(:fusion_auth, :api_key)
    tenant_id = Application.get_env(:fusion_auth, :tenant_id)

    client = FusionAuth.client(base_url, api_key, "")
    TestUtilities.create_tenant(client, tenant_id)
    client_with_tenant = FusionAuth.client(base_url, api_key, tenant_id)

    TestUtilities.create_application_with_id(client_with_tenant, @application_id)

    TestUtilities.enable_registration_verification(
      client_with_tenant,
      @application_id,
      @template_id
    )

    Users.create_user_with_id(
      client_with_tenant,
      @user,
      @user_id
    )

    {:ok, %{client: client}}
  end

  describe "Create a user registration for an existing user" do
    test "create_user_registration/3 returns a 200 status code based on an existing user id", %{
      client: client
    } do
      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheIronManStark"}
        }
      }

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Registrations.create_user_registration(
                 client,
                 @user_id,
                 data
               )
    end

    test "create_user_registration/3 returns a 400 status code if the applicationId is invalid or not passed",
         %{client: client} do
      data = %{
        registration: %{
          data: %{displayName: "TonyTheIronManStark"}
        }
      }

      response_body = %{
        "fieldErrors" => %{
          "registration.applicationId" => [
            %{
              "code" => "[missing]registration.applicationId",
              "message" => "You must specify the [registration.applicationId] property."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Registrations.create_user_registration(
                 client,
                 @user_id,
                 data
               )
    end

    test "create_user_registration/3 returns a 400 if the user doesn't exist",
         %{client: client} do
      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheIronManStark"}
        }
      }

      response_body = %{
        "fieldErrors" => %{
          "userId" => [
            %{
              "code" => "[invalid]userId",
              "message" =>
                "The user with Id [00000000-0000-0000-0000-00000001e240] does not exist."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Registrations.create_user_registration(
                 client,
                 "123456",
                 data
               )
    end
  end

  describe "Create a user and registration" do
    test "create_user_and_registration/2 creates the user and registration", %{client: client} do
      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheIronManStark"}
        },
        user: %{
          username: "tony_stark",
          password: "ironmanRIP2019",
          email: "tonystark@stark.com"
        }
      }

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Registrations.create_user_and_registration(
                 client,
                 data
               )
    end

    test "create_user_and_registration/3 creates the user and registration given a self provided UUID",
         %{
           client: client
         } do
      user_id = "01e81e42-bb06-4e80-a370-a38eedc24dda"

      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheIronManStark"}
        },
        user: %{
          username: "tony_stark",
          password: "ironmanRIP2019",
          email: "tonystark@stark.com"
        }
      }

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Registrations.create_user_and_registration(
                 client,
                 data,
                 user_id
               )
    end

    test "create_user_and_registration/2 returns status code 400 if user object is not in the request body",
         %{client: client} do
      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheIronManStark"}
        }
      }

      response_body = %{
        "fieldErrors" => %{
          "userId" => [
            %{
              "code" => "[missing]userId",
              "message" => "The Id of the User was not specified on the URL."
            }
          ]
        }
      }

      assert {:error, ^response_body, %Tesla.Env{status: 400}} =
               Registrations.create_user_and_registration(
                 client,
                 data
               )
    end
  end

  describe "Retrive a user registration" do
    test "get_user_registration/3 returns 200 status code for a successful request", %{
      client: client
    } do
      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheIronManStark"}
        }
      }

      Registrations.create_user_registration(
        client,
        @user_id,
        data
      )

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Registrations.get_user_registration(
                 client,
                 @user_id,
                 @application_id
               )
    end

    test "get_user_registration/3 returns 404 status code for invalid application id", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Registrations.get_user_registration(
                 client,
                 @user_id,
                 "12345"
               )
    end

    test "get_user_registration/3 returns 404 status code for invalid user id", %{client: client} do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Registrations.get_user_registration(
                 client,
                 "12345",
                 @application_id
               )
    end
  end

  describe "Update a user registration" do
    test "update_user_registration/3 returns 200 status code for a successful request", %{
      client: client
    } do
      current_data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "Tony Stark"}
        }
      }

      Registrations.create_user_registration(
        client,
        @user_id,
        current_data
      )

      updated_data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheRIPIronManStark"}
        }
      }

      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Registrations.update_user_registration(
                 client,
                 @user_id,
                 updated_data
               )
    end

    test "update_user_registration/3 returns 404 status code for user that is not found", %{
      client: client
    } do
      not_found_user_id = "fd7857a7-166a-4043-a1ee-026499d0cce6"

      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "TonyTheRIPIronManStark"}
        }
      }

      assert {:error, "", %Tesla.Env{status: 404}} =
               Registrations.update_user_registration(
                 client,
                 not_found_user_id,
                 data
               )
    end

    test "update_user_registration/3 returns 400 status code for malformed request", %{
      client: client
    } do
      resp_body = %{
        "fieldErrors" => %{
          "registration.applicationId" => [
            %{
              "code" => "[missing]registration.applicationId",
              "message" => "You must specify the [registration.applicationId] property."
            }
          ]
        }
      }

      data = %{
        registration: %{
          data: %{displayName: "TonyTheRIPIronManStark"}
        }
      }

      assert {:error, ^resp_body, %Tesla.Env{status: 400}} =
               Registrations.update_user_registration(
                 client,
                 @user_id,
                 data
               )
    end
  end

  describe "Delete a user registration" do
    test "delete_user_registration/3 returns 200 status code for successful request", %{
      client: client
    } do
      data = %{
        registration: %{
          applicationId: @application_id,
          data: %{displayName: "Tony Stark"}
        }
      }

      Registrations.create_user_registration(
        client,
        @user_id,
        data
      )

      assert {:ok, "", %Tesla.Env{status: 200}} =
               Registrations.delete_user_registration(
                 client,
                 @user_id,
                 @application_id
               )
    end

    test "delete_user_registration/3 returns 404 status code for user not found request", %{
      client: client
    } do
      not_found_user_id = "fd7857a7-166a-4043-a1ee-026499d0cce6"

      assert {:error, "", %Tesla.Env{status: 404}} =
               Registrations.delete_user_registration(
                 client,
                 not_found_user_id,
                 @application_id
               )
    end

    test "delete_user_registration/3 returns 404 status code if the user_id is invalid", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Registrations.delete_user_registration(
                 client,
                 "12345",
                 @application_id
               )
    end
  end

  describe "Verify a user registration" do
    test "verify_user_registration/2 returns 404 status code for invalid request", %{
      client: client
    } do
      assert {:error, "", %Tesla.Env{status: 404}} =
               Registrations.verify_user_registration(
                 client,
                 "bad-code"
               )
    end
  end

  describe "Resend a user registration verification email" do
    test "resend_user_registration_verification_email/3 returns 200 status code for successful request",
         %{client: client} do
      assert {:ok, %{}, %Tesla.Env{status: 200}} =
               Registrations.resend_user_registration_verification_email(
                 client,
                 @application_id,
                 @user[:email]
               )
    end

    test "resend_user_registration_verification_email/3 returns 400 status code for malformed request",
         %{
           client: client
         } do
      resp_body = %{
        "fieldErrors" => %{
          "applicationId" => [
            %{
              "code" => "[couldNotConvert]applicationId",
              "message" => "Invalid UUID"
            },
            %{
              "code" => "[missing]applicationId",
              "message" => "You must specify the [applicationId] as a parameter."
            }
          ]
        }
      }

      assert {:error, ^resp_body, %Tesla.Env{status: 400}} =
               Registrations.resend_user_registration_verification_email(
                 client,
                 "invalid-app-id",
                 @user[:email]
               )
    end
  end
end
