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
# colnames(df)

df1 <- df %>%
    filter(time_period == "3-month period" & rate_type == "Crude" & cause_of_death %in% c("All causes", "COVID-19")) %>%
    select(year_and_quarter, cause_of_death, overall_rate)

df1 <- df1 %>%
    mutate_at(c("overall_rate"), ~coalesce(.,0))

covid_death_rate <- df1 %>%
    filter(cause_of_death == "COVID-19") %>%
    select("overall_rate")
#
all_causes_rate <- df1 %>%
    filter(cause_of_death == "All causes") %>%
    select(overall_rate)

covid_ratio <- covid_death_rate / all_causes_rate * 100

df_ratio <- df1 %>%
    filter(cause_of_death == "All causes") %>%
    select(year_and_quarter)
df_ratio["covid_ratio"] = covid_ratio
ggplot(df_ratio, aes( x=year_and_quarter, y=covid_ratio)) +
    geom_bar(stat="identity", fill="yellow") +
    scale_y_continuous(breaks=seq(0,20,2))
    theme_bw()


# Example to draw smooth line with formular
p <- ggplot(cars, aes(speed, dist)) +
  geom_point()
# Add regression line
p + geom_smooth(method = lm)
p + geom_smooth(method = "lm", formula = y ~ poly(x, 3), se = FALSE)

# Save plot to file
p = ggplot(df1, aes(fill=cause_of_death, x=year_and_quarter, y=overall_rate)) +
    geom_bar(position="stack", stat="identity") +
    geom_col() +
    geom_smooth(aes(group=cause_of_death)) +
    scale_y_continuous(breaks=seq(0,1500,100)) +
    theme_bw()

save_plot("covid_plot.svg", fig = p, width=30, height=20)

# Draw plot directly showing it as new window
ggplot(df1, aes(fill=cause_of_death, x=year_and_quarter, y=rate_california)) +
    geom_bar(position="stack", stat="identity") +
    geom_col() +
    geom_smooth(aes(group=cause_of_death)) +
    scale_y_continuous(breaks=seq(0,1500,100))
    theme_bw()


# Show both Overall and CA
df1 <- df %>%
    filter(time_period == "3-month period" & rate_type == "Crude" & cause_of_death %in% c("All causes", "COVID-19")) %>%
    select(year_and_quarter, cause_of_death, overall_rate, rate_california) %>%
    mutate_at(c("overall_rate", "rate_california"), ~coalesce(.,0))

df2 = df1 %>% gather(Variable, rate_per_100k, -year_and_quarter, -cause_of_death)
ggplot(data = df2,
       aes(x=Variable, y = rate_per_100k, fill = cause_of_death)) +
    geom_bar(stat = "identity",
             position = "stack") +
    geom_col() +
    scale_y_continuous(breaks=seq(0,1500,100)) +
    facet_grid(~ year_and_quarter) +
    theme(axis.text.x=element_text(angle=45,hjust=1,size=8))



# To show age groups' trend
df3 <- df %>%
    filter(time_period == "3-month period" & rate_type == "Crude" & cause_of_death %in% c("All causes", "COVID-19")) %>%
    select(year_and_quarter, cause_of_death, rate_age_85_plus,rate_age_75_84,rate_age_65_74,rate_age_55_64,rate_age_45_54,rate_age_35_44) %>%
    mutate_at(c("rate_age_85_plus", "rate_age_75_84","rate_age_65_74","rate_age_55_64","rate_age_45_54","rate_age_35_44"), ~coalesce(.,0))

df4 = df3 %>% pivot_longer(names_to = "rate_type", values_to = "rate_of_10k",cols = -c(year_and_quarter, cause_of_death))
ggplot(data = df4,
       aes(x=rate_type, y = rate_of_10k, fill = cause_of_death)) +
    geom_bar(stat = "identity",
             position = "stack") +
    geom_col() +
    facet_grid(~ year_and_quarter) +
    theme(axis.text.x=element_text(angle=45,hjust=1,size=8))
