compare_character <- function(x, y, x_path = "x", y_path = "y") {
  attributes(x) <- NULL
  attributes(y) <- NULL

  diff_element(x, y, x_path = x_path, y_path = y_path)
}

compare_numeric <- function(x,
                            y,
                            x_path = "x",
                            y_path = "y",
                            tolerance = .Machine$double.eps^0.5
                            ) {
  attributes(x) <- NULL
  attributes(y) <- NULL

  if (num_equal(x, y, tolerance)) {
    return(new_compare())
  }

  x_cmp <- num_format(x)
  y_cmp <- num_format(y)

  diff <- ses(x_cmp, y_cmp)

  if (nrow(diff) == 0) {
    xi <- seq_along(x)
    diff <- ses_df(xi, xi, "c", xi, xi)[x != y, , drop = FALSE]
    x_cmp <- num_format(y - x)
    y_cmp <- rep(0, length(x))
    path <- glue("\u0394{path}")
  }

  chunks <- diff_split(diff, length(x))
  out <- map_chr(chunks, diff_render, x = x_cmp, y = y_cmp, path = x_path,
    diff_a = function(x) cli::col_blue("+", x),
    diff_d = function(x) cli::col_yellow("-", x),
    diff_c = function(x, y) paste0(cli::col_yellow(x), "/", cli::col_blue(y)),
    path_context = function(path, start, end) glue("{path}[{start}:{end}]"),
    combine = function(path, diff) paste0(path, ": ", paste0(diff, collapse = " "))
  )
  new_compare(out)
}