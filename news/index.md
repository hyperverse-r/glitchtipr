# Changelog

## glitchtipr 0.1.0

- Initial CRAN release.
- [`gt_connect()`](https://hyperverse-r.github.io/glitchtipr/reference/gt_connect.md)
  — parse a GlitchTip/Sentry DSN and return a connection object. Returns
  an inactive connection when no DSN is configured.
- [`gt_capture()`](https://hyperverse-r.github.io/glitchtipr/reference/gt_capture.md)
  — wrap any R expression to capture and report errors to GlitchTip
  before re-raising them. No-op when connection is inactive.
- `@capture` plumber2 tag — one annotation to protect a route handler,
  with full request context (endpoint, query string, sanitised headers)
  included in the error report.
