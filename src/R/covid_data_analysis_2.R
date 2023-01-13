library("dplyr")
library("ggplot2")
library("janitor")
library("tidyr")
library("readr")
library("sjPlot")
df <- readr::read_csv(file.path(getwd(), "Provisional_COVID-19_Death_Counts_by_Week_Ending_Date_and_State.csv"), col_names = TRUE)
df <- clean_names(df)
tmp_start_date <- strptime(df$start_date, "%m/%d/%Y")
df$start_date <- format(tmp_start_date, "%Y-%m-%d")

df1 <- df %>%
    filter(state == "United States" & group == "By Week") %>%
    select(start_date, covid_19_deaths)

p = ggplot(df1, aes( x=start_date, y=covid_19_deaths, group=1)) +
    geom_line(color="blue") +
    theme(axis.text.x=element_text(angle=45,hjust=1,size=5))
save_plot("covid_plot_weekly_wave.svg", fig = p, width=60, height=20)

library("pracma")
peaks = findpeaks(df1$covid_19_deaths, npeaks=5,  sortstr=TRUE)


is_peak <- vector( "logical" , length(df1$covid_19_deaths ))
df1$is_peak = is_peak

for (x in peaks[,2]) {
  df1$is_peak[x] = TRUE
}


df2 = df1 %>% filter(is_peak == TRUE)
df2[order(-df2$covid_19_deaths),]



p = ggplot(df1, aes(x=start_date, y=covid_19_deaths, group=1)) +
    geom_line(color="blue") +
    geom_point(data = . %>% filter(is_peak == TRUE), stat="identity", size = 4, color = "red") +
    scale_y_continuous(breaks=seq(0,30000,4000)) +
    theme(axis.text.x=element_text(angle=45,hjust=1,size=5))

save_plot("covid_plot_weekly_peak.svg", fig = p, width=60, height=20)


sum(df1$covid_19_deaths)
summary(df1$covid_19_deaths)

df3 <- df %>%
    filter(state == "United States" & group == "By Week") %>%
    select(start_date, total_deaths)
sum(df3$total_deaths)
summary(df3$total_deaths)
