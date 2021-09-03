
library(shiny)
library(tidyverse)
library(tidybayes)
library(ggtext)
library(brms)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Conditional posterior predictions from bayesian model for SV increase above target"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("Y0",
                        "Y0: Baseline SV:",
                        min = 1.92,
                        max = 8.08,
                        value = 3.0,
                        step=0.01),
            sliderInput("Y1",
                        "Y1: Post mini-bolus SV:",
                        min = 1.18,
                        max = 8.36,
                        value = 3.2,
                        step=0.01),
            sliderInput("Y4min",
                        "Y4min: Target minimum SV:",
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
