gt_test_connect <- function(active = TRUE) {
  if (active) {
    structure(
      list(
        active = TRUE,
        key = "testkey",
        url = "https://glitchtip.example.com/api/1/store/"
      ),
      class = "gt_connection"
    )
  } else {
    structure(list(active = FALSE), class = "gt_connection")
  }
}

make_mock_request <- function(
  url = "http://localhost/api",
  method = "GET",
  querystring = "",
  headers = list(),
  ip = "127.0.0.1"
) {
  list(
    url = url,
    method = method,
    querystring = querystring,
    headers = headers,
    ip = ip
  )
}
