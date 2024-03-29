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


## Setting up

We are using Docker compose to bootstrap a local Typesense instance from a
sample `docker-compose.yml` file.


Clone the `ex_typesense` GitHub repository:

```bash
git clone https://github.com/jaeyson/ex_typesense.git
```

Navigate to the cloned GitHub repository start the Typesense instance:

```bash
cd ex_typesense
docker-compose up -d
```

Once you've started Typesense, you can verify its installation by accessing the
health endpoint through a browser or `curl` in the terminal:

```bash
$ curl http://localhost:8108/health
{"ok":true}
```

In a separate terminal, you can view the logs of your local Typesense instance
using following command:

```bash
docker-compose logs -f
```
