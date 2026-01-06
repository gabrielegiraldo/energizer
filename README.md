
<!-- README.md is generated from README.Rmd. Please edit that file -->

# energizer

<!-- badges: start -->

[![R-CMD-check](https://github.com/gggiraldo/enrgz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gggiraldo/enrgz/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of energizer is to …

## Installation

R Interface to get EPC data using the OpenDataCommunities API

## Installation

You can install the development version of energizer from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("gggiraldo/energizer")
```

or with:

``` r
remotes::install_github("gggiraldo/energizer")
```

## Getting the API key

To get the API key, visit the
[opc.opendatacommunities.org](https://epc.opendatacommunities.org/#register)
website.

A confirmation containing the API key will be sent to the e-mail address
provided during registration.

## 🪪 API Credentials Setup

First, to start using `energizer` you need to set your API key with:

``` r
energizer::odc_set_key(
  odc_user = "username", 
  odc_key = "api-key"
)
```

where `odc_user` is the address provided during the registration
process, and `odc_key` is the one included in the confirmation e-mail.

## 🔍 General Search

The `search_domestic` function allows to search for certificates using
various filters:

``` r
energizer::odc_search_data(
  address = "liverpool road",
  type = "domestic"
)
#> # A tibble: 25 × 93
#>    low_energy_fixed_light_count address                 uprn_source floor_height
#>    <chr>                        <chr>                   <chr>       <chr>       
#>  1 ""                           329 Old Liverpool Road  Energy Ass… 2.7         
#>  2 ""                           93 Liverpool Road       Energy Ass… 2.64        
#>  3 ""                           44 Liverpool Road       Energy Ass… 2.4         
#>  4 ""                           2a Crown Buildings, Li… Energy Ass… 2.42        
#>  5 ""                           22 Liverpool Road       Energy Ass… 2.6         
#>  6 ""                           5 Liverpool Road        Energy Ass… 2.16        
#>  7 ""                           60 Liverpool Road, Aug… Energy Ass… 2.54        
#>  8 ""                           546 Liverpool Road, Ha… Energy Ass… 2.46        
#>  9 ""                           104 Liverpool Road, Gr… Energy Ass… 2.6         
#> 10 ""                           Flat, 575 Liverpool Ro… Energy Ass… 2.52        
#> # ℹ 15 more rows
#> # ℹ 89 more variables: heating_cost_potential <chr>,
#> #   unheated_corridor_length <chr>, hot_water_cost_potential <chr>,
#> #   construction_age_band <chr>, potential_energy_rating <chr>,
#> #   mainheat_energy_eff <chr>, windows_env_eff <chr>,
#> #   lighting_energy_eff <chr>, environment_impact_potential <chr>,
#> #   glazed_type <chr>, heating_cost_current <chr>, address3 <chr>, …
```

By default, the function returns 25 records matching the filtering
criteria. This behavior can be changed using the `max_records`
parameter:

``` r
london_search_50 <- 
  energizer::odc_search_data(
    address = "liverpool road",
    type = "domestic",
    max_records = 50
  )

dim(london_search_50)
#> [1] 50 93
```

## 🔑 `lmk_key`-based Search

Certitificates can also be retrieved using the `lmk_key` field
attribute, representing the “*Individual lodgement identifier*”, which
is unique and “*\[…\]can be used to identify a certificate*”.

``` r
energizer::odc_get_data(
  domestic_lmk_key, 
  type = "domestic",
  endpoint = "certificate"
)
#> # A tibble: 1 × 93
#>   low_energy_fixed_lig…¹ address uprn_source floor_height heating_cost_potential
#>   <chr>                  <chr>   <chr>       <chr>        <chr>                 
#> 1 ""                     39 Bee… Energy Ass… 2.3          887                   
#> # ℹ abbreviated name: ¹​low_energy_fixed_light_count
#> # ℹ 88 more variables: unheated_corridor_length <chr>,
#> #   hot_water_cost_potential <chr>, construction_age_band <chr>,
#> #   potential_energy_rating <chr>, mainheat_energy_eff <chr>,
#> #   windows_env_eff <chr>, lighting_energy_eff <chr>,
#> #   environment_impact_potential <chr>, glazed_type <chr>,
#> #   heating_cost_current <chr>, address3 <chr>, …
```

In the same way, recommendations can also be searched:

``` r
energizer::odc_get_data(
  domestic_lmk_key,
  type = "domestic",
  endpoint = "recommendation"
)
#> # A tibble: 3 × 7
#>   lmk_key         improvement_item improvement_summary_…¹ improvement_descr_text
#>   <chr>           <chr>            <chr>                  <chr>                 
#> 1 00031a8942cc00… 1                Floor insulation (sol… Floor insulation (sol…
#> 2 00031a8942cc00… 2                Heating controls (the… Heating controls (TRV…
#> 3 00031a8942cc00… 3                Solar photovoltaic pa… Solar photovoltaic pa…
#> # ℹ abbreviated name: ¹​improvement_summary_text
#> # ℹ 3 more variables: improvement_id <chr>, improvement_id_text <chr>,
#> #   indicative_cost <chr>
```

Notice that if no recommendations are found, an error message is
returned.

## 📃 Paginated Search

By default, only the first page of results is returned. Searching with
pagination can be done by setting `paginate = "all"`:

``` r
energizer::odc_search_data(
    address = "liverpool road",
    type = "domestic",
    paginate = "all", 
    size = 5000
)
#> # A tibble: 17,768 × 93
#>    low_energy_fixed_light_count address                 uprn_source floor_height
#>    <chr>                        <chr>                   <chr>       <chr>       
#>  1 ""                           329 Old Liverpool Road  Energy Ass… 2.7         
#>  2 ""                           93 Liverpool Road       Energy Ass… 2.64        
#>  3 ""                           44 Liverpool Road       Energy Ass… 2.4         
#>  4 ""                           2a Crown Buildings, Li… Energy Ass… 2.42        
#>  5 ""                           22 Liverpool Road       Energy Ass… 2.6         
#>  6 ""                           5 Liverpool Road        Energy Ass… 2.16        
#>  7 ""                           60 Liverpool Road, Aug… Energy Ass… 2.54        
#>  8 ""                           546 Liverpool Road, Ha… Energy Ass… 2.46        
#>  9 ""                           104 Liverpool Road, Gr… Energy Ass… 2.6         
#> 10 ""                           Flat, 575 Liverpool Ro… Energy Ass… 2.52        
#> # ℹ 17,758 more rows
#> # ℹ 89 more variables: heating_cost_potential <chr>,
#> #   unheated_corridor_length <chr>, hot_water_cost_potential <chr>,
#> #   construction_age_band <chr>, potential_energy_rating <chr>,
#> #   mainheat_energy_eff <chr>, windows_env_eff <chr>,
#> #   lighting_energy_eff <chr>, environment_impact_potential <chr>,
#> #   glazed_type <chr>, heating_cost_current <chr>, address3 <chr>, …
```

Manual control over the pagination can be achived with:

``` r
energizer::odc_search_data(
    address = "liverpool road",
    type = "domestic",
    paginate = "manual", 
    size = 5000
)
#> # A tibble: 5,000 × 93
#>    low_energy_fixed_light_count address                 uprn_source floor_height
#>    <chr>                        <chr>                   <chr>       <chr>       
#>  1 ""                           329 Old Liverpool Road  Energy Ass… 2.7         
#>  2 ""                           93 Liverpool Road       Energy Ass… 2.64        
#>  3 ""                           44 Liverpool Road       Energy Ass… 2.4         
#>  4 ""                           2a Crown Buildings, Li… Energy Ass… 2.42        
#>  5 ""                           22 Liverpool Road       Energy Ass… 2.6         
#>  6 ""                           5 Liverpool Road        Energy Ass… 2.16        
#>  7 ""                           60 Liverpool Road, Aug… Energy Ass… 2.54        
#>  8 ""                           546 Liverpool Road, Ha… Energy Ass… 2.46        
#>  9 ""                           104 Liverpool Road, Gr… Energy Ass… 2.6         
#> 10 ""                           Flat, 575 Liverpool Ro… Energy Ass… 2.52        
#> # ℹ 4,990 more rows
#> # ℹ 89 more variables: heating_cost_potential <chr>,
#> #   unheated_corridor_length <chr>, hot_water_cost_potential <chr>,
#> #   construction_age_band <chr>, potential_energy_rating <chr>,
#> #   mainheat_energy_eff <chr>, windows_env_eff <chr>,
#> #   lighting_energy_eff <chr>, environment_impact_potential <chr>,
#> #   glazed_type <chr>, heating_cost_current <chr>, address3 <chr>, …
```

In addition to the usual output, this also returns the
`X-Next-Search-After` response header, which can be passed to the
subsequent search via the `search_after` input argument.

## ⬇️ Bulk Download

`energizer` wraps the bulk download functionality provided by the API:

``` r
energizer::odc_bulk_download(
  file_name = "non-domestic-E08000025-Birmingham.zip",
  destination_path = here::here(),
  type = "certificate"
)
```

To save the `.zip` file together with the `.csv` file, set
`keep_zip = TRUE`:

``` r
energizer::odc_bulk_download(
  file_name = "non-domestic-E08000025-Birmingham.zip",
  destination_path = here::here(),
  type = "certificate",
  keep_zip = TRUE
)
```

## 🔎 Search Features

- Flexible filtering: `address`, `postcode`, `local_authority`, `dates`,
  `property_type`, etc.

- Smart pagination: three modes (`"none"`, `"all"`, `"manual"`)

- Result control: `max_records` and `max_pages` parameters

- Automatic type conversion: Use `local_authority` instead of
  `local-authority`

## ⚠️ Disclaimer

*This package is not affiliated with or endorsed by the UK Department
for Levelling Up, Housing and Communities or the Open Data Communities
service.*
