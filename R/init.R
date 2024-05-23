# Functions for package initialization

.onLoad <- function(libname, pkgname) {
  options(ld_prompt = c("@", ">"))
}