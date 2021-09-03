library(tidyverse)
library(brms)
library(tidybayes)
library(here)

n <- 1000
# true values
Y0 <- rnorm(n, 5, 1)

a <- rnorm(n, 0, 1) # change
Y1 <- Y0 + a/2
Y4 <- Y1 + a

# add independent random noise
Y0 <- Y0 + rnorm(n, 0, 0.2)
Y1 <- Y1 + rnorm(n, 0, 0.2)
Y4 <- Y4 + rnorm(n, 0, 0.2)
df <- tibble(Y0,Y1,Y4)

# fit model (with flat priors)
model1 <- brm(Y4 ~ 0 + Y0 + Y1,
          data = df,
          file = here("fluid_response","data","model1.Rds"),
          file_refit= "on_change"
          )

# values to predict from
Y0_new <- 3.0
Y1_new <- 3.4
Y4_target <- 3.6 #minimum

#generate posterior predictions based on Y0 and Y1
prediction <- tibble(Y0=Y0_new,Y1_new) %>%
  add_predicted_draws(bm)

#calculate posterior probability of Y4 superior to target
post_pred_prob <- prediction %>%
  summarise(prob=mean(.prediction>Y4_target)) %>%
  pull(prob)

#data for points and lines
plot_data = tibble(time=ordered(c("Y0","Y1","Y4")),y=c(Y0_new,Y1_new,mean(prediction$.prediction)),group="group")

# plot "measured" values and posterior predicted Y4
plot_data %>%
  ggplot(aes(x = time, y = y,group="group")) +
  stat_halfeye(aes(y = .prediction, x = "(Predicted) Y4", fill = after_stat(ifelse(y > Y4_target, "over", "under"))), data = prediction) +
  geom_point(size=3)+
  geom_path()+
  geom_hline(yintercept = Y4_target,linetype="dotted")+
  scale_fill_manual(values = c("over" = "#87ceeb", "under" = "#FFC0CB")) +
  scale_y_continuous(name = "Y (CO)")+
  scale_x_discrete(name="")+
  theme_tidybayes() +
  labs(title = paste0(
    "Posterior prediction for Y4 contitional on baseline Y0 and post-minibolus Y1 <br>",
    "Posterior probability of Y4 <span style='color:#87ceeb;'>superior</span> to target (dotted line): ", scales::percent(post_pred_prob, accuracy = .1)
  )) +
  theme(
    legend.position = "none", axis.line.y = NULL,
    plot.title = element_markdown(lineheight = 1.1),
    legend.text = element_markdown(size = 11)
  )
