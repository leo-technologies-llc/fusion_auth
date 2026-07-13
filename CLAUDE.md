# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Elixir SDK (`fusion_auth`) for the FusionAuth REST API, built on Tesla with the Hackney adapter. Elixir/OTP versions are pinned in `.tool-versions` (Elixir 1.17.2, OTP 27).

## Commands

Tests are integration tests that run against a real FusionAuth instance in Docker (FusionAuth + Postgres + OpenSearch, defined in `docker-compose.yml` and seeded via Kickstart from `priv/data/fusionauth/kickstart.json`). The `./run` script manages the full lifecycle:

```bash
./run test                 # spin up fresh containers, run mix test, tear down
./run test test/fusion_auth/users_test.exs           # single file
./run test test/fusion_auth/users_test.exs:26        # single test
./run coveralls            # same, but with coverage (this is what CI runs)
./run down                 # stop containers
./run logs                 # start stack and follow FusionAuth logs
```

`./run test` wipes existing `fusion_auth`-named Docker volumes before starting, then waits for Kickstart to complete. **Source the env first**: `source .env.example && ./run test` — the script only sources `.env.example` after `docker compose up`, so without a `.env` file or pre-sourced shell, Postgres starts with a blank password and the stack fails (CI avoids this by copying `.env.example` to `.env`). Test config in `config/test.exs` reads these vars — note tests use `FUSION_AUTH_TEST_URL` (port 29012), not `FUSION_AUTH_URL`. Port 29012 may conflict with FusionAuth containers from other projects (e.g. `fusionauth-test`).

To iterate on tests without the container teardown/startup cost, leave the stack up and run mix directly:

```bash
source .env.example && mix test path/to/test.exs
```

Format with `mix format` (covers `config/`, `lib/`, `test/`).

## Architecture

- `lib/fusion_auth.ex` — the core module. `FusionAuth.client/3` builds a `Tesla.Client` from a base URL, API key, and tenant ID (or `client/0` from `:fusion_auth` app config). `FusionAuth.result/1` normalizes every Tesla response into the 3-tuple used throughout: `{:ok, body, %Tesla.Env{}}` for status < 300, `{:error, body, env_or_error}` otherwise. The Tesla adapter is swappable via `config :fusion_auth, :tesla` (used to inject `Tesla.Mock` in tests).
- `lib/fusion_auth/*.ex` — one module per FusionAuth API area (`Users`, `Login`, `Groups`, `JWT`, `Registrations`, etc.). Each function takes the client as its first argument, makes the Tesla request, and pipes through `FusionAuth.result/1`. Only a subset of FusionAuth's APIs is implemented; the checklist is in README.md.
- `lib/fusion_auth/response.ex` — optional `Response.format/1,2,3` to flatten the 3-tuple into `{:ok, payload}` / `{:error, reason}`, extract a payload key, and apply a formatter (e.g. atomize keys).
- `lib/fusion_auth/plugs/` — `AuthorizeJWT` and `RefreshJWT` plugs for consumers' Phoenix/Plug apps; configured via `:fusion_auth` app env (`token_header_key`, `refresh_header_key`, `jwt_signing_key`, etc.).
- `lib/fusion_auth/utils.ex` — `build_query_parameters/1` converts keyword lists to query strings; used by API modules and `Helpers.Mock`.

## Tests

- Test cases use `FusionAuth.DataCase` (`test/data_case.ex`), which deletes all users, groups, identity providers, and the test tenant before and after every test — tests run against shared live state, so isolation depends on this cleanup.
- `test/test_utilities.ex` (`FusionAuth.TestUtilities`) holds setup helpers: creating tenants/applications/keys, enabling JWT/passwordless/refresh tokens, and `wait_for_process/2` for polling FusionAuth's eventually-consistent search index (OpenSearch-backed user search lags writes).
- A typical `setup` block builds a tenant-less client, calls `TestUtilities.create_tenant_with_email_template/2`, then builds the real client with the tenant ID.
- `lib/fusion_auth/helpers/mock.ex` provides `mock_request/1,2` around `Tesla.Mock` for the few unit-style tests that don't hit the live instance.

## Git conventions

- Gitflow-style branches: `development` is the default/PR target; `production`, `release/**`, and `hotfix/**` also exist. Commits reference Jira tickets, e.g. `feat(fusionauth): [VR-15812] ...`.
