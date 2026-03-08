# Connect to a GlitchTip or Sentry-compatible instance

Parses a DSN and returns a connection object used by
[`gt_capture()`](https://hyperverse-r.github.io/glitchtipr/reference/gt_capture.md).
If `dsn` is empty or missing, a inactive connection is returned and
[`gt_capture()`](https://hyperverse-r.github.io/glitchtipr/reference/gt_capture.md)
will be a no-op — the application continues to run normally.

## Usage

``` r
gt_connect(dsn = Sys.getenv("GLITCHTIP_DSN"))
```

## Arguments

- dsn:

  DSN string in the format `https://KEY@HOST/PROJECT_ID`. Defaults to
  the `GLITCHTIP_DSN` environment variable.

## Value

A `gt_connection` object.

## Examples

``` r
# From environment variable (recommended)
gt <- gt_connect()

# Explicit DSN
gt <- gt_connect("https://key@glitchtip.example.com/1")
```
