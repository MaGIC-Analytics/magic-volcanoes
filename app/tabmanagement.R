# Hiding and showing tabs on command!
############################################################################
observe({
    if(is.null(input$de_data)){
        hideTab(inputId = "NAVTABS", target = "Volcano Plots")
    }
})

observeEvent(input$submit,{
    if( (!is.null(input$VolX)) & (!is.null(input$VolY))){
        showTab(inputId = "NAVTABS", target = "Volcano Plots")
        updateTabsetPanel(session, inputId="NAVTABS", selected="Volcano Plots")
    }      
})

observeEvent(input$demo_submit,{
    showTab(inputId = "NAVTABS", target = "Volcano Plots")
    updateTabsetPanel(session, inputId="NAVTABS", selected="Volcano Plots")
})
