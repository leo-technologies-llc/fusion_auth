defmodule FusionAuth.TestUtilities do
  alias FusionAuth.{Users, Applications, Registrations, OpenIdConnect, Groups}

  def user_exists?(client, username) do
    search = %{
      numberOfResults: 10,
      queryString: "username:" <> username,
      sortFields: [
        %{
          name: "username",
          order: "asc"
        }
      ],
      startRow: 0
    }

    case Users.search_users(client, search) do
      {:ok, %{"total" => 1}, _} -> true
      {:ok, %{"total" => 0}, _} -> false
      _ -> false
    end
  end

  def wait_for_process(func, attempts \\ 1) do
    case func.() do
      :continue ->
        true

      :wait ->
        cond do
          attempts < 20 ->
            Process.sleep(100)
            wait_for_process(func, attempts + 1)

          true ->
            false
        end
    end
  end

  # Will only create a refresh token if the setting for the application is enabled
  def create_tokens_and_user(client, application_id, user_id) do
    Users.delete_user(client, user_id, [{:hardDelete, true}])

    user = %{
      username: Faker.Internet.user_name(),
      password: Faker.UUID.v4(),
      email: Faker.Internet.email()
    }

    data = %{
      registration: %{
        applicationId: application_id
      },
      user: user
    }

    {:ok, registration, _} =
      Registrations.create_user_and_registration(
        client,
        data,
        user_id
      )

    wait_for_process(fn ->
      if user_exists?(client, user[:username]) and Map.has_key?(registration, "refreshToken"),
        do: :continue,
        else: :wait
    end)

    tokens = %{token: registration["token"]}

    if registration["refreshToken"] do
      Map.put(tokens, :refresh_token, registration["refreshToken"])
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

  def cleanup_groups(client) do
    {:ok, groups, _} = Groups.get_groups(client)

    if groups != %{} do
      Enum.map(groups["groups"], fn group ->
        Groups.delete_group(client, group["id"])
      end)
    end
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
        "name" => Faker.Internet.domain_word(),
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
        "name" => Faker.Internet.domain_word()
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  def create_application_with_id(client, application_id) do
    application = %{
      "application" => %{
        "name" => Faker.Internet.domain_word()
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
        "name" => Faker.Internet.domain_word(),
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
