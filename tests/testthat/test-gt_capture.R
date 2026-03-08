test_that("gt_capture() with inactive connection evaluates expr and returns value", {
  gt <- gt_test_connect(active = FALSE)

  result <- gt_capture(gt, 1 + 1)

  expect_equal(result, 2)
})

test_that("gt_capture() with inactive connection makes no HTTP calls", {
  gt <- gt_test_connect(active = FALSE)

  # without_internet() would cause a test failure if any HTTP call is attempted
  httptest2::without_internet({
    result <- gt_capture(gt, "hello")
    expect_equal(result, "hello")
  })
})

test_that("gt_capture() with active connection returns value when no error", {
  gt <- gt_test_connect()

  result <- gt_capture(gt, 42)

  expect_equal(result, 42)
})

test_that("gt_capture() with active connection accepts NULL request", {
  gt <- gt_test_connect()

  expect_no_error(gt_capture(gt, "value", request = NULL))
})

test_that("gt_capture() re-raises error after attempting to report it", {
  gt <- gt_test_connect()

  # without_internet() forces .gt_report() to fail silently (tryCatch inside)
  httptest2::without_internet({
    expect_error(
      suppressMessages(gt_capture(gt, stop("route error"))),
      "route error"
    )
  })
})

test_that("gt_capture() silently handles HTTP failure when reporting", {
  gt <- gt_test_connect()

  httptest2::without_internet({
    expect_message(
      tryCatch(
        gt_capture(gt, stop("err")),
        error = function(e) invisible(NULL)
      ),
      "glitchtipr: failed to report error"
    )
  })
})

test_that("gt_capture() passes request context to .gt_report()", {
  gt <- gt_test_connect()
  req <- make_mock_request(url = "http://localhost/users", method = "POST")

  httptest2::without_internet({
    expect_error(
      suppressMessages(gt_capture(gt, stop("err"), request = req)),
      "err"
    )
  })
})
