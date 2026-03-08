# Helper: capture the tag handler registered via add_plumber2_tag.
# add_plumber2_tag is @importFrom plumber2 into glitchtipr's namespace,
# so we mock it there (not in plumber2's namespace).
capture_tag_fn <- function() {
  tag_fn <- NULL

  testthat::local_mocked_bindings(
    add_plumber2_tag = function(name, fn) {
      tag_fn <<- fn
    }
  )

  glitchtipr:::.gt_register_tag()

  tag_fn
}

# Helper: a minimal plumber2_handler_block
make_handler_block <- function(handler = function(request) "ok") {
  structure(
    list(handler = handler),
    class = c("plumber2_handler_block", "plumber2_block")
  )
}

test_that(".gt_register_tag() executes without error", {
  expect_no_error(glitchtipr:::.gt_register_tag())
})

test_that("@capture tag errors on non-handler block", {
  tag_fn <- capture_tag_fn()

  non_handler <- structure(list(), class = "plumber2_block")

  expect_error(
    tag_fn(
      block = non_handler,
      call = NULL,
      tags = "capture",
      values = list(NULL),
      env = new.env()
    ),
    "@capture can only be used on route handlers"
  )
})

test_that("@capture tag errors when gt variable is missing from env", {
  tag_fn <- capture_tag_fn()

  block <- make_handler_block()
  empty_env <- new.env(parent = emptyenv())

  expect_error(
    tag_fn(
      block = block,
      call = NULL,
      tags = "capture",
      values = list(NULL),
      env = empty_env
    ),
    "'gt' not found in api.R"
  )
})

test_that("@capture tag errors with correct variable name in message", {
  tag_fn <- capture_tag_fn()

  block <- make_handler_block()
  empty_env <- new.env(parent = emptyenv())

  expect_error(
    tag_fn(
      block = block,
      call = NULL,
      tags = c("capture"),
      values = list("my_gt"),
      env = empty_env
    ),
    "'my_gt' not found in api.R"
  )
})

test_that("@capture tag wraps handler in a new function", {
  tag_fn <- capture_tag_fn()

  original_fn <- function(request) "original result"
  block <- make_handler_block(original_fn)

  api_env <- new.env(parent = emptyenv())
  api_env$gt <- gt_test_connect()

  modified_block <- tag_fn(
    block = block,
    call = NULL,
    tags = "capture",
    values = list(NULL),
    env = api_env
  )

  expect_false(identical(modified_block$handler, original_fn))
})

test_that("@capture wrapped handler passes through return value", {
  tag_fn <- capture_tag_fn()

  block <- make_handler_block(function(request) "hello world")

  api_env <- new.env(parent = emptyenv())
  api_env$gt <- gt_test_connect()

  modified_block <- tag_fn(
    block = block,
    call = NULL,
    tags = "capture",
    values = list(NULL),
    env = api_env
  )

  result <- modified_block$handler(request = NULL)

  expect_equal(result, "hello world")
})

test_that("@capture wrapped handler uses custom gt variable name", {
  tag_fn <- capture_tag_fn()

  block <- make_handler_block(function(request) "custom")

  api_env <- new.env(parent = emptyenv())
  api_env$my_gt <- gt_test_connect()

  modified_block <- tag_fn(
    block = block,
    call = NULL,
    tags = c("capture"),
    values = list("my_gt"),
    env = api_env
  )

  result <- modified_block$handler(request = NULL)

  expect_equal(result, "custom")
})
