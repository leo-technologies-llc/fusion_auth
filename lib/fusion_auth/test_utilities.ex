defmodule FusionAuth.TestUtilities do
  alias FusionAuth.Users
  alias FusionAuth.Applications

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

  def create_tenant_with_email_template(
        client,
        tenant_id,
        template_id \\ "2eb20ca0-b1e8-4179-8dcf-52f78a7f6c06"
      ) do
    create_email_template(client, template_id)

    tenant = %{
      "tenant" => %{
        "name" => for(_ <- 1..25, into: "", do: <<Enum.random('0123456789abcdef')>>),
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
        "name" => for(_ <- 1..25, into: "", do: <<Enum.random('0123456789abcdef')>>)
      }
    }

    Tesla.post(client, "/api/tenant/" <> tenant_id, tenant)
  end

  def create_application_with_id(client, application_id) do
    application = %{
      "application" => %{
        "name" => for(_ <- 1..25, into: "", do: <<Enum.random('0123456789abcdef')>>)
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

  def create_email_template(client, template_id) do
    template = %{
      "emailTemplate" => %{
        "name" => for(_ <- 1..25, into: "", do: <<Enum.random('0123456789abcdef')>>),
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
