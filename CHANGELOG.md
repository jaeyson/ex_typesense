# Changelog

## 0.3.4 (2023.07.12)

* Remove string conversion on struct id when deleting a document.

## 0.3.3 (2023.07.11)

* Add index_multiple_documents/1 clause for accepting struct args

## 0.3.2 (2023.07.11)

* Maps struct pk to document's id

* Update http request timeout to `3,600` seconds

## 0.3.1 (2023.07.11)

* Increase connection timeout

## 0.3.0 (2023.06.20)

* Fixed url request path for aliases

* Refactor functions inside collection and document.

* Changed return values from `{:ok, t()}` to `t()` only.

* Added cheatsheet section on docs

* Parse schema field types for `float`, `boolean`, `string`, `integer` and a list with these corresponding types.

## 0.2.2 (2023.01.26)

* Updated docs

## 0.2.1 (2023.01.22)

* Returned an ecto query instead of list of results

## 0.2.0 (2023.01.20)

* Added search function which returns a list of structs or empty.

## 0.1.0 (2023.01.20)

* Initial release
