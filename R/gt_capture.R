#' Capture and report errors to GlitchTip
#'
#' Evaluates `expr` and reports any error to GlitchTip before letting it
#' propagate. Uses `withCallingHandlers()` internally so the full call stack
#' is preserved in the report.
#'
#' If `gt` is an inactive connection (no DSN configured), `expr` is evaluated
#' normally and nothing is reported.
#'
#' @param gt A `gt_connection` object created by [gt_connect()].
#' @param expr An expression to evaluate (supports `{ }` blocks).
#' @param request Optional plumber2 `request` object. When provided, the
#'   endpoint path and HTTP method are included in the error report.
#'
#' @return The value of `expr`, invisibly. Errors are re-raised after
#'   reporting.
#'
#' @examples
#' # With an inactive connection (no DSN), gt_capture() is a transparent no-op
#' gt <- gt_connect()
#'
#' result <- gt_capture(gt, 1 + 1)
#'
#' @export
gt_capture <- function(gt, expr, request = NULL) {
  if (!gt$active) return(invisible(expr))

  withCallingHandlers(
    expr,
    error = function(e) {
      .gt_report(gt, e, request = request)
    }
  )
}
