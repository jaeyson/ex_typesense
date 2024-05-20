# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Date format in this changelog is `yyyy.mm.dd`

## 0.4.0 (2024.05.10)

### Added

- Mix task for creation and import
- Add missing module doc versions

### Changed

- Bumped dependencies' version
- Update type URI that is undefined

## 0.3.5 (2023.08.13)

### Fixed

- Fixed typos

## 0.3.4 (2023.07.12)

### Fixed

- Remove string conversion on struct id when deleting a document.

## 0.3.3 (2023.07.11)

### Added

- Add index_multiple_documents/1 clause for accepting struct args

## 0.3.2 (2023.07.11)

### Changed

- Maps struct pk to document's id
- Update http request timeout to `3,600` seconds

## 0.3.1 (2023.07.11)

### Changed

- Increase connection timeout

## 0.3.0 (2023.06.20)

### Added

- Added cheatsheet section on docs

### Fixed

- Fixed url request path for aliases

### Changed

- Refactor functions inside collection and document.
- Changed return values from `{:ok, t()}` to `t()` only.
- Parse schema field types for `float`, `boolean`, `string`, `integer` and a list with these corresponding types.

## 0.2.2 (2023.01.26)

### Changed

- Updated docs

## 0.2.1 (2023.01.22)

### Changed

- Returned an ecto query instead of list of results

## 0.2.0 (2023.01.20)

### Added

- Added search function which returns a list of structs or empty.

## 0.1.0 (2023.01.20)

- Initial release
