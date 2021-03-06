source('pkg_check.R')

library('shiny')
library('shinyBS')
library('shinyAce')
library('yaml')

###############################################################################
# Setup
###############################################################################

# Loads in the help and information text.
# The shinyBS popovers can't handle line returns in the strings so a special
# handler is needed.
str.handler <- function(x) { gsub("[\r\n]", "", x) }
help.text <- yaml.load_file('help-text.yaml', handlers = list(str = str.handler))

###############################################################################
# Load Data Tab
###############################################################################

load.data.editor <- aceEditor('code_used_read',
                              value='# code to read in your data',
                              mode='r',
                              readOnly=TRUE,
                              height='100px')

load.data.side.panel <- sidebarPanel(
                          h4('Upload your CSV file by pressing "Load data" below'),
                          h5(paste('Your data should appear to the right. If ',
                                   'this data is correct, please move to tab ',
                                   '2: "Data analysis"', sep='')),
                          fileInput('data_file', 'Load data'),
                          h6('Code used to read in data:'),
                          load.data.editor,
                          checkboxInput('use_sample_data', 'Use sample data instead'),
                          conditionalPanel(
                            condition="input.use_sample_data == true",
                            radioButtons('sample_data_buttons',
                                         'Select your sample data',
                                         choices=c('Split plot design'='plots',
                                                   'Data of corn'='corn',
                                                   'Data of cotton'='cotton',
                                                   'Data of sweetpotato yield'='sweetpotato')
                                                  )),
                          bsTooltip('code_used_read',
                                    title='click for more information',
                                    placement = 'top',
                                    trigger='hover'),
                          bsPopover('code_used_read',
                                    title='Load data R code',
                                    content=help.text$load.data.explanation,
                                    placement='top',
                                    trigger='click')
                          )

load.data.tab <- tabPanel('1. Load data',
                          tags$style(type="text/css", "body {padding-top: 55px;}"),
                          sidebarLayout(
                            load.data.side.panel,
                            mainPanel(
                              h4('Loaded Data'),
                              dataTableOutput('data_table')
                              )
                            )
                          )

###############################################################################
# Data Analysis Tab
###############################################################################

# In this panel the user selects 1 of 9 experimental design options from a
# dropdown list. The choice is stored in input$exp.design. Data must be loaded
# first for the panel to function.
experimental.design.panel <-
  bsCollapsePanel(
    '1. Experimental Design',
    h5('Choose an experimental design that matches your data.'),
    uiOutput('select.design'),
    bsButton('exp_design_info_button',
             "Experimental Design Information"),
    bsModal('exp_design_info_content',
            trigger='exp_design_info_button',
            title='Information On Experimental Design Types',
            h5(help.text$exp.design.types)
           )
  )

# The user can adjust whether variables are continuous or factors.
# TODO : Maybe it should go below the dependent and independent variable
# selections so you only have to choose the variable type for the variables used
# in the analysis.
variable.type.panel <-
  bsCollapsePanel(
    '2. Variable types',
    h5('Indicate your variable types below'),
    h6(paste('We have made guesses at the variable types ',
             'in your data, but change the variable types ',
              'below if they are incorrect.', sep='')),
    uiOutput('var_types_select'),
    bsButton('variable_type_button',
             'Information on variable types'),
    bsModal('var_type_info',
            title='Variable type info',
            trigger='variable_type_button',
            h5(help.text$var.type.info))
  )

# In this panel, the user selects one of the columns from their data set to be
# the dependent variable. The choice is stored in input$dependent.variable. The
# experimental design must be chosen first.
dependent.panel <-
  bsCollapsePanel(
    "3. Dependent Variable",
    uiOutput('select.dependent'),
    bsButton('dependent_info_button',
             "Dependent Variable Information"),
    bsModal('dependent_info_content',
            trigger='dependent_info_button',
            title='Information on Dependent Variable Choice',
            h5(help.text$dependent.variable.info)
           )
  )

# In this panel the user selects the independent variables. Depending on which
# experimental design is chosen, different selection boxes appear.
independent.panel <-
  bsCollapsePanel(
    '4. Independent variables',
    uiOutput('select.independent'),
    bsButton('select_iv_info',
             'Independent variable info'),
    bsModal('iv_info_content',
            title='Information on independent variables',
            trigger='select_iv_info',
            h5(help.text$ind.var.explanation))
  )

# In this panel, the user can select a type of transformation to apply to the
# dependent variable.
transformation.panel <-
  bsCollapsePanel(
    '5. Transformations',
    selectInput('transformation',
                'Select a transformation for the dependent variable:',
                choices = c('None', 'Power', 'Logarithmic', 'Square Root'),
                selected = 'None')
  )

analysis.editor <- aceEditor('code_used_model', value='# code to run analysis',
                             mode='r', readOnly=TRUE, height='150px')

data.analysis.tab <-
  tabPanel(
    '2. Analysis',
    sidebarLayout(
      sidebarPanel(
        bsCollapse(
          multiple = FALSE,
          id = 'main_collapse_panel',
          experimental.design.panel,
          variable.type.panel,
          dependent.panel,
          independent.panel,
          transformation.panel
          ),
        actionButton('run_analysis', 'Run analysis')
      ),
      mainPanel(
        analysis.editor,
        bsTooltip('code_used_model',
                  'Click for more information',
                  placement = 'top',
                  trigger = 'hover'),
        bsPopover('code_used_model',
                  title = 'Analysis R code',
                  content = help.text$analysis.code.explanation,
                  placement = 'bottom',
                  trigger = 'click'),
        h2('Model Formula'),
        verbatimTextOutput('formula'),
        uiOutput('exponent'),
        uiOutput('fit.summary'),
        bsTooltip('fit.summary',
                  'Click for more information',
                  placement = 'top',
                  trigger = 'hover'),
        bsPopover('fit.summary',
                  title = 'Standard output',
                  help.text$fit.explanation,
                  placement = 'left',
                  trigger = 'click'),
        uiOutput('residuals.vs.fitted.plot'),
        uiOutput('kernel.density.plot'),
        uiOutput('best.fit.plot'),
        uiOutput('boxplot.plot'),
        uiOutput('shapiro.wilk.results'),
        uiOutput('levene.results'),
        uiOutput('tukey.results'),
        uiOutput('interaction.plot')
      )
    )
  )

###############################################################################
# Post-hoc Tests Tab
###############################################################################

posthoc.tab <-
  tabPanel('3. Post-hoc tests',
    sidebarLayout(
      sidebarPanel(h4('Post hoc analysis'),
                   actionButton('run_post_hoc_analysis',
                                'Run post hoc analysis')),
      mainPanel(h3('Post hoc tests and figures'),
                uiOutput('lsd.results'))
    )
  )

###############################################################################
# Report Tab
###############################################################################

report.tab <-
  tabPanel('4. Report',
           verticalLayout(
             textInput('file.name', "File name:", "analysis.html"),
             downloadButton('download_report')
           )
          )

###############################################################################
# About Tab
###############################################################################

about.tab <-
  tabPanel('About',
    verticalLayout(
      p(help.text$about),
      h1('Funding'),
      p(help.text$funding),
      img(src = "usaid-logo-600.png", width = "300px"),
      h1('Authors'),
      tags$ul(tags$li('Ian K. Kyle'), tags$li('Jason K. Moore'),
              tags$li('Maegen B. Simmonds')),
      h1('Disclaimer'),
      p(help.text$disclaimer),
      h1('License'),
      p(help.text$license, tags$a('http://github.com/ucd-ipo/aip-analysis'))
    )
  )

###############################################################################
# Main User Interface
###############################################################################

shinyUI(
  navbarPage(
    title = 'Agricultural Field Trial Statistics Package',
    windowTitle = 'Agricultural Field Trial Statistics Package',
    position = 'fixed-top',
    load.data.tab,
    data.analysis.tab,
    posthoc.tab,
    report.tab,
    about.tab
  )
)
