test_that(".gt_event_id() produces a 32-char hex string", {
  id <- glitchtipr:::.gt_event_id()

  expect_equal(nchar(id), 32)
  expect_match(id, "^[0-9a-f]{32}$")
})

test_that(".gt_event_id() produces unique values", {
  ids <- replicate(20, glitchtipr:::.gt_event_id())
  expect_gt(length(unique(ids)), 1)
})

test_that(".gt_report() messages silently when HTTP fails", {
  gt <- gt_test_connect()
  e <- simpleError("test error")

  httptest2::without_internet({
    expect_message(
      glitchtipr:::.gt_report(gt, e),
      "glitchtipr: failed to report error"
    )
  })
})

test_that(".gt_report() does not raise when HTTP fails", {
  gt <- gt_test_connect()
  e <- simpleError("test error")

  httptest2::without_internet({
    expect_no_error(
      suppressMessages(glitchtipr:::.gt_report(gt, e))
    )
  })
})

test_that(".gt_report() POSTs to the correct GlitchTip endpoint", {
  gt <- gt_test_connect()
  e <- simpleError("test error")
  captured_url <- NULL
  captured_body <- NULL

  testthat::local_mocked_bindings(
    req_perform = function(req, ...) {
      captured_url <<- req$url
      captured_body <<- req$body # non-NULL body means httr2 will use POST
      structure(
        list(
          url = req$url,
          status_code = 200L,
          headers = list(),
          body = raw(0)
        ),
        class = "httr2_response"
      )
    },
    # No .package — mocks in glitchtipr's namespace where httr2 fns are @importFrom-ed
  )

  glitchtipr:::.gt_report(gt, e)

  expect_equal(captured_url, "https://glitchtip.example.com/api/1/store/")
  expect_false(is.null(captured_body))
})

test_that(".gt_report() payload includes required Sentry fields", {
  gt <- gt_test_connect()
  e <- simpleError("something went wrong")

  payload <- NULL

  # Intercept req_body_json to capture the payload before HTTP
  testthat::local_mocked_bindings(
    req_body_json = function(req, data, ...) {
      payload <<- data
      req
    },
    req_perform = function(req, ...) {
      structure(
        list(
          method = "POST",
          url = req$url,
          status_code = 200L,
          headers = list(),
          body = charToRaw("{}")
        ),
        class = "httr2_response"
      )
    },
    # No .package — mocks in glitchtipr's namespace where httr2 fns are @importFrom-ed
  )

  glitchtipr:::.gt_report(gt, e)

  expect_equal(payload$level, "error")
  expect_equal(payload$platform, "other")
  expect_equal(payload$logger, "glitchtipr")
  expect_equal(nchar(payload$event_id), 32)
  expect_equal(payload$exception$values[[1]]$type, "simpleError")
  expect_equal(payload$exception$values[[1]]$value, "something went wrong")
  expect_null(payload$request)
})

test_that(".gt_report() includes request block when request is provided", {
  gt <- gt_test_connect()
  e <- simpleError("test error")
  req <- make_mock_request(url = "http://localhost/api/data", method = "GET")

  payload <- NULL

  testthat::local_mocked_bindings(
    req_body_json = function(req, data, ...) {
      payload <<- data
      req
    },
    req_perform = function(req, ...) {
      structure(
        list(
          method = "POST",
          url = req$url,
          status_code = 200L,
          headers = list(),
          body = charToRaw("{}")
        ),
        class = "httr2_response"
      )
    },
    # No .package — mocks in glitchtipr's namespace where httr2 fns are @importFrom-ed
  )

  glitchtipr:::.gt_report(gt, e, request = req)

  expect_equal(payload$request$method, "GET")
  expect_equal(payload$request$url, "http://localhost/api/data")
  expect_length(payload$fingerprint, 3)
})

test_that(".gt_report() strips sensitive headers from request block", {
  gt <- gt_test_connect()
  e <- simpleError("test error")
  req <- make_mock_request(
    headers = list(
      authorization = "Bearer secret-token",
      cookie = "session=abc123",
      x_api_key = "myapikey",
      accept = "application/json"
    )
  )

  payload <- NULL

  testthat::local_mocked_bindings(
    req_body_json = function(req, data, ...) {
      payload <<- data
      req
    },
    req_perform = function(req, ...) {
      structure(
        list(
          method = "POST",
          url = req$url,
          status_code = 200L,
          headers = list(),
          body = charToRaw("{}")
        ),
        class = "httr2_response"
      )
    },
    # No .package — mocks in glitchtipr's namespace where httr2 fns are @importFrom-ed
  )

  glitchtipr:::.gt_report(gt, e, request = req)

  expect_null(payload$request$headers$authorization)
  expect_null(payload$request$headers$cookie)
  expect_null(payload$request$headers$x_api_key)
  expect_equal(payload$request$headers$accept, "application/json")
})

test_that(".gt_report() fingerprint uses [type, message, path] without query string", {
  gt <- gt_test_connect()
  e <- simpleError("not found")
  req <- make_mock_request(url = "http://localhost/items?page=2&limit=10")

  payload <- NULL

  testthat::local_mocked_bindings(
    req_body_json = function(req, data, ...) {
      payload <<- data
      req
    },
    req_perform = function(req, ...) {
      structure(
        list(
          method = "POST",
          url = req$url,
          status_code = 200L,
          headers = list(),
          body = charToRaw("{}")
        ),
        class = "httr2_response"
      )
    },
    # No .package — mocks in glitchtipr's namespace where httr2 fns are @importFrom-ed
  )

  glitchtipr:::.gt_report(gt, e, request = req)

  fp <- payload$fingerprint
  expect_equal(fp[[1]], "simpleError")
  expect_equal(fp[[2]], "not found")
  expect_equal(fp[[3]], "http://localhost/items") # no query string
})
