testwhereami <- function(expr, dirpath = tempdir()){
  
  on.exit({
    remDr$closeall()
    rD$server$stop()
    cDrv$stop()
    x$kill()
    unlink(shiny_testdir,recursive = TRUE,force = TRUE)
  })
  
  shiny_testdir <- file.path(dirpath,'whereami_test')
  shiny_err     <- file.path(shiny_testdir,'err.txt')
  shiny_out     <- file.path(shiny_testdir,'out.txt')
  shiny_where   <- file.path(shiny_testdir,'whereami.json')
  
  dir.create(shiny_testdir,showWarnings = FALSE)
  test_ip <- 6012
  
  shiny_cmds <- c(
    "pkgload::load_all()",
    "library(whereami)",
    glue::glue("whereami::set_whereami_log('{shiny_testdir}')"),
    glue::glue("run_app(shiny_opts = list(port = {test_ip}L))")
  )
  
  x <- processx::process$new(
    "R", c("-e", paste0(shiny_cmds,collapse = ';')),
    stderr = shiny_err,
    stdout = shiny_out)
  
  chrome_args <- c("--headless","--disable-gpu", "--window-size=1280,800")
  
  chrome_pref = list(
    "profile.default_content_settings.popups" = 0L,
    "download.prompt_for_download" = FALSE,
    "download.directory_upgrade" = TRUE,
    "safebrowsing.enabled" = TRUE,
    "download.default_directory" = dirpath
  )
  
  chrome_options <- list(args = chrome_args, prefs = chrome_pref)
  
  cDrv <- wdman::chrome(
    verbose = FALSE,
    check = FALSE
  )
  
  rD <- RSelenium::rsDriver(
    browser = "chrome",
    verbose = FALSE,
    port = 4567L,
    extraCapabilities = list(
      chromeOptions = chrome_options
    ),
    check = FALSE
  )
  
  remDr <- rD$client
  
  remDr$navigate(glue::glue("http://127.0.0.1:{test_ip}"))
  
  eval(substitute(expr))
  
  file.timeout(shiny_where)
  
  return(jsonlite::read_json(shiny_where,simplifyVector = TRUE))
  
}


expect_count <- function(counter,tag,exptected){
  
  testthat::expect_equal(
  max(counter$count[counter$tag==tag]),
  exptected
  )
  
}

# https://goo.gl/jFqKfS
asyncr <- function(remDr, using, value, maxiter = 20, attrib = NULL) {
  
  elem <- NULL
  
  i <- 0
  
  while (is.null(elem) & (i <= maxiter)) {
    
    suppressMessages({
      elem <- tryCatch({
        remDr$findElement(using = using, value = value)
      },
      error = function(e) {
        NULL
      }
      )
    })
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  if (is.null(elem) && i >= maxiter) {
    # assuming this means timed out
    stop("servers failed, please check network connectivity and try again",
         call. = FALSE
    )
  }
  
  if(!is.null(attrib)){
    
    attr_out <- NULL
    
    i <- 0
    
    while (is.null(attr_out) & (i <= maxiter)) {
    
      attr_out <- tryCatch({
        elem$getElementAttribute(attrib)[[1]]
      },
      error = function(e) {
        NULL
      }
      )
    
      Sys.sleep(0.02 * (i + 1))
      
      i <- i + 1
    }
    
    attr_out
    
  }else{
    
    elem
    
  }
  
  
}

asyncr_update <- function(remDr, using, value, maxiter = 20, attrib, old_value){
  
  if(is.null(old_value))
    return(NULL)
  
  elem_update <- FALSE
  
  i <- 1
  
  while (!elem_update & (i <= maxiter)) {
    
    new_value <- asyncr(remDr, using = using, value = value, maxiter = maxiter, attrib = attrib)
    
    elem_update <- identical(old_value, new_value)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  invisible(new_value)
}


file.timeout <- function(path, maxiter = 20) {
  
  file_found <- FALSE
  
  i <- 0
  
  while (!file_found & (i <= maxiter)) {
    
    file_found <- file.exists(path)
    
    Sys.sleep(0.02 * (i + 1))
    
    i <- i + 1
  }
  
  if (i >= maxiter) {
    # assuming this means timed out
    stop("Could not find file in path, 
         please check network connectivity and try again",
         call. = FALSE
    )
  }
  
}
