write_union <- function(base_path, path, new_lines, quiet = FALSE) {
  stopifnot(is.character(new_lines))

  full_path <- file.path(base_path, path)
  if (file.exists(full_path)) {
    lines <- readLines(full_path, warn = FALSE)
  } else {
    lines <- character()
  }

  new <- setdiff(new_lines, lines)
  if (length(new) == 0)
    return(invisible(FALSE))

  if (!quiet) {
    quoted <- paste0(value(new), collapse = ", ")
    done("Adding ", quoted, " to ", value(path))
  }

  all <- union(lines, new_lines)
  write_utf8(full_path, all)
}

write_over <- function(base_path, path, contents) {
  stopifnot(is.character(contents), length(contents) == 1)

  full_path <- file.path(base_path, path)
  dir.create(dirname(full_path), showWarnings = FALSE)

  if (same_contents(full_path, contents))
    return(invisible(FALSE))

  if (!can_overwrite(full_path))
    stop(value(path), " already exists.", call. = FALSE)

  done("Writing ", value(path))
  write_utf8(full_path, contents)
}

write_utf8 <- function(path, lines, append = FALSE) {
  stopifnot(is.character(path))
  stopifnot(is.character(lines))

  conn_mode <- if(append) "a" else "w"
  con <- file(path, conn_mode, encoding = "utf-8")
  on.exit(close(con), add = TRUE)

  if (length(lines) > 1) {
    lines <- paste0(lines, "\n", collapse = "")
  }
  cat(lines, file = con, sep = "")

  invisible(TRUE)
}

write_append <- function(base_path, path, contents) {
  stopifnot(is.character(contents), length(contents) == 1)

  full_path <- file.path(base_path, path)
  done(paste0("* Writing additional contents to '", value(path), "'"))
  write_utf8(full_path, contents, append = TRUE)
  TRUE
}

same_contents <- function(path, contents) {
  if (!file.exists(path))
    return(FALSE)

  text_hash <- digest::digest(contents, serialize = FALSE)
  file_hash <- digest::digest(file = path)

  identical(text_hash, file_hash)
}
