
[Getting Started](https://numtide.github.io/devshell/getting_started.html)

This example will run Postgres and Memcached natively on your machine.

You may have to be a member of the `postgres` group to allow Postgres to start. Otherwise, Postgres may be unable to create its lockfile.

First create the Postgres database with the devshell command `initPostgres`. This is defined in the TOML. It uses Postgres command `initdb`.

Then the devshell command `database:start`.
