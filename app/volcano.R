# ─── Help Modal ───────────────────────────────────────────────────────────────

show_vol_help_ui <- function() {
    showModal(modalDialog(
        title     = tagList(icon("circle-question"), " Volcano Plot Tool Help"),
        size      = "l",
        easyClose = TRUE,
        footer    = modalButton("Close"),
        tabsetPanel(
            tabPanel("Overview",
                br(),
                h4("What is a Volcano Plot?"),
                p("A volcano plot visualizes the results of a differential expression (or any comparative) analysis. Each point represents a feature (gene, peak, protein, etc.). The x-axis shows the magnitude of change (log2 fold-change) and the y-axis shows statistical significance (-log10 p-value), creating a 'volcano' shape."),
                h4("Reading the Plot"),
                tags$ul(
                    tags$li(strong("Right side (positive x):"), " features upregulated in the comparison condition."),
                    tags$li(strong("Left side (negative x):"), " features downregulated."),
                    tags$li(strong("Higher y:"), " more statistically significant."),
                    tags$li(strong("Points in the upper corners:"), " large fold-change AND high significance — the most biologically interesting hits.")
                ),
                h4("Cutoff Lines"),
                p("The horizontal dashed line marks the p-value cutoff. The vertical dashed lines mark the fold-change cutoff. Points beyond both cutoffs are highlighted in color.")
            ),
            tabPanel("Input Data",
                br(),
                h4("Required Columns"),
                p("Your CSV/TSV file must contain at minimum:"),
                tags$ul(
                    tags$li(strong("A differential value column:"), " typically log2FoldChange, logFC, or similar."),
                    tags$li(strong("A significance column:"), " typically padj, FDR, p.value, or pvalue.")
                ),
                p("Any additional columns (gene symbols, descriptions, etc.) can be used for labels."),
                h4("Common Sources"),
                tags$ul(
                    tags$li("DESeq2: log2FoldChange + padj"),
                    tags$li("edgeR: logFC + FDR"),
                    tags$li("limma: logFC + adj.P.Val"),
                    tags$li("Proteomics / ATAC-seq: any fold-change + significance columns")
                )
            ),
            tabPanel("Controls",
                br(),
                h4("Point Options"),
                p("Control point size and the four colors used for: (1) not significant, (2) fold-change only, (3) p-value only, (4) both significant."),
                h4("Labels"),
                p("Toggle labels on/off. Choose which column provides the label text. Optionally restrict labels to a selected subset of genes. Boxed labels and connector lines improve readability for dense plots."),
                h4("Legend Options"),
                p("Reposition the legend and adjust label/icon sizes."),
                h4("Advanced Options"),
                tags$ul(
                    tags$li(strong("Y/X cutoff sliders:"), " move the significance and fold-change threshold lines."),
                    tags$li(strong("Axis Limits:"), " manually set the x and y axis ranges to zoom in or out."),
                    tags$li(strong("Gridlines:"), " toggle major and minor grid lines.")
                ),
                h4("Resize & Download"),
                p("Use the Resize Image toggle to set pixel dimensions. Download in JPEG, PNG, TIFF, PDF, SVG, or EPS.")
            )
        )
    ))
}

observeEvent(input$show_help_float, { show_vol_help_ui() })

# ─── Code Modal ───────────────────────────────────────────────────────────────

observeEvent(input$show_code_modal, {
    ds   <- isolate(tryCatch(InputReactive(), error=function(e) NULL))
    if (is.null(ds)) {
        code <- "# Load your data first, then click here to get the reproducible code."
    } else {
        volx <- isolate(if (input$DemoData) input$VolX else input$DemoX)
        voly <- isolate(if (input$DemoData) input$VolY else input$DemoY)
        lab_line <- if (input$ShowLabs)
            sprintf('\n    lab = as.character(data[["%s"]]),', input$VLabBy)
        else
            '\n    lab = "",  # labels off'
        sel_line <- if (input$ShowLabs && input$Select && length(input$VLabs) > 0)
            sprintf('\n    selectLab = c(%s),', paste0('"', input$VLabs, '"', collapse=", "))
        else ""
        axis_lines <- if (input$AxisLimits)
            sprintf('\n    xlim = c(%.2f, %.2f),\n    ylim = c(0, %.2f),', input$Vxmin, input$Vxmax, input$Vymax)
        else ""

        code <- paste0(
            "library(EnhancedVolcano)\n\n",
            "# data <- read.csv('your_file.csv', row.names = 1)\n\n",
            "EnhancedVolcano(data,",
            lab_line, sel_line,
            sprintf('\n    x = "%s",', volx),
            sprintf('\n    y = "%s",', voly),
            sprintf('\n    pCutoff = %s,', input$VpCutoff),
            sprintf('\n    FCcutoff = %s,', input$VFCcutoff),
            sprintf('\n    pointSize = %s,', input$VpointSize),
            if (input$ShowLabs) sprintf('\n    labSize = %s,', input$VLabSize) else "",
            sprintf('\n    legendPosition = "%s",', input$VLegendPos),
            sprintf('\n    legendLabSize = %s,', input$VLegLabSize),
            sprintf('\n    legendIconSize = %s,', input$VLegIconSize),
            sprintf('\n    col = c("%s", "%s", "%s", "%s"),', input$color1, input$color2, input$color3, input$color4),
            sprintf('\n    drawConnectors = %s,', tolower(as.character(input$Connectors))),
            if (input$Connectors) sprintf('\n    widthConnectors = %s,\n    colConnectors = "%s",', input$Connectorwidth, input$concolor) else "",
            sprintf('\n    boxedLabels = %s,', tolower(as.character(input$Boxed))),
            sprintf('\n    gridlines.major = %s,', tolower(as.character(input$majorgrid))),
            sprintf('\n    gridlines.minor = %s,', tolower(as.character(input$minorgrid))),
            axis_lines,
            "\n    title = NULL,\n    subtitle = NULL\n)\n"
        )
    }

    showModal(modalDialog(
        title     = tagList(icon("file-code"), " Reproducible R Code"),
        size      = "l",
        easyClose = TRUE,
        footer    = modalButton("Close"),
        p("Copy this code to reproduce your current volcano plot in an offline R session.", style="color:#555; margin-bottom:12px;"),
        tags$pre(
            style = paste(
                "background:#1e1e1e; color:#d4d4d4; border-radius:6px;",
                "padding:16px; font-size:12px; max-height:520px; overflow-y:auto;",
                "white-space:pre; font-family:'Courier New', monospace;"
            ),
            code
        )
    ))
})

# ─── Column selectors ─────────────────────────────────────────────────────────

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

    if(input$AxisLimits==FALSE){
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
            boxedLabels=input$Boxed,
            gridlines.major=input$majorgrid,
            gridlines.minor=input$minorgrid
        )
    }
    else if(input$AxisLimits==TRUE){
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
            boxedLabels=input$Boxed,
            gridlines.major=input$majorgrid,
            gridlines.minor=input$minorgrid,
            xlim=c(as.numeric(input$Vxmin), as.numeric(input$Vxmax)),
            ylim=c(0,as.numeric(input$Vymax))
        )
    }
    

    return(plot)
})

observe({
    output$volcano_out <- renderPlot({
        volcano_plotter()
    }, height=input$VHeight, width=input$VWidth)
})

output$DownloadVS <- downloadHandler(
    filename=function(){
        paste('volcano',input$DownVSFormat,sep='.')
    },
    content=function(file){   
        if(input$DownVSFormat=='jpeg'){
            jpeg(file, height=input$VHeight, width=input$VWidth)
            print(volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='png'){
            png(file, height=input$VHeight, width=input$VWidth)
            print(volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='tiff'){
            tiff(file, height=input$VHeight, width=input$VWidth, res=1000)
            print(volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='pdf'){
            pdf(file, height=input$VHeight/100, width=input$VWidth/100)
            print(volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='svg'){
            svg(file, height=input$VHeight/100, width=input$VWidth/100)
            print(volcano_plotter())
            dev.off()
        }
        if(input$DownVSFormat=='eps'){
            setEPS()
            postscript(file, height=input$VHeight/100, width=input$VWidth/100)
            print(volcano_plotter())
            dev.off()
        }
    }
)