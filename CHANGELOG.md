# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## major.minor.patch (yyyy.mm.dd)

## 1.1.1 (2025.03.26)

### Changed

* Bump dependency version.

## 1.1.0 (2025.03.02)

### Added

* `Collection.create_collection_with_alias/1`.
* Allow module name (atom) to be passed as alias name in `Collection.create_collection_with_alias/1`.
* Typespec to pass also omodule name (atom) for `Collection.create_collection_with_alias/1`.
* Separate dev and test environments.

### Fixed

* Typespecs for `Search.multi_search_ecto`.
* Return values of `Search.multi_search_ecto` for `search_test.exs`.

### Deprecated

* `Collection.get_collection_name/1`

## 1.0.2 (2025.01.30)

### Changed

* Bump dependency version.

## 1.0.1 (2025.01.26)

### Changed

* Bump dependency version.
* README banner image

## 1.0.0 (2025.01.19)

### Added

* External docs link for example of using another HTTP client.
* More test coverage

### Changed

* Backwards-incompatible changes, in favor of using [`OpenApiTypesense`](https://github.com/jaeyson/open_api_typesense).
* Bump dependencies
* CI to support Typesense versions v26.0, v27.0, v27.1

### Removed

* Dropped support for Typesense version v0.25.2
* `ExTypesense.ResultParser` module (moved to `ExTypesense.Search`)

### Deprecated

* Dropped support for Typesense v0.25.2

## 0.7.3 (2024.11.11)

### Added

* `{:error, String.t()}` type for `Search.search/3`

## 0.7.2 (2024.11.07)

### Changed

* Use `v27.1` of [Typesense](https://typesense.org/docs/27.1/api) in CI and local development.

## 0.7.1 (2024.09.10)

### Removed

* `:castore` dependency not passing on CI test

## 0.7.0 (2024.09.10)

### Changed

* HTTP request construction in `ExTypesense.HttpClient` to include `options`.
* Bumped dependencies

### Added

* `options` in config `config/config.exs`.
* `get_options/0` function in `HttpClient` to fetch the `options` configuration.
* tests for `get_options/0` in `ExTypesense.HttpClientTest`.

## 0.6.0 (2024.07.15)

### Changed

* Move application env variables from `test_helper.exs` to `config` directory, in usage for both `dev` and `test` environments.

### Added

* Function: [multi search](https://typesense.org/docs/26.0/api/federated-multi-search.html)

## 0.5.0 (2024.07.13)

### Changed

* `README` regarding `default_sorting_field`, where it joins the table name with `_id` (e.g. `images` is `images_id` instead of `image_id`).

### Added

* Function: [delete by query](https://typesense.org/docs/26.0/api/documents.html#delete-by-query).
* Function: [delete all documents](https://github.com/typesense/typesense/issues/1613#issuecomment-1994986258) in a collection.
* Collection's schema [field parameters](https://typesense.org/docs/26.0/api/collections.html#field-parameters):
  - `:vec_dist`
  - `:store`
  - `:reference`
  - `:range_index`
  - `:stem`

### Removed

- `HttpClient.run` and `HttpClient.httpc_run` function (use `HttpClient.request`).

## 0.4.3 (2024.07.03)

### Changed

* `README` regarding test and connection strings.
* Replacing connection struct to map.

## 0.4.2 (2024.06.19)

### Changed

* `README` and cheatsheet details regarding on setup for creation of collection schema.

## 0.4.1 (2024.06.11)

### Changed

* `README` on running `docker compose`.

## 0.4.0 (2024.05.20)

### Added

* Connection module for dynamic loading of credentials.
* Default connection config when running commands (e.g. create collections, etc.).

### Changed

* Refactor `ExTypesense.HttpClient` on how to handle request.
* Bumped dependencies' version.
* Dropped usage of `:httpc` in favor of using [`Req library`](https://hex.pm/packages/req).

### Deprecated

* Some functions from `Document` and `HttpClient` where soft depcrated in order to incorporate the `Connection` module for dynamic connections loaded from Ecto schema. If you read the docs, you might notice it's marked with `deprecated` and encourages to use the newer ones.

## 0.3.5 (2023.08.13)

### Fixed

* Fixed typos

## 0.3.4 (2023.07.12)

### Changed

* Remove string conversion on struct id when deleting a document.

## 0.3.3 (2023.07.11)

### Added

* Add index_multiple_documents/1 clause for accepting struct args.

## 0.3.2 (2023.07.11)

### Changed

* Maps struct pk to document's id.
* Update http request timeout to `3,600` seconds.

## 0.3.1 (2023.07.11)

### Changed

* Increase connection timeout.

## 0.3.0 (2023.06.20)

### Fixed

* Fixed url request path for aliases.

### Changed

* Refactor functions inside collection and document.
* Changed return values from `{:ok, t()}` to `t()` only.
* Parse schema field types for `float`, `boolean`, `string`, `integer` and a list with these corresponding types.

### Added

* Added cheatsheet section on docs.

## 0.2.2 (2023.01.26)

### Changed

* Updated docs

## 0.2.1 (2023.01.22)

### Changed

* Returned an ecto query instead of list of results.

## 0.2.0 (2023.01.20)

### Added

* Added search function which returns a list of structs or empty.

## 0.1.0 (2023.01.20)

* Initial release
