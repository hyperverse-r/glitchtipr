test_that("gt_connect() returns active connection from valid DSN", {
  gt <- gt_connect("https://mykey@glitchtip.example.com/42")

  expect_true(gt$active)
  expect_equal(gt$key, "mykey")
  expect_equal(gt$url, "https://glitchtip.example.com/api/42/store/")
  expect_s3_class(gt, "gt_connection")
})

test_that("gt_connect() returns inactive connection for empty DSN", {
  gt <- gt_connect("")

  expect_false(gt$active)
  expect_s3_class(gt, "gt_connection")
})

test_that("gt_connect() stops on invalid DSN — not https", {
  expect_error(gt_connect("http://key@host.com/1"), "Invalid DSN format")
})

test_that("gt_connect() stops on invalid DSN — no key separator", {
  expect_error(
    gt_connect("https://glitchtip.example.com/1"),
    "Invalid DSN format"
  )
})

test_that("gt_connect() stops on invalid DSN — non-numeric project id", {
  expect_error(
    gt_connect("https://key@host.com/myproject"),
    "Invalid DSN format"
  )
})

test_that("gt_connect() stops on invalid DSN — plain string", {
  expect_error(gt_connect("not-a-dsn"), "Invalid DSN format")
})

test_that("gt_connect() reads from GLITCHTIP_DSN env var", {
  withr::local_envvar(GLITCHTIP_DSN = "https://envkey@glitchtip.example.com/99")

  gt <- gt_connect()

  expect_true(gt$active)
  expect_equal(gt$key, "envkey")
  expect_equal(gt$url, "https://glitchtip.example.com/api/99/store/")
})

test_that("gt_connect() returns inactive when GLITCHTIP_DSN is not set", {
  withr::local_envvar(GLITCHTIP_DSN = "")

  gt <- gt_connect()

  expect_false(gt$active)
})

test_that("print.gt_connection() shows 'inactive' for inactive connection", {
  gt <- gt_connect("")
  expect_output(print(gt), "inactive")
})

test_that("print.gt_connection() shows URL for active connection", {
  gt <- gt_connect("https://key@glitchtip.example.com/1")
  expect_output(print(gt), "https://glitchtip.example.com/api/1/store/")
})
