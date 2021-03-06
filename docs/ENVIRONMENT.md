# Environment Variables

This environment variables can be used to configure released docker container at start time.
Also sample `.env` can be used as payload for `docker run` cli.

## General

| VAR_NAME      | Default Value           | Description |
| ------------- | ----------------------- | ----------- |
| ERLANG_COOKIE | `03/yHifHIEl`.. | Erlang [distribution cookie](http://erlang.org/doc/reference_manual/distributed.html). **Make sure that default value is changed in production.** |
| LOG_LEVEL     | `info` | Elixir Logger severity level. Possible values: `debug`, `info`, `warn`, `error`. |

## Phoenix HTTP Endpoint

| VAR_NAME      | Default Value | Description |
| ------------- | ------------- | ----------- |
| PORT          | `4000`        | HTTP host for web app to listen on. |
| HOST          | `localhost`   | HTTP port for web app to listen on. |
| SECRET_KEY    | `b9WHCgR5TGcr`.. | Phoenix [`:secret_key_base`](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html). **Make sure that default value is changed in production.** |

## Database

| VAR_NAME      | Default Value | Description |
| ------------- | ------------- | ----------- |
| DB_NAME       | `nil`         | Database name. |
| DB_USER       | `nil`         | Database user name. |
| DB_PASSWORD   | `nil`         | Database user password. |
| DB_HOST       | `nil`         | Database host. |
| DB_PORT       | `nil`         | Database port. |
| DB_POOL_SIZE  | `nil`         | Number of connections to the database. |
| DB_MIGRATE    | `false`       | Flag to run migration. |
