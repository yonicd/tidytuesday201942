#' Run the Shiny Application
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(...,shiny_opts = list(port = 1234L)) {
  with_golem_options(
    app = shinyApp(ui = app_ui, server = app_server,options = shiny_opts), 
    golem_opts = list(...)
  )
}
