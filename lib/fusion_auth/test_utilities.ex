defmodule FusionAuth.TestUtilities do
  @moduledoc """
  This is module provides various functions for writing tests utilizing this packages functions
  """
  alias FusionAuth.{Users, Applications, Registrations, OpenIdConnect, Groups}
  alias Faker.{Internet, UUID}

  @doc """
  Checks if a given user object is currently available to be queried by FusionAuth
  - Directly after creating a user in FusionAuth they might not be available to be queried
  """
  def user_exists?(client, user) do
    query_string =
      case user do
        %{username: username} ->
          "username:" <> username

        %{id: id} ->
          "id:" <> id

        %{email: email} ->
          "email:" <> email
      end

    search = %{
      queryString: query_string
    }

    case Users.search_users(client, search) do
      {:ok, %{"total" => 1}, _} -> true
      _ -> false
    end
  end

  @doc """
  Waits for a given function, returns true if successful and false if the max attempts is exceeded
  There are several situations where after creating a FusionAuth object it is not available to be queried,
  this function aids in waiting for said object to be available for use.
  """
  def wait_for_process(func, attempts \\ 1) do
    case func.() do
      :continue ->
        true

      :wait ->
        cond do
          attempts < 50 ->
            Process.sleep(100)
            wait_for_process(func, attempts + 1)

          true ->
            false
        end
    end
  end

  defp valid_app_token_configs?(client, application_id) do
    {:ok, application, _} = Applications.get_application(client, application_id)
    jwt_enabled = application["application"]["jwtConfiguration"]["enabled"]
    refresh_config = application["application"]["loginConfiguration"]
    allow_token_refresh_enabled = refresh_config["allowTokenRefresh"]
    generate_refresh_tokens_enabled = refresh_config["generateRefreshTokens"]

    if jwt_enabled and allow_token_refresh_enabled and generate_refresh_tokens_enabled do
      true
    else
      false
    end
  end

  @doc """
  Takes an already created application id and user id (that may or may not exist) and creates tokens for a user with that id
  - This does recreate the user if one already exists so the ID will be the same but the other information won't.
  """
  def create_tokens_and_user(client, application_id, user_id) do
    enable_JWT(client, application_id)
    enable_refresh_tokens(client, application_id)

    if user_exists?(client, %{id: user_id}),
      do: Users.delete_user(client, user_id, [{:hardDelete, true}])

    user = %{
      username: Internet.user_name(),
      password: UUID.v4(),
      email: Internet.email()
    }

    data = %{
      registration: %{
        applicationId: application_id
      },
      user: user
    }

    wait_for_process(fn ->
      if valid_app_token_configs?(client, application_id),
        do: :continue,
        else: :wait
    end)

    {:ok, registration, _} =
      Registrations.create_user_and_registration(
        client,
        data,
        user_id
      )

    wait_for_process(fn ->
      if user_exists?(client, user),
        do: :continue,
        else: :wait
    end)

    %{token: registration["token"], refresh_token: registration["refreshToken"]}
  end

  @doc """
  Hard Deletes all the users in FusionAuth.
  """
  def cleanup_users(client) do
    {:ok, users, _} = Users.search_users(client, %{queryString: ""})

    user_list = users["users"]

    if is_list(user_list) and length(user_list) do
      Enum.map(user_list, fn user ->
        Users.delete_user(client, user["id"], hardDelete: true)
      end)
    end
  end

  @doc """
  Deletes a specific tenant given the ID.
  """
  def cleanup_tenant(client, tenant_id) do
    Tesla.delete(client, "/api/tenant/" <> tenant_id)
  end

  @doc """
  Deletes all the groups in FusionAuth.
  """
  def cleanup_groups(client) do
    {:ok, groups, _} = Groups.get_groups(client)

    if groups != %{} do
      Enum.map(groups["groups"], fn group ->
        Groups.delete_group(client, group["id"])
      end)
    end
  end

  @doc """
  Deletes all the identity providers in FusionAuth.
  """
  def cleanup_identity_providers(client) do
    {:ok, identity_providers, _} = OpenIdConnect.retrieve_all_identity_providers(client)

    if identity_providers != %{} do
      Enum.map(identity_providers["identityProviders"], fn provider ->
        OpenIdConnect.delete_openid_connect_identity_provider(client, provider["id"])
      end)
    end
  end

  @doc """
  creates a tenant and sets up an email template.
  - Certain api calls require a template to be used for emails.
  """
  def create_tenant_with_email_template(
        client,
        tenant_id,
        template_id \\ "2eb20ca0-b1e8-4179-8dcf-52f78a7f6c06"
      ) do
    create_email_template(client, template_id)

    tenant = %{
      "tenant" => %{
        "name" => Internet.domain_word(),
        "emailConfiguration" => %{
          "forgotPasswordEmailTemplateId" => template_id
        }
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  @doc """
  Creates a tenant with the given id.
  """
  def create_tenant(client, tenant_id) do
    tenant = %{
      "tenant" => %{
        "name" => Internet.domain_word()
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  @doc """
  Creates an application with the given id.
  """
  def create_application_with_id(client, application_id) do
    application = %{
      "application" => %{
        "name" => Internet.domain_word()
      }
    }

    Tesla.post(client, "/api/application/" <> application_id, application)
  end

  @doc """
  Enables registration verification for the application with the given id. It uses the provided template id
  as the email template.
  """
  def enable_registration_verification(client, application_id, template_id) do
    create_email_template(client, template_id)

    app = %{
      "verifyRegistration" => true,
      "verificationEmailTemplateId" => template_id
    }

    Applications.update_application(client, application_id, app)
  end

  @doc """
  Enables refresh tokens for the application with the given id.
  """
  def enable_refresh_tokens(client, application_id) do
    app = %{
      "loginConfiguration" => %{
        "allowTokenRefresh" => true,
        "generateRefreshTokens" => true
      }
    }

    Applications.update_application(client, application_id, app)
  end

  @doc """
  Enables JWT generation for the application with the given id.
  """
  def enable_JWT(client, application_id) do
    app = %{
      "jwtConfiguration" => %{
        "enabled" => true
      }
    }

    Applications.update_application(client, application_id, app)
  end

  @doc """
  Creates a basic email template for the given template_id
  """
  def create_email_template(client, template_id) do
    template = %{
      "emailTemplate" => %{
        "name" => Internet.domain_word(),
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
