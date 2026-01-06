# Changelog

## energizer (development version)

## energizer 0.10.0

- `odc_set_key` sets the Open Data Communities API by base64-encoding
  user-provided credentials.
- `odc_get_data` retrieves certificates and recommendations for
  `domestic`, `non_domestic` and `display` certification types by
  `lmk_key` attribute.
- `odc_search_data` allows users to search both `certificates` and
  `recommendations` for `domestic`, `non_domestic` and `display` based
  on multiple filtering criteria.
- `odc_get_schema` allow retrieval of dataset schemas.
- `odc_get_meta` returns the API metadata, such as `latestDate` and
  `updateData`.
- `odc_bulk_download` can be used to bulk download available files,
  which can be retrieved either via
  [`odc_get_file_list()`](https://gabrielegiraldo.github.io/enrgz/reference/odc_get_file_list.md)
  or `odc_get_list()`.
