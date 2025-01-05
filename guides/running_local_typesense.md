# Running local Typesense

This document guides you through setting up a local Typesense instance for
development purposes. Running a local instance allows you to experiment with
search functionalities and integrate them into your development workflow
seamlessly.

## Prerequisites

### Install Elixir

This project uses **Elixir version** `>= v1.14`

There are 4 ways to install Elixir:

#### Option A: via Official page

https://elixir-lang.org/install.html

#### Option B: via [`asdf`](https://asdf-vm.com)

1. https://asdf-vm.com/guide/getting-started.html
2. https://github.com/asdf-vm/asdf-elixir
3. https://github.com/asdf-vm/asdf-erlang?tab=readme-ov-file#before-asdf-install
4. `asdf global elixir VERSION && asdf global erlang VERSION`

#### Option C: via [`vfox`](https://vfox.lhan.me)

1. https://vfox.lhan.me/guides/quick-start.html
2. https://github.com/version-fox/vfox-elixir
3. https://github.com/version-fox/vfox-erlang
4. `vfox use -g erlang@VERSION && vfox use -g elixir@VERSION`

#### Option D: via Docker/docker-compose

Please refer to this repo: https://github.com/jaeyson/docker-dev-setup/tree/master/elixir.

> **Note**: you might need to omit packages like `postgres-client`
in the `elixir.dockerfile`, since we won't use such package. Also remove
the line that contains `RUN mix archive.install hex phx_new --force` since
we won't install Phoenix framework.

### Install Docker

Before we begin, ensure you have the following installed on your development
machine:

- Docker: <https://www.docker.com/> - Docker provides a containerization platform
  for running Typesense in an isolated environment.

- Docker Compose: <https://docs.docker.com/compose/install/> - Docker Compose
  helps manage multi-container applications like Typesense.

Or use the [one line command](https://github.com/docker/docker-install) to install both:

```bash
# this is slightly edited so that you don't
# have to save the file on the machine
curl -sSL https://get.docker.com/ | sh
```

## Setting up

We are using Docker compose to bootstrap a local Typesense instance from a
sample docker compose file.

Clone the `ex_typesense` GitHub repository:

```bash
git clone https://github.com/jaeyson/ex_typesense.git
```

Navigate to the cloned GitHub repository start the Typesense instance:

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

