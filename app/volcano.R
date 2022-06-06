observe({
    vol_options=colnames(InputReactive())
    updateSelectInput(session, "VLabBy", choices=vol_options)
})

observe({
    GenesList=unique(InputReactive()[[input$VLabBy]])
    updateSelectizeInput(session, "VLabs", choices=GenesList, server=TRUE, options = list(maxOptions = 50))
})

volcano_plotter <- reactive({
    DataSet=InputReactive()
    if(input$ShowLabs==FALSE){
        vol_lab=''
    }
    else{
        vol_lab=as.character(DataSet[[input$VLabBy]])
    }
    if(input$Select==FALSE){
        sel_lab=NULL
    }
    else{
        sel_lab=c(input$VLabs)
    }
    if(input$DemoData==TRUE){
        volx=input$VolX
        voly=input$VolY
    }
    else if(input$DemoData==FALSE){
        volx=input$DemoX
        voly=input$DemoY
    }

    plot <- EnhancedVolcano(DataSet,
        lab=vol_lab,
        title=NULL,
        subtitle=NULL,
        selectLab=sel_lab,
        x=as.character(volx),
        y=as.character(voly),
        legendPosition=input$VLegendPos,,
        legendLabels=c('Not selected',paste(volx), paste(voly), paste(volx, ' & ', voly, sep='')),
        pCutoff=input$VpCutoff, 
        FCcutoff=input$VFCcutoff,
        pointSize=input$VpointSize,
        labSize=input$VLabSize,
        legendLabSize=input$VLegLabSize,
        legendIconSize=input$VLegIconSize,
        col=c(input$color1, input$color2, input$color3, input$color4),
        drawConnectors=input$Connectors,
        widthConnectors=input$Connectorwidth,
        colConnectors=input$concolor,
        boxedLabels=input$Boxed
    )

    return(plot)
})

observe({
    output$volcano_out <- renderPlot({
        volcano_plotter()
    }, height=input$VHeight, width=input$VWidth)
})

output$DownloadVS <- downloadHandler(
    filename=function(){
        paste(input$VolComp,input$DownVSFormat,sep='.')
    },
    content=function(file){   
        if(input$DownVSFormat=='jpeg'){
            jpeg(file, height=input$VHeight, width=input$VWidth)
            print(static_volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='png'){
            png(file, height=input$VHeight, width=input$VWidth)
            print(static_volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='tiff'){
            tiff(file, height=input$VHeight, width=input$VWidth, res=1000)
            print(static_volcano_plotter())
            dev.off()
        }
    }
)