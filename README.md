# FusionAuth

This library provides an Elixir API for accessing the [FusionAuth Developer APIs](https://fusionauth.io/docs/v1/tech/apis/).

Currently implemented are:
* [Users API](https://fusionauth.io/docs/v1/tech/apis/users)

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

