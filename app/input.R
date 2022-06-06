output$data_selector <- renderUI({
    if (is.null(input$de_file)) return()
    tagList(
        h3('Select which columns will be the input data for the volcano plot.'),
        hr(),
        selectInput("VolX", label="Choose X axis column", choices=NULL),
        p("Generally the X axis would be your expression comparator such as log2FoldChange"),
        hr(),
        selectInput("VolY", label="Choose Y axis column", choices=NULL),
        p("Generally the Y axis would be your significance value, such as p-value or padj"),
        actionButton('submit',"Submit Data",class='btn btn-info'),
        p("Once the data is submitted, you can view the plot on the Volcano Plots tab")
    )
})

output$data_demo <- renderUI({
    tagList(
        h3('Select which demo columns will be the input data for the volcano plot.'),
        hr(),
        selectInput("DemoX", label="Choose X axis column", choices=c('Geneid','log2FoldChange','padj'), selected='log2FoldChange'),
        hr(),
        selectInput("DemoY", label="Choose Y axis column", choices=c('Geneid','log2FoldChange','padj'), selected='padj'),
        actionButton('demo_submit',"Submit Demo Data",class='btn btn-info'),
        p("Play with some demo data!")
    )
})

observe({
    vol_options=colnames(InputReactive())
    updateSelectInput(session, "VolX", choices=vol_options)
    updateSelectInput(session, "VolY", choices=vol_options)
})


InputReactive <- reactive({

    if(input$DemoData==TRUE){
        shiny::validate(
            need((!is.null(input$de_file)),
            message='Please enter a valid csv or tsv file')
        )
        
        tryCatch({
            de_data <- fread(input$de_file$datapath)
        },
        error=function(e)
        {
            showNotification(id="errorNotify", paste(e$Message), type='error', duration=NULL)
        })

    
    } else if(input$DemoData==FALSE){
        tryCatch({
            de_data <- fread('www/demo.csv')
        },
        error=function(e)
        {
            showNotification(id="errorNotify", paste(e$Message), type='error', duration=NULL)
        })

    
    }
    return(de_data)

})

output$input_table <- DT::renderDataTable({
    DT::datatable(InputReactive(), style='bootstrap',options=list(pageLength = 15,scrollX=TRUE))
})