defmodule FusionAuth.Samlv2 do
  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()
  @type headers :: [tuple()]
  @type start_login_request_body :: %{
          application_id: String.t(),
          data: %{request_id: String.t()},
          identity_provider_id: String.t()
        }
  @type complete_login_request_body :: %{
          application_id: String.t(),
          data: %{
            saml_response: String.t()
          },
          identity_provider_id: String.t(),
          ip_address: String.t(),
          meta_data: %{
            device: %{
              description: String.t(),
              last_accessed_address: String.t(),
              name: String.t(),
              type: String.t()
            }
          },
          no_jwt: boolean(),
          no_link: boolean()
        }

  @spec start_login(client(), start_login_request_body()) :: FusionAuth.result()
  def start_login(client, start_login_request_body) do
    Tesla.post(client, "/api/identity-provider/start", start_login_request_body)
    |> FusionAuth.result()
  end

  @spec complete_login(client(), complete_login_request_body()) :: FusionAuth.result()
  def complete_login(client, complete_login_request_body) do
    Tesla.post(client, "/api/identity-provider/login", complete_login_request_body)
    |> FusionAuth.result()
  end

  @spec complete_login(client(), complete_login_request_body(), headers()) :: FusionAuth.result()
  def complete_login(client, complete_login_request_body, headers) do
    Tesla.post(client, "/api/identity-provider/login", complete_login_request_body,
      headers: headers
    )
    |> FusionAuth.result()
  end
end
