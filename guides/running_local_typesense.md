# Running local Typesense

This document guides you through setting up a local Typesense instance for
development purposes. Running a local instance allows you to experiment with
search functionalities and integrate them into your development workflow
seamlessly.

## Prerequisites

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
