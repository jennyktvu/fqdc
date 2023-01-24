library("dplyr")
library("ggplot2")
library("janitor")
library("tidyr")
library("readr")
library("sjPlot")
df <- readr::read_csv(file.path(getwd(), "NCHS_-_VSRR_Quarterly_provisional_estimates_for_selected_indicators_of_mortality.csv"), col_names = TRUE)
df <- clean_names(df)
# To fix the colname format from origin csv file
df <- df %>% rename("rate_age_65_74" = "rate_65_74")
# df[,c("Year and Quarter", "Time Period", "Overall Rate")]

# filter(df["Cause of Death" == "All causes"]  %>%
glimpse(df)
df1 <- df %>%
    filter(time_period == "3-month period" & rate_type == "Crude" & cause_of_death %in% c("COVID-19")) %>%
    select(year_and_quarter, rate_age_1_4, rate_age_5_14,rate_age_15_24, rate_age_25_34,rate_age_35_44, rate_age_45_54,rate_age_55_64,rate_age_65_74,rate_age_75_84,rate_age_85_plus)


df2 = df1 %>% pivot_longer(names_to = "rate_type", values_to = "rate_of_10k",cols = -c(year_and_quarter))

df2 <- df2 %>%
    mutate_at(c("rate_of_10k"), ~coalesce(.,0))

plotdata <- df2 %>%
    group_by(rate_type) %>%
    summarize(n = n(),
            mean = mean(rate_of_10k),
            sd = sd(rate_of_10k),
            ci = qt(0.975, df = n - 1) * sd / sqrt(n))

# Enfore the age based order
# plotdata <- plotdata[c(1,6,2:5,7:10),]


# factor(rate_type, level = c('rate_age_1_4','rate_age_5_14','rate_age_15_24','rate_age_25_34','rate_age_35_44','rate_age_45_54','rate_age_55_64','rate_age_65_74','rate_age_75_84','rate_age_85_plus')
p = ggplot(plotdata,
       aes(x = factor(rate_type, level = c('rate_age_1_4','rate_age_5_14','rate_age_15_24','rate_age_25_34','rate_age_35_44','rate_age_45_54','rate_age_55_64','rate_age_65_74','rate_age_75_84','rate_age_85_plus'))
         , y = mean, group = 1)) +
    geom_line(linetype="dashed", color="darkgrey") +
    geom_errorbar(aes(ymin = mean - ci,
                      ymax = mean + ci),
                  width = .2) +
    geom_point(size = 3, color="red") +
    scale_y_continuous(breaks=seq(0,1800,100)) +
    theme_bw() +
    labs(x="rate_type",
         y="rate_of_10k",
         title="Mean Plot with 95% Confidence Interval")
save_plot("covid_plot_age_impact1.svg", fig = p, width=30, height=20)

# plotdata2 <- plotdata %>%
#         filter(rate_type%in% c('rate_age_1_4','rate_age_5_14','rate_age_15_24','rate_age_25_34','rate_age_35_44','rate_age_45_54'))
#
# ggplot(plotdata2,
#        aes(x = factor(rate_type, level = c('rate_age_1_4','rate_age_5_14','rate_age_15_24','rate_age_25_34','rate_age_35_44','rate_age_45_54')) , y = mean, group = 1)) +
#   geom_line(linetype="dashed", color="darkgrey") +
#   geom_errorbar(aes(ymin = mean - ci,
#                     ymax = mean + ci),
#                 width = .2) +
#   geom_point(size = 3, color="red") +
#   theme_bw() +
#   labs(x="rate_type",
#        y="rate_of_10k",
#        title="Mean Plot with 95% Confidence Interval")
                                        #

df2$rate_type = as.factor(df2$rate_type)
fit <- aov(rate_of_10k ~ rate_type, data=df2)
summary(fit)
outlierTest(fit)
bartlett.test(rate_of_10k ~ rate_type, data=df2)

library("car")
qqPlot(fit, simulate=TRUE, main="Q-Q test")


pairwise <- TukeyHSD(fit)
pairwise


plotdata <- as.data.frame(pairwise[[1]])
plotdata$conditions <- row.names(plotdata)

library(ggplot2)
p = ggplot(data=plotdata, aes(x=conditions, y=diff)) +
  geom_errorbar(aes(ymin=lwr, ymax=upr, width=.2)) +
  geom_hline(yintercept=0, color="red", linetype="dashed") +
  geom_point(size=3, color="red") +
  theme_bw() +
  labs(y="Difference in mean levels", x="",
       title="95% family-wise confidence level") +
    coord_flip()
p
save_plot("covid_plot_age_impact2.svg", fig = p, width=30, height=20)


set.seed(69)
x <- rnorm(100)
qqPlot(x)

library(multcomp)
tuk <- glht(fit, linfct = mcp(rate_type="Tukey"))
summary(tuk)
labels1 <- cld(tuk, level=.05)$mcletters$Letters
labels2 <- paste(names(labels1), "\n", labels1)
ggplot(data=fit$model, aes(x=rate_type, y=rate_of_10k)) +
  scale_x_discrete(breaks=names(labels1), labels=labels2) +
  geom_boxplot(fill="lightgrey") +
  theme_bw() +
  labs(x="rate_type",
       title="Distribution of rate Scores by rate_type",
       subtitle="Groups without overlapping letters differ signifcantly (p < .05)")
