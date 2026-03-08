# Capture and report errors to GlitchTip

Evaluates `expr` and reports any error to GlitchTip before letting it
propagate. Uses
[`withCallingHandlers()`](https://rdrr.io/r/base/conditions.html)
internally so the full call stack is preserved in the report.

## Usage

``` r
gt_capture(gt, expr, request = NULL)
```

## Arguments

- gt:

  A `gt_connection` object created by
  [`gt_connect()`](https://hyperverse-r.github.io/glitchtipr/reference/gt_connect.md).

- expr:

  An expression to evaluate (supports
  [`{ }`](https://rdrr.io/r/base/Paren.html) blocks).

- request:

  Optional plumber2 `request` object. When provided, the endpoint path
  and HTTP method are included in the error report.

## Value

The value of `expr`, invisibly. Errors are re-raised after reporting.

## Details

If `gt` is an inactive connection (no DSN configured), `expr` is
evaluated normally and nothing is reported.

## Examples

``` r
# With an inactive connection (no DSN), gt_capture() is a transparent no-op
gt <- gt_connect()

result <- gt_capture(gt, 1 + 1)
```
