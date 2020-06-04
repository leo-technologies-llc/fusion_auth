# FusionAuth ![Status](https://github.com/Cogility/fusion_auth/workflows/.github/workflows/elixir.yml/badge.svg?branch=master)

This library provides an Elixir API for accessing the [FusionAuth Developer APIs](https://fusionauth.io/docs/v1/tech/apis/).

Currently implemented are:
- [ ] [Actioning Users](https://fusionauth.io/docs/v1/tech/apis/actioning-users)
- [ ] [Applications](https://fusionauth.io/docs/v1/tech/apis/applications)
- [ ] [Audit Logs](https://fusionauth.io/docs/v1/tech/apis/audit-logs)
- [ ] [Consent](https://fusionauth.io/docs/v1/tech/apis/consent)
- [ ] [Emails](https://fusionauth.io/docs/v1/tech/apis/emails)
- [ ] [Event Logs](https://fusionauth.io/docs/v1/tech/apis/event-logs)
- [ ] [Families](https://fusionauth.io/docs/v1/tech/apis/families)
- [ ] [Groups](https://fusionauth.io/docs/v1/tech/apis/groups)
- [ ] [Identity Providers](https://fusionauth.io/docs/v1/tech/apis/identity-providers)
- [ ] [Integrations](https://fusionauth.io/docs/v1/tech/apis/integrations)
- [ ] [JWT](https://fusionauth.io/docs/v1/tech/apis/jwt)
- [ ] [Keys](https://fusionauth.io/docs/v1/tech/apis/keys)
- [ ] [Login](https://fusionauth.io/docs/v1/tech/apis/login)
- [ ] [Passwordless](https://fusionauth.io/docs/v1/tech/apis/passwordless)
- [ ] [Registrations](https://fusionauth.io/docs/v1/tech/apis/registrations)
- [ ] [Reports](https://fusionauth.io/docs/v1/tech/apis/reports)
- [ ] [System](https://fusionauth.io/docs/v1/tech/apis/system)
- [ ] [Tenants](https://fusionauth.io/docs/v1/tech/apis/tenants)
- [ ] [Themes](https://fusionauth.io/docs/v1/tech/apis/themes)
- [ ] [Two Factor](https://fusionauth.io/docs/v1/tech/apis/two-factor)
- [X] [Users](https://fusionauth.io/docs/v1/tech/apis/users)
- [ ] [User Actions](https://fusionauth.io/docs/v1/tech/apis/user-actions)
- [ ] [User Action Reasons](https://fusionauth.io/docs/v1/tech/apis/user-action-reasons)
- [ ] [User Comments](https://fusionauth.io/docs/v1/tech/apis/user-comments)
- [ ] [Webhooks](https://fusionauth.io/docs/v1/tech/apis/webhooks)

The API access uses the [Tesla](https://github.com/teamon/tesla) library and
relies on the caller passing in a FusionAuth base URL, API Key and Tenant ID to create a
client. The client is then passed into all API calls.

The API returns a 3 element tuple. If the API HTTP status code is less
the 300 (ie. suceeded) it returns `:ok`, the HTTP body as a map and the full
Tesla Env if you need to access more data about the return. If the API HTTP
status code is greater than 300. it returns `:error`, the HTTP body and the
Telsa Env. If the API doesn't return at all it should return `:error`, a blank
map and the error from Tesla.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fusion_auth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fusion_auth, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fusion_auth](https://hexdocs.pm/fusion_auth).

## Contributing


## License
