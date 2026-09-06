# energizer 2.0.0

- Renamed exported API functions from `epb_*` to unprefixed names, including
  `set_token()`, `get_certificate()`, `search_*()`, and `download_*()`.
- Removed the exported `epb_*` API. Internal implementation helpers retain
  their `epb_` prefix.

# energizer 1.0.0

- Migrated to Get energy performance of buildings data API.
- Added bearer-token authentication through `set_token()` and
  `EPB_BEARER_TOKEN`.
- Added certificate retrieval, three certificate search functions, change
  events, code tables, full-load downloads and download metadata under new
  public API.
- Added page-based pagination using API `pagination` response object.
- Marked legacy `odc_*` interface defunct because Open Data Communities API and
  Basic Authentication workflow are obsolete.
- Removed obsolete Base64 credential encoding, LMK-key retrieval, file listing
  and hard-coded schema archive handling.
- Fixed HTTP error handling so API status and response details are reported
  instead of a secondary `NULL` response error.
- Search functions now return an empty tibble when a valid query has no
  matching certificates, represented by HTTP 404 in the API.
- Normalized JSON `null` record fields before row binding to avoid repetitive
  `data.table::rbindlist()` missing-value warnings.

# energizer 0.10.0

-   `odc_set_key` sets the Open Data Communities API by base64-encoding user-provided credentials.
-   `odc_get_data` retrieves certificates and recommendations for `domestic`, `non_domestic` and `display` certification types by `lmk_key` attribute.
-   `odc_search_data` allows users to search both `certificates` and `recommendations` for `domestic`, `non_domestic` and `display` based on multiple filtering criteria.
-   `odc_get_schema` allow retrieval of dataset schemas.
-   `odc_get_meta` returns the API metadata, such as `latestDate` and `updateData`.
-   `odc_bulk_download` can be used to bulk download available files, which can be retrieved either via `odc_get_file_list()` or `odc_get_list()`.
