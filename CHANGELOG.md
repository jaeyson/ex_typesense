# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
