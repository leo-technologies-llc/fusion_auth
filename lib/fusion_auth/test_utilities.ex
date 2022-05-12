defmodule FusionAuth.TestUtilities do
  alias FusionAuth.Users
  alias FusionAuth.Applications
  alias FusionAuth.Registrations
  alias FusionAuth.OpenIdConnect

  defp rand_string() do
    for(_ <- 1..25, into: "", do: <<Enum.random('0123456789abcdef')>>)
  end

  # Will only create a refresh token if the setting for the application is enabled
  def create_tokens_and_user(client, application_id, user_id) do
    Users.delete_user(client, user_id, [{:hardDelete, true}])

    data = %{
      registration: %{
        applicationId: application_id
      },
      user: %{
        username: rand_string(),
        password: rand_string(),
        email: rand_string() <> "@email.com"
      }
    }

    {:ok, registration, _} =
      Registrations.create_user_and_registration(
        client,
        data,
        user_id
      )

    tokens = %{token: registration["token"]}

    if registration["refreshToken"] do
      Map.put(tokens, :refreshToken, registration["refreshToken"])
    end
  end

  def cleanup_users(client) do
    {:ok, users, _} = Users.search_users(client, %{queryString: ""})

    user_list = users["users"]

    if is_list(user_list) and length(user_list) do
      Enum.map(user_list, fn user ->
        Users.delete_user(client, user["id"], hardDelete: true)
      end)
    end
  end

  def cleanup_tenant(client, tenant_id) do
    Tesla.delete(client, "/api/tenant/" <> tenant_id)
  end

  def cleanup_identity_providers(client) do
    {:ok, identity_providers, _} = OpenIdConnect.retrieve_all_identity_providers(client)

    if identity_providers != %{} do
      Enum.map(identity_providers["identityProviders"], fn provider ->
        OpenIdConnect.delete_openid_connect_identity_provider(client, provider["id"])
      end)
    end
  end

  def create_tenant_with_email_template(
        client,
        tenant_id,
        template_id \\ "2eb20ca0-b1e8-4179-8dcf-52f78a7f6c06"
      ) do
    create_email_template(client, template_id)

    tenant = %{
      "tenant" => %{
        "name" => rand_string(),
        "emailConfiguration" => %{
          "forgotPasswordEmailTemplateId" => template_id
        }
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  def create_tenant(client, tenant_id) do
    tenant = %{
      "tenant" => %{
        "name" => rand_string()
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  def create_application_with_id(client, application_id) do
    application = %{
      "application" => %{
        "name" => rand_string()
      }
    }

    Tesla.post(client, "/api/application/" <> application_id, application)
  end

  def enable_registration_verification(client, application_id, template_id) do
    create_email_template(client, template_id)

    app = %{
      "verifyRegistration" => true,
      "verificationEmailTemplateId" => template_id
    }

    Applications.update_application(client, application_id, app)
  end

  def enable_refresh_tokens(client, application_id) do
    app = %{
      "loginConfiguration" => %{
        "allowTokenRefresh" => true,
        "generateRefreshTokens" => true
      }
    }

    Applications.update_application(client, application_id, app)
  end

  def enable_JWT(client, application_id) do
    app = %{
      "jwtConfiguration" => %{
        "enabled" => true
      }
    }

    Applications.update_application(client, application_id, app)
  end

  def create_email_template(client, template_id) do
    template = %{
      "emailTemplate" => %{
        "name" => rand_string(),
        "fromEmail" => "email@example.com",
        "defaultFromName" => "Administrator",
        "defaultSubject" => "Template Subject",
        "defaultHtmlTemplate" => "<p>Hello ${user.username}",
        "defaultTextTemplate" => "Hello ${user.username}"
      }
    }

    Tesla.post(client, "/api/email/template/" <> template_id, template)
  end
end
