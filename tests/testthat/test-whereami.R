context("reactivity")
library(tidytuesday201942)
library(RSelenium)
library(whereami)

shiny_cmds <- c(
  "pkgload::load_all()",
  "library(whereami)",
  glue::glue('whereami::set_whereami_log("{getwd()}")'),
  "run_app(shiny_opts = list(port = 6012L))"
)

x <- processx::process$new(
  "R", c("-e", paste0(shiny_cmds,collapse = ';')),
  stderr = 'err.txt',stdout = 'out.txt')


cDrv <- wdman::chrome()
rD <- RSelenium::rsDriver(verbose = FALSE,port = 1323L)
remDr <- rD$client

appURL <- "http://127.0.0.1:6012"
remDr$navigate(appURL)

webElem <- remDr$findElement("css selector", "#raw_data > div > ul > li:nth-child(1) > a")
webElem$clickElement()

buttonElem <- remDr$findElement("css selector", "#dataviz_ui_1-go")
buttonElem$clickElement()

remDr$closeall()

x$kill()
