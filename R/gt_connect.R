#' Connect to a GlitchTip or Sentry-compatible instance
#'
#' Parses a DSN and returns a connection object used by [gt_capture()].
#' If `dsn` is empty or missing, a inactive connection is returned and
#' [gt_capture()] will be a no-op — the application continues to run normally.
#'
#' @param dsn DSN string in the format `https://KEY@HOST/PROJECT_ID`.
#'   Defaults to the `GLITCHTIP_DSN` environment variable.
#'
#' @return A `gt_connection` object.
#'
#' @examples
#' # From environment variable (recommended)
#' gt <- gt_connect()
#'
#' # Explicit DSN
#' gt <- gt_connect("https://key@glitchtip.example.com/1")
#'
#' @export
gt_connect <- function(dsn = Sys.getenv("GLITCHTIP_DSN")) {
  if (!nzchar(dsn)) {
    return(structure(list(active = FALSE), class = "gt_connection"))
  }

  m <- regmatches(dsn, regexec("^https://([^@]+)@([^/]+)/([0-9]+)$", dsn))[[1]]
  if (length(m) < 4) {
    stop(
      "Invalid DSN format. Expected: https://KEY@HOST/PROJECT_ID",
      call. = FALSE
    )
  }

  structure(
    list(
      active = TRUE,
      key = m[2],
      url = paste0("https://", m[3], "/api/", m[4], "/store/")
    ),
    class = "gt_connection"
  )
}

#' @export
print.gt_connection <- function(x, ...) {
  if (!x$active) {
    cat("<gt_connection> inactive (no DSN configured)\n")
  } else {
    cat("<gt_connection>\n")
    cat("  url:", x$url, "\n")
  }
  invisible(x)
}
