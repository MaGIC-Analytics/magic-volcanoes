function(input, output, session) {
    options(shiny.maxRequestSize=50*1024^2)
    source('ui.R',local=TRUE)
    source('input.R',local=TRUE)
    source('tabmanagement.R',local=TRUE)
    source('volcano.R',local=TRUE)
}