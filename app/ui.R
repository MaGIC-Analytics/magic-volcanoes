library(shiny)
require(shinyjs)
library(shinythemes)
require(shinycssloaders)
library(shinyWidgets)

library(DT)
library(tidyverse)
library(data.table)
library(colourpicker)
library(RColorBrewer)
library(EnhancedVolcano)

tagList(
    tags$head(
        #includeHTML(("www/GA.html")), If including google analytics
        tags$style(type = 'text/css','.navbar-brand{display:none;}')
    ),
    fluidPage(theme = shinytheme('yeti'),
            windowTitle = "MaGIC Volcano Plot Tool",
            titlePanel(
                fluidRow(
                column(2, tags$a(href='http://www.bioinformagic.io/', tags$img(height =75 , src = "MaGIC_Icon_0f344c.svg")), align = 'center'), 
                column(10, fluidRow(
                    column(10, h1(strong('MaGIC Volcano Plot Tool'), align = 'center')),
                    ))
                ),
                windowTitle = "MaGIC Volcano Plot Tool" ),
                tags$style(type='text/css', '.navbar{font-size:20px;}'),
                tags$style(type='text/css', '.nav-tabs{padding-bottom:20px;}'),
                tags$head(tags$style(".modal-dialog{ width:1300px}")),

        navbarPage(title ="", id='NAVTABS',

        ## Intro Page
##########################################################################################################################################################
            tabPanel('Introduction',
                fluidRow(
                    column(2,
                    ),
                    column(8,
                        column(12, align = "center", 
                            style="margin-bottom:25px;",
                            h3(markdown("Welcome to the Volcano Plot Tool by 
                            [the Molecular and Genomics Informatics Core](http://www.bioinformagic.io)."))),
                        hr(),
                    ),
                    column(2,
                    )
                ),
                fluidRow(
                    column(2,
                    ),
                    column(8, align='center',
                        img(src="fortnite-volcano-eruption-fortnite-volcano.gif")
                    ),
                    column(2,
                    )
                ),
                fluidRow(
                    column(3,
                    ),
                    column(6,
                        column(12, align = "left", 
                            style="margin-bottom:25px;",
                            h4("About Volcano Plots"),
                            markdown("Volcano plots are a staple in differential expression analyses. In general, it is meant to visualize the differences seen in your direct comparisons.
                            For example, if you are doing a treatment vs control experiment, you will be able to visualize the spread of each data point between the comparisons.
                            Volcano plots are named after Plinian eruptions. As you visualize your data, you will see how the dispersion of your differential expression vs signficance values takes the shape of a volcanic eruption.

                            "),
                            hr(),
                            h4("Data Sources"),
                            markdown("The data for volcano plots can come from any type of comparative data. A few examples are RNA-seq differential gene expression comparisons, 
                            ATAC-seq differential peak comparisons, proteomics differential protein comparisons, single cells pseudo-bulk differential gene expression comparisons etc. 

                            "),
                            hr(),
                            h4("Minimum requirements"),
                            markdown("To utilize this tool, at minimum you must have a tsv/csv table containing a column of identifiers (ex Gene IDs), a differential value (ex log2FoldChange), 
                            and significance values (ex padj). You can then upload your file to the application, select the respective columns, and plot your personal volcano plot!

                            ")),
                        hr(),
                    ),
                    column(3,
                    )
                ),
            ),


        ## Input Page
##########################################################################################################################################################
            tabPanel('Input Data',
                fluidRow(
                    column(3,
                        wellPanel(
                            h2('Input Data', align='center'),
                            hr(),
                            materialSwitch("DemoData", label="Use your own data", value=TRUE, right=TRUE, status='info'),
                            conditionalPanel("input.DemoData",
                                fileInput('de_file','Select your differential expression file',
                                accept=c(
                                    'text/csv',
                                    'text/comma-separated-values, text/plain',
                                    '.csv',
                                    'text/tsv',
                                    'text/tab-separated-values, text/plain',
                                    '.tsv'), 
                                multiple=FALSE
                                ),
                                uiOutput('data_selector')
                            ),
                            conditionalPanel("input.DemoData==false",
                                uiOutput('data_demo')
                            )
                        )
                    ),
                    column(9,
                        tabsetPanel(id='InputTables',
                            tabPanel(title='Input Table', hr(),
                                withSpinner(type=6, color='#5bc0de',
                                        dataTableOutput('input_table')
                                    )
                            )
                        )
                    )
                )
            ),
        ## Volcanoes
##########################################################################################################################################################
            tabPanel('Volcano Plots',
                fluidRow(
                    column(3,
                        wellPanel(
                            h2('Plot Options', align='center'),
                            sliderInput("VpointSize","Point size: ", min=1, max=30, step=1, value=5),
                            column(3, colourInput("color1", "Color 1", "#5b5b5b")),
                            column(3, colourInput("color2", "Color 2", "#008000")),
                            column(3, colourInput("color3", "Color 3", "#0000FF")),
                            column(3, colourInput("color4", "Color 4", "#ff0000")),
                            materialSwitch("ShowLabs", label="Show point labels", value=FALSE, right=TRUE, status='info'),
                            conditionalPanel("input.ShowLabs",
                                selectInput("VLabBy", label="Label data by: ", choices=NULL),
                                sliderInput("VLabSize","Label size: ", min=1, max=30, step=1, value=4),
                                materialSwitch('Select',label='Label only selected values',value=FALSE, right=TRUE, status='info'),
                                conditionalPanel("input.Select",
                                    selectizeInput("VLabs","Please list genes of choice", choices = NULL, multiple=TRUE, options=list(placeholder='Search'))
                                ),
                                materialSwitch("Boxed", label="Boxed Labels", value=FALSE, right=TRUE, status='info'),
                                materialSwitch("Connectors", label="Draw Connectors", value=FALSE, right=TRUE, status='info'),
                                conditionalPanel("input.Connectors",
                                    sliderInput('Connectorwidth','Connector line width', min=0.1, max=10, step=0.1, value=1),
                                    colourInput("concolor", "Connector color", "black")
                                )
                            ),
                            materialSwitch("LegOpts", label="Legend Options", value=FALSE, right=TRUE, status='info'),
                            conditionalPanel("input.LegOpts",
                                radioButtons("VLegendPos", label="Legend Position", inline=TRUE,
                                    choices=c("Top"='top',"Bottom"='bottom','Right'='right','left'='left'), selected="bottom"),
                                sliderInput("VLegLabSize","Legend Label size: ", min=1, max=30, step=1, value=10),
                                sliderInput("VLegIconSize","Legend Icon size: ", min=1, max=30, step=1, value=5)
                            ),
                            materialSwitch("AdvancedOptions", label="Advanced Options", value=FALSE, right=TRUE, status='info'),
                            conditionalPanel("input.AdvancedOptions",
                                sliderInput("VpCutoff", "Y axis cutoff lines", min=0.01, max=1, step=0.01, value=0.05),
                                sliderInput("VFCcutoff", "X axis cutoff lines", min=0, max=10, step=0.25, value=1)                                
                            ),
                            materialSwitch("Resize", label="Resize Image", value=FALSE, right=TRUE, status='info'),
                            conditionalPanel("input.Resize",
                                sliderInput('VHeight', label='Plot Heights: ', min=50, max=2000, step=10, value=800),
                                sliderInput('VWidth', label='Plot Widths: ',  min=50, max=2000, step=10, value=800)
                            )
                        )
                    ),
                    column(9,
                        tabsetPanel(id='Plot',
                            tabPanel(title='Volcano Plot', hr(),
                                withSpinner(type=6, color='#5bc0de',  
                                    plotOutput("volcano_out", height='100%')
                                ),
                                fluidRow(align='center',style="margin-top:25px;",
                                    column(12, selectInput("DownVSFormat", label='Choose download format', choices=c('jpeg','png','tiff'))),
                                    column(12, downloadButton('DownloadVS', 'Download the Volcano Plot'),style="margin-bottom:50px;")
                                )
                            )
                        )
                    )
                )
            ),
            
            
        ## Footer
##########################################################################################################################################################
            tags$footer(
                wellPanel(
                    fluidRow(
                        column(4, align='center',
                        tags$a(href="https://github.com/MaGIC-Analytics/magic-volcanoes", icon("github", "fa-3x")),
                        tags$h4('GitHub to submit issues/requests')
                        ),
                        column(4, align='center',
                        tags$a(href="http://www.bioinformagic.io/", icon("magic", "fa-3x")),
                        tags$h4('Bioinfor-MaGIC Home Page')
                        ),
                        column(4, align='center',
                        tags$a(href="https://github.com/MaGIC-Analytics", icon("address-card", "fa-3x")),
                        tags$h4("Developer's Page")
                        )
                    ),
                    fluidRow(
                        column(12, align='center',
                            HTML('<a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ">
                            <p>&copy; 
                                <script language="javascript" type="text/javascript">
                                var today = new Date()
                                var year = today.getFullYear()
                                document.write(year)
                                </script>
                            </p>
                            </a>
                            ')
                        )
                    ) 
                )
            )
        )#Ends navbarPage,
    )#Ends fluidpage
)#Ends tagList