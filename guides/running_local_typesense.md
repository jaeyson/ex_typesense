# Running local Typesense

This document guides you through setting up a local Typesense instance for
development purposes. Running a local instance allows you to experiment with
search functionalities and integrate them into your development workflow
seamlessly.

## Prerequisites

### Install Elixir

This project uses **Elixir version** `>= v1.14`

There are 4 ways to install Elixir:

<!-- tabs-open -->

### 1. Official Elixir-Lang page

visit https://elixir-lang.org/install.html

### 2. via `vfox`

[`vfox`](https://vfox.lhan.me)

1. https://vfox.lhan.me/guides/quick-start.html
2. https://github.com/version-fox/vfox-elixir
3. https://github.com/version-fox/vfox-erlang
4. `vfox use -g erlang@VERSION && vfox use -g elixir@VERSION`

### 3. via `asdf`

[`asdf`](https://asdf-vm.com)

1. https://asdf-vm.com/guide/getting-started.html
2. https://github.com/asdf-vm/asdf-elixir
3. https://github.com/asdf-vm/asdf-erlang?tab=readme-ov-file#before-asdf-install
4. `asdf global elixir VERSION && asdf global erlang VERSION`

### 4. using Dockerfile

Please refer to this repo: https://github.com/jaeyson/docker-dev-setup/tree/master/elixir.

> #### editing `elixir.dockerfile` {: .info}
>
> you might need to omit packages like `postgres-client`
> in the `elixir.dockerfile`, since we won't use such package. Also remove
> the line that contains `RUN mix archive.install hex phx_new --force` since
> we won't install Phoenix framework.

<!-- tabs-close -->

### Install Docker

We use docker container for spinning up local Typesense instance.

Here are 3 ways to install:

<!-- tabs-open -->

### one-line install script (Linux)

> #### not for production use {: .info}
>
> This script is intended as a convenient way to configure docker's package
> repositories and to install Docker Engine, This script is not recommended
> for production environments.


```bash
# this is slightly edited so that you don't
# have to save the file on the machine
curl -sSL https://get.docker.com/ | sh
```

### Docker Desktop

- Mac: https://docs.docker.com/desktop/setup/install/mac-install
- Windows: https://docs.docker.com/desktop/setup/install/windows-install
- Linux: https://docs.docker.com/desktop/setup/install/linux

### Orbstack

https://orbstack.dev

<!-- tabs-close -->

## Setting up

We are using Docker compose to bootstrap a local Typesense instance from a
sample docker compose file.

Clone the `ex_typesense` GitHub repository:

```bash
git clone https://github.com/jaeyson/ex_typesense.git
```

Navigate to the cloned GitHub repository and start the Typesense instance:

```bash
cd ex_typesense

docker compose up -d
```

More info on spinning a local instance: https://typesense.org/docs/guide/install-typesense.html

Once you've started Typesense, you can verify its installation by accessing the
health endpoint through a browser or `curl` in the terminal:

```bash
$ curl http://localhost:8108/health
{"ok":true}
```

In a separate terminal, you can view the logs of your local Typesense instance
using following command:

```bash
# logs from all instances
docker compose logs -f

# or specifically Typesense
docker container logs --follow --tail 50 typesense
```

This Docker Compose setup exposes three services with dedicated URLs:

- http://localhost:8107 (Internal Server Status), provides information about the
  health and status of your internal server.
- http://localhost:8108 (Typesense Server and API), allows you to interact with
  the Typesense search engine and its API functionalities.
- http://localhost:8109 (Typesense Dashboard), opens the Typesense web interface
  for managing your search collections and settings.

