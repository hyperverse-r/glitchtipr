#' Register the @capture plumber2 tag
#'
#' Called automatically at package load via `.onLoad()`. Registers a custom
#' plumber2 tag that wraps route handlers with [gt_capture()].
#'
#' @section Usage in `api.R`:
#'
#' ```r
#' gt <- gt_connect()
#'
#' #* @capture
#' #* @get /data
#' function(request) {
#'   list(data = rnorm(10))
#' }
#' ```
#'
#' A custom connection variable name can be specified:
#' `#* @capture my_gt`
#'
#' @importFrom plumber2 add_plumber2_tag
#' @noRd
.gt_register_tag <- function() {
  add_plumber2_tag("capture", function(block, call, tags, values, env) {
    if (!inherits(block, "plumber2_handler_block")) {
      stop(
        "@capture can only be used on route handlers ",
        "(@get, @post, @put, @delete, @patch, @any).",
        call. = FALSE
      )
    }

    # Resolve gt variable name (default: "gt")
    idx <- which(tags == "capture")[1]
    gt_name_raw <- values[[idx]]
    gt_name <- if (is.null(gt_name_raw) || !nzchar(trimws(gt_name_raw))) {
      "gt"
    } else {
      trimws(gt_name_raw)
    }

    # Look up gt in api.R's environment
    gt_obj <- tryCatch(
      get(gt_name, envir = env, inherits = TRUE),
      error = function(e) {
        stop(
          "@capture: object '",
          gt_name,
          "' not found in api.R. ",
          "Define `",
          gt_name,
          " <- gt_connect()` before using @capture.",
          call. = FALSE
        )
      }
    )

    # Wrap the route handler — filter args to match original_fn's formals,
    # then forward request for richer error reports
    original_fn <- block$handler
    block$handler <- function(...) {
      args <- list(...)
      req <- args[["request"]]
      fn_params <- names(formals(original_fn))
      call_args <- if ("..." %in% fn_params) args else
        args[intersect(names(args), fn_params)]
      gt_capture(gt_obj, do.call(original_fn, call_args), request = req)
    }

    block
  })
}

.onLoad <- function(libname, pkgname) {
  .gt_register_tag()
}
