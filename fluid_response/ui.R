#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(tidybayes)
library(ggtext)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Posterior prodections from bayesian model for "),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("Y0",
                        "Y0: Basline CO:",
                        min = 1.92,
                        max = 8.08,
                        value = 3.0,
                        step=0.01),
            sliderInput("Y1",
                        "Y1: Post mini-bolus CO:",
                        min = 1.18,
                        max = 8.36,
                        value = 3.2,
                        step=0.01),
            sliderInput("Y4min",
                        "Y4min: Target minimum CO:",
                        min = 1.18,
                        max = 8.36,
                        value = 3.4,
                        step=0.01)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
))
