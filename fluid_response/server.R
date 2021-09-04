

library(shiny)
library(tidyverse)
library(tidybayes)
library(ggtext)
library(brms)


model1 <- readRDS("model1.Rds")

# Define server logic required to draw the posterior predicted Y4
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

      #generate posterior predictions based on Y0 and Y1
       prediction <- tibble(Y0=input$Y0,Y1=input$Y1) %>%
            add_predicted_draws(model1)

       #calculate posterior probability of Y4 superior to target
       post_pred_prob <- prediction %>%
           summarise(prob=mean(.prediction>input$Y4min)) %>%
           pull(prob)

       #data for points and lines
       plot_data <- tibble(time=ordered(c("Y0","Y1","Y4 (Predicted)")),y=c(input$Y0,input$Y1,mean(prediction$.prediction)),group="group")

       spaghetti_data <- tibble(Y0=input$Y0,Y1=input$Y1,"Y4 (Predicted)"=sample(prediction$.prediction,200)) %>%
         pivot_longer(everything(),names_to = "time",values_to = "y") %>%
         mutate(across(time,as.ordered)) %>%
         mutate(group=as.factor(rep(1:200,each=3)))

       plot_data %>%
         ggplot(aes(x = time, y = y,group=group)) +
         stat_halfeye(aes(y = .prediction, x = "Y4 (Predicted)", fill = after_stat(ifelse(y > input$Y4min, "over", "under"))), data = prediction,inherit.aes=FALSE) +
         geom_point(size=3,data = . %>% filter(time!="Y4 (Predicted)"))+
         geom_line(data = . %>% filter(time!="Y4 (Predicted)"))+
         geom_line(data = spaghetti_data %>% filter(time!="Y0"),alpha=1/20)+
         geom_hline(yintercept = input$Y4min,linetype="dotted")+
         scale_fill_manual(values = c("over" = "#87ceeb", "under" = "#FFC0CB")) +
         scale_y_continuous(name = "Y (SV)")+
         scale_x_discrete(name="")+
         theme_tidybayes() +
         labs(title = paste0(
           "Posterior prediction for Y4 contitional on baseline Y0 and post-minibolus Y1 <br>",
           "Posterior probability of Y4 <span style='color:#87ceeb;'>superior</span> to target (dotted line): ", scales::percent(post_pred_prob, accuracy = .1)
         ),caption = "@load_dependent") +
         theme(
           legend.position = "none", axis.line.y = NULL,
           plot.title = element_markdown(lineheight = 1.1),
           legend.text = element_markdown(size = 11)
         )
    })



})
