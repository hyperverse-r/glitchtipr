#' @importFrom httr2 request req_headers req_body_json req_perform
#' @noRd
.gt_report <- function(gt, e, request = NULL) {
  payload <- list(
    event_id = .gt_event_id(),
    timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
    level = "error",
    platform = "other",
    logger = "glitchtipr",
    exception = list(
      values = list(list(
        type = class(e)[1],
        value = conditionMessage(e)
      ))
    )
  )

  if (!is.null(request)) {
    h <- request$headers
    if (!is.list(h) || is.null(names(h))) h <- as.list(h)
    # plumber2 lowercases header names and replaces hyphens with underscores
    h[tolower(names(h)) %in% c("authorization", "cookie", "x_api_key")] <- NULL
    # flatten single-element vectors to plain strings
    h <- lapply(h, paste, collapse = ", ")

    payload$request <- list(
      url = request$url,
      method = toupper(request$method),
      query_string = sub("^\\?", "", request$querystring),
      headers = h,
      env = list(REMOTE_ADDR = request$ip)
    )

    # Fingerprint sur type + message + chemin (sans query params)
    # pour grouper les occurrences du même bug quelle que soit la valeur des params
    path <- sub("\\?.*$", "", request$url)
    payload$fingerprint <- list(class(e)[1], conditionMessage(e), path)
  }

  tryCatch(
    request(gt$url) |>
      req_headers(
        "Content-Type" = "application/json",
        "X-Sentry-Auth" = paste0(
          "Sentry sentry_version=7, ",
          "sentry_key=",
          gt$key,
          ", ",
          "sentry_client=glitchtipr/0.1.0, ",
          "sentry_timestamp=",
          as.integer(Sys.time())
        )
      ) |>
      req_body_json(payload) |>
      req_perform(),
    error = function(e) {
      message("glitchtipr: failed to report error: ", conditionMessage(e))
    }
  )

  invisible(NULL)
}

#' @noRd
.gt_event_id <- function() {
  paste0(sample(c(letters[1:6], 0:9), 32, replace = TRUE), collapse = "")
}
