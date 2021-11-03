## Introduction 

This post focuses on how to implement traditional RFM technique on R. RFM stands for recency, frequency and monetary value. This simple customer behavior segmentation method allows you to create specify 'customer zone' to target and smartly engage with customers to win their trust. It is known to be a handy method to find your superior customer all the way down to alarming churning customer. Like with everything else, some concerns do withhold in terms of reliability, however there is no doubt RFM is one of the go-to first step before micro-segmentating and rigorously understand their future value. 



## Business Insight: 

Customers may have subscriptions to receive the product or service.  Subscriptions and engagement campaigns are important marketing role as a business to retain and for customer acquisition. Higher the return in any type of investment bigger the risk follows to compensate. 

$$\ Expected Return = (E(Sales) - Cost of good sold) / 1 - E(Risk) $$ 
  
  Depending on your proficiency and background these key components can really branch out adding complexity. How would as data scientist and analyst could interpret with equation and leverage this Expected return. To me, the first step yet the most critical part of action is to keep uniformly distributed individual segmentation. Main ideology is robust scoring which comprises following concepts and more: 
  
  + Risk Distribution (Risk Hedging)
+ Systematic Customer Management (Operational Benefit)
+ Divide and Conquer (New Opportunity)

RFM metrics  


Companies fear missing good business opportunity whether that is launching new products, up-sell, opening new business location or building new partner. 
Hence identifying target customer with high probability to future spending & 80/20 rule, Pareto principle is essential measure for business sales revenue growth. 

External 

### Framework/ Analytic Design: 

##### RFM Score Calculation 
+ Fixed Range 

+ Power of quantiles 

[1] Identify Seasonality or events. Time Series Analysis to decompose trend/seasonal/irregular components from yearly/monthly time frame to evaluate the business cycle. 

[2] Top customer analysis 

[3] Differentiate customers with different repurchasing pattern {interpurchase times or latencies}, but will generally repurchase somewhere around the mean interpurchase time. If customer goes beyond their mean interpurchase time, the probability of them no longer being a customer increase. 


##### Vision: 
# [1] In prior to customer segmentation in any kinds it is essential to understand the main business objectives and customer value. In here, I would like to focus identifying most valuable customers through RFM scoring and also customer's sales attribute activity {high or low latency purchasing behaviour} within these cohorts. 

# [2] Due to high cost for marketing Campaigns, it is important to understand Profit-Loss profile. I will assume % gain on sale ~ a profit gain in % and seek which month or corresponding time frame gives best performance marketing output with respect to the seasonality components. 

##### Principle: 
# With regardless to contract/non-contractual term, churn prediction is hard to predict with high accuracy and robustness of its model. The likelihood of churn varies from individual to individual, even under the same circumstances {service experience given at point in time}.

# FRM feature engineering can often be misleading especially for predicting their future spending. However it sets a good initial benchmark for understanding customer purchasing behaviour. 

##### Source of Insights: 
# [1] Business Science 101 Course 

***
### 1.0 Load Libraries -----

library(readr)
library(fs)
library(tidyverse)
library(dplyr)
library(lubridate)
library(skimr)
library(scales)
library(psych)
library(gmodels)
library(tidyquant)
library(forecast)
library(timetk)
library(rsample) 
library(ggplot2)
library(plotly)
library(gganimate)
library(wesanderson)
library(GGally)


### 2.0 Environment Setting -----

set.seed(42)
options(scipen = 99, digits = 3)
trans_df_raw <- read_csv("~/Dropbox/business_insight/df_trans_raw.csv", col_types = cols())
trans_df <- trans_df_raw 
trans_df_raw




resp_df_raw <- read_csv("~/Dropbox/business_insight/df_resp_raw.csv")
resp_df_raw$X1 <- NULL
resp_df <- resp_df_raw
resp_df



#### 3.0 Data Preparation -----
######* Someday repeat purchase ----
# [1] 13% of customer has made same-day repeated purchase 

# [2] I feel it is sufficient number to flag as it could counter as useful variable for customer segmentation in later analysis 

trans_pre_df <- trans_df %>% 
  dplyr::mutate(trans_date = lubridate::dmy(trans_date))
skimr::skim(trans_df)
someday_dup_customer <- trans_pre_df %>% 
  janitor::get_dupes(c(customer_id, trans_date)) %>% 
  group_by(customer_id, trans_date) %>% 
  summarise(tran_amount = sum(tran_amount),
            dupe_count = mean(dupe_count)) %>%  ungroup()
someday_pur_customer <- someday_dup_customer %>% 
  set_names("customer_id", "trans_date", "sameday_pur_flag", "tran_amount") %>%
  mutate(sameday_pur_flag = ifelse(!sameday_pur_flag == "", 1))
# Abstract data without the sameday purchase + add flag 
without_sameday_pur <- trans_pre_df %>% 
  filter(!customer_id %in% someday_pur_customer$customer_id) 
without_sameday_pur$sameday_pur_flag <- 0
# Abstract data with the sameday purchase + add flag
sameday_pur <- trans_pre_df %>% 
  filter(customer_id %in% someday_pur_customer$customer_id) 
sameday_pur$sameday_pur_flag <- 1
# Row bind above data frames 
cust_prep_flag <- rbind(sameday_pur, without_sameday_pur) %>% arrange(customer_id)



###### Quick overview on correlation matrix for customer purchasing amount and number of purchases with repect to daily transcational date and customer id ----

[1] The historical data shows there are hardly any correlation between date and customer behaviour, likely to be a random walk model 
[2] There is a noticeable correlation between customer id and their purchasing behaviour. I anticipate could be due to number of reasons, perhaps, the primary key was organised by geographical manner, time, or other possible useful information held behind. 

daily_pur <- cust_prep_flag %>% 
  group_by(trans_date) %>% 
  summarise(no_pur = n(),
            amt = sum(tran_amount)) 
psych::pairs.panels(daily_pur)
cust_pur <- cust_prep_flag %>% 
  group_by(customer_id) %>% 
  summarise(no_pur = n(),
            amt = sum(tran_amount)) 
psych::pairs.panels(cust_pur)




cust_time_corr <- cust_prep_flag %>% 
  group_by(customer_id) %>% 
  summarise(earliest_pur = min(trans_date),
            latest_pur = max(trans_date),
            no_pur = n(),
            amt = sum(tran_amount)) 
psych::pairs.panels(cust_time_corr)


#### 4.0 Time Series ----

##### *Daily Transcation Overview ----
[1] Hard to notice any trend or seasonality by daily transcational data
[2] I am going to see if the density curve of transcational data satisfy normality for the purpose of predicting whether the sales against the time follows the random-walk model

{css, echo=FALSE}
p.caption {
  font-size: 2em;
  font-style: italic;
  color: grey;
  margin-right: 10%;
  margin-left: 10%;  
  text-align: justify;
}


{r, fig.align="center", fig.width=6, fig.height=6, fig.cap="Figure 1-1 : Daily sales time plot and its volatility density curve outlook."}
# Visulaisation 
p1_daily_pur <- daily_pur %>% 
  ggplot() +
  geom_line(aes(x = trans_date, y = amt), colour = "darkblue") + 
  labs(x = 'Time', y = 'Sales', title = '') +
  geom_hline(yintercept = 5799)
p2_daily_pur <- daily_pur %>%
  ggplot(aes(x = amt)) +
  geom_density(fill = "lightblue", alpha = 0.4) +
  labs(x = "") +
  coord_flip() +
  geom_vline(xintercept = mean(daily_pur$amt))
gridExtra::grid.arrange(p1_daily_pur, p2_daily_pur, ncol = 2)



{r, fig.align="center", fig.width=6, fig.height=6, fig.cap="Figure 1-2 : qq-plot of daily sales for normality test for its density curve."}
# Normality Test 
car::qqPlot(daily_pur$amt)
stats::shapiro.test(daily_pur$amt)
stats::shapiro.test(sqrt(daily_pur$amt))


***Findings ----
[1] The daily sales amount is non-normaliy distributed. As it is time/date grouped data, we anticipate not following the i.i.d rules. This indicates possible trend or volatility in customer purchasing activity.
[2] The volatile daily transcation data can bury such trend or activity variance, hence, I am going to decompose TSl components of the monthly customer transcation data to identify if there are any sign of trend and seasonality. Understnading the business cycle bu seasonality can be essential part of train and test data partitioning. 
[3] To me, this density curve shows a natural presence of segmentation in customer spending amount behavior {the noticable two bumps}. Which seems interesting. Having this in mind, I will perform classic RFM scoring and time series analysis of its segmented groups to see if any noticeable pattern appears by the data.{later on} 

# *Proof of the above data is daily transcation date ----
start_date <- min(g$trans_date)
end_date <- max(daily_pur$trans_date)
nrow(daily_pur) # 1401
end_date - start_date # Time difference of 1400 days
generate_ts_data <- function(ts_prep, period) {
  
  step_1 <- ts_prep %>% 
    group_by(trans_date) %>% 
    summarise(N_pur = n()) %>% 
    tq_transmute(select = N_pur, 
                 mutate_fun = period,
                 FUN = sum) 
  
  step_2 <- ts_prep %>% 
    tq_transmute(select = tran_amount, 
                 mutate_fun = period,
                 FUN = sum) 
  
  step_2 %>% 
    left_join(step_1, by = "trans_date")
}
adj_start_date <- "2011-06-01"
adj_end_date <-"2015-02-28"
# Reason: removing incomplete time span for monthly data as it could hide away the trend or the seasonlity trend components {important}. Same follows with weekly data, incomplete week is removed here 
daily_pur_ts <- generate_ts_data(cust_prep_flag, apply.daily)
weekly_pur_ts <- generate_ts_data(cust_prep_flag %>% filter(trans_date < (end_date-7)), apply.weekly)
monthly_pur_ts <- generate_ts_data(cust_prep_flag %>% filter(trans_date > adj_start_date & trans_date < adj_end_date), apply.monthly)
create
postcards::create_postcard("about.Rmd", template = "trestles")
postcards::create_postcard(template = "trestles")


plot_ts_data <- function(ts_data) {
  
  abline <- mean(ts_data$tran_amount)
  
  g <- ts_data %>% 
    ggplot() +
    geom_line(aes(x = trans_date, y = tran_amount), colour = "darkblue") + 
    labs(x = 'Time', y = 'Sales', title = '') +
    geom_hline(yintercept = abline, color = "darkred", size = 1)
  
  ggplotly(g)
}
p_m <- plot_ts_data(monthly_pur_ts)
p_w <- plot_ts_data(weekly_pur_ts)
p_d <- plot_ts_data(daily_pur_ts)

######* Findings 
Again, hard to tell, but the monthly data do tells me there is a descending trend. If I connect the dots of the highest point and same for lowest points, it is clear that the average sales should be descending. 
Down-ward Linear Trend with Additive Seasonality  
{r, fig.align="center", fig.width=6, fig.height=6, fig.cap="Figure 2-1 : Descending Trend Components by Monthly Raw Time Series."}
monthly_ts <- ts(monthly_pur_ts$tran_amount, start = c(2011, 6), f = 12)
weekly_ts <- ts(weekly_pur_ts$tran_amount, start = c(2011, 5), f = 365.25/7)
daily_ts <- ts(daily_pur_ts$tran_amount, start = c(2011, 5), f = 365)
set.seed(42)
auto_arima_monthly_fit <- auto.arima(monthly_ts) 
checkresiduals(auto_arima_monthly_fit)
t <- 1:length(monthly_ts)
fit_monthly_lm <- lm(monthly_ts ~ t)
fit_monthly_lm$coefficients
anova(fit_monthly_lm)
trend <- fitted(fit_monthly_lm)
ts.plot(monthly_ts, trend, col=1:2, lty = 1:2, ylab = "Monthly Sales", xlab = "time")
        legend("topright", lty=1:2, col=1:2, c("Raw Monthly Time series", "Trend component"))

######* Seasonal Components 
{r, fig.align="center", fig.width=6, fig.height=6, fig.cap="Figure 2-2 : Sesonal Components by Decomposition Method."}
adjtrend = monthly_ts/trend
y = factor(cycle(adjtrend))
fit_monthly_1 <-auto.arima(adjtrend,
                           max.p = 2,
                           xreg=model.matrix(~0 + y)[, -12],
                           seasonal = F, max.d = 0, max.q = 0)
coef(fit_monthly_1)
seasonal = fit_monthly_1$fitted
pred = trend*seasonal
irregular = monthly_ts/pred
ts.plot(seasonal)

{r, fig.align="center", fig.width=6, fig.height=6, fig.cap="Figure 2-3 : Irregular Components by Decomposition Method."}
ts.plot(irregular)

##### TSL components
{r, fig.align="center", fig.width=6, fig.height=6, fig.cap="Figure 2-3 : graph 4-6 Raw Monthly Time series and Prediction by Decomposition Method."}
ts.plot(monthly_ts, pred, lty = 1:2, ylab = "Monthly Sales", col = c("blue", "red"))
# * Create table for TSl components ----
date <- ymd("20110601") + months(1:length(monthly_ts)-1)
table4 <- data.frame(date, monthly_ts, trend, seasonal, irregular)
table4

The auto.arima illustrated that raw monthly sales data is likely to presence MA1. By means there is a correlation between at point in time error with the lag=1 past error. Depending on the sample size such correlation of error can be ignored, but it is always nice to verify on this by following steps.

[step 1] See the scatterplot {randomness or correlation} of redsiduals/irregular component against time/Z where Z here is a multiple regression model of MA1 
Z = Xß + e 
Z - Z^ = e --> covariance matrix, cov(e) is not a diagonal matrix thus the correlation between the e vector do presnece. 

[step2] The noticeable function on the scatter-plot, e.g. change in variance correlation or any sort of function will argue that there is a chance of rejecting the Null Hypothesis that irregular component is independent 

fit <- tslm(monthly_ts ~ 0)

summary(fit)
checkresiduals(fit)

fit_T <- tslm(monthly_ts ~ trend)
summary(fit_T)
checkresiduals(fit_T)

fit_S <- tslm(monthly_ts ~ season)
summary(fit_S)
checkresiduals(fit_S)   

fit_TS <- tslm(monthly_ts ~ season + trend)
summary(fit_TS)
checkresiduals(fit_TS)

 fourier_fit_TS <- tslm(monthly_ts ~ season + trend + fourier(monthly_ts, K=2))
summary(fourier_fit_TS)
checkresiduals(fourier_fit_TS)

monthly_df <- as.data.frame(monthly_ts)
monthly_df[,"Residuals"]  <- as.numeric(residuals(fit))
monthly_df[,"Residuals_w_T"]  <- as.numeric(residuals(fit_T))
monthly_df[,"Residuals_w_S"]  <- as.numeric(residuals(fit_S))
monthly_df[,"Residuals_TS_w"]  <- as.numeric(residuals(fit_TS))
monthly_df[,"Residuals_w_fourier"]  <- as.numeric(residuals(fourier_fit_TS))


p_1 <- ggplot(monthly_df, aes(x, y = Residuals)) +
  geom_point() + xlab("") + ylab('residuals')
p_2 <- ggplot(monthly_df, aes(x, y = Residuals_w_T)) +
  geom_point() + xlab("") + ylab('residuals')
p_3 <- ggplot(monthly_df, aes(x, y = Residuals_w_S)) +
  geom_point() + xlab("") + ylab('residuals')
p_4 <- ggplot(monthly_df, aes(x, y = Residuals_TS_w)) +
  geom_point() + xlab("") + ylab('residuals')
p_5 <- ggplot(monthly_df, aes(x, y = Residuals_w_fourier)) +
  geom_point() + xlab("") + ylab('residuals')

gridExtra::grid.arrange(p_1, p_2, p_3, p_4)

cbind(Data=monthly_ts, Fitted=fitted(fit_TS)) %>%
  as.data.frame() %>%
  ggplot(aes(x = Data, y = Fitted,
             colour = as.factor(cycle(monthly_ts)))) +
  geom_point() +
  ylab("Predcited Sales") + xlab("Actual Sales") +
  ggtitle("Monthly Sales") +
  scale_colour_brewer(palette="Dark2", name="Month") +
  geom_abline(intercept=0, slope=1)
cbind(Data=monthly_ts, Fitted=fitted(fit_TS)) %>%
  as.data.frame() %>%
  ggplot(aes(x = Data, y = Fitted,
             colour = as.factor(cycle(monthly_ts)))) +
  geom_point() +
  ylab("Predcited Sales") + xlab("Actual Sales") +
  ggtitle("Monthly Sales") +
  scale_colour_brewer(palette="Paired", name="Month") +
  geom_abline(intercept=0, slope=1)
# Sesonal component
monthly_ts %>% stl(s.window = "per") %>%
  autoplot() + xlab("")
monthly_ts %>% mstl() %>%
  autoplot() + xlab("")

#### 5.0 Joinging with Promotion Data ----

resp <- resp_df %>% 
  select(customer_id, response) %>% 
  setNames(c("customer_id", "campaign"))
cust_ready <- cust_prep_flag %>% 
  left_join(resp, by = "customer_id")
cust_ready

#### 6.0 Train and Test : Data Splitting (2-Stages) ----
######* Stage 1 : Random Splitting by Customer ID ---

set.seed(42)
ids_train <- cust_ready %>% 
  pull(customer_id) %>% 
  unique() %>% 
  sample(size = round(0.8*length(.))) %>% 
  sort()
split_1_train <- cust_ready %>% 
  filter(customer_id %in% ids_train)
split_1_test <- cust_ready %>% 
  filter(!customer_id %in% ids_train)

######* Stage 2 : Time Splitting ----
{r, fig.show = 'hide'}
splits_2_train <- split_1_train %>% 
  timetk::time_series_split(
    date_var = trans_date,
    assess = "3 month",
    cumulative = TRUE
  )
fig_splits_2_train <- splits_2_train %>% 
  tk_time_series_cv_plan() %>% 
  mutate(monthly = floor_date(trans_date, "month")) %>%
  filter(trans_date > as.Date("2011-05-31") & trans_date < as.Date("2015-03-01")) %>% 
  group_by(monthly) %>% 
  mutate(monthly_sales = sum(tran_amount)) %>% ungroup() %>% 
  plot_time_series_cv_plan(monthly, monthly_sales)
splits_2_test <- split_1_test %>% 
  timetk::time_series_split(
    date_var = trans_date,
    assess = "3 month",
    cumulative = TRUE
  )
fig_splits_2_test <- splits_2_test %>% 
  tk_time_series_cv_plan() %>% 
  mutate(monthly = floor_date(trans_date, "month")) %>%
  filter(trans_date > as.Date("2011-05-31") & trans_date < as.Date("2015-03-01")) %>% 
  group_by(monthly) %>% 
  mutate(monthly_sales = sum(tran_amount)) %>% ungroup() %>% 
  plot_time_series_cv_plan(monthly, monthly_sales)
# ** Make in-sample targets from training data ---
train <- rsample::training(splits_2_train)
target_train <- rsample::testing(splits_2_train) %>% 
  group_by(customer_id) %>% 
  summarise(
    spend_90_total = sum(tran_amount),
    spend_90_flag = 1
  )
# ** Make in-sample targets from testing(splits_2) ---
test <- rsample::training(splits_2_test)
target_test <- testing(splits_2_test) %>% 
  group_by(customer_id) %>% 
  summarise(
    spend_90_total = sum(tran_amount),
    spend_90_flag = 1
  )

##### 7.0 RFM Score Feature Engineering  ----
######*EAD 

train %>% 
  group_by(customer_id) %>% 
  mutate(start = min(trans_date),
         end = max(trans_date),
         duration = end - start) %>% 
  ggplot() +
  geom_histogram(aes(duration))
analy_day <- max(train$trans_date)
p_hist <- train %>% 
  group_by(customer_id) %>% 
  mutate(recency_days = as.numeric(analy_day - max(trans_date)),
         frequency = n(), 
         monetary = sum(tran_amount)) %>%  ungroup()
hist(p_hist$recency_days)
hist(p_hist$frequency)
hist(p_hist$monetary)
skimr::skim(p_hist)

The histogram of recency is heavily right-hand skewed. As, I have framed to primilarly focus on targeting superior customer, I decided to bin in the expotential manner just like the histogram.
Same binning techniques applies to the frequency and monetary as well, so that I can put equal weights on these three indicators. 

result <- c() 
j <- 0
for(i in 1:5){
  j = j + i
  result[i] = 1 -(j/(1+2+3+4+5))
  print(result)
}
generate_rfm <- function(data, target_data) {
  
  analy_day <- max(data$trans_date) + 1
  
  step_1 <- data %>% 
    group_by(customer_id) %>% 
    summarise(recency_days = as.numeric(analy_day - max(trans_date)),
              frequency = n(),
              monetary = sum(tran_amount),
              sameday_pur_flag = mean(sameday_pur_flag),
              campaign = mean(campaign)) %>% ungroup() 
  
  R_level <- quantile(step_1$recency_days, probs = result)
  F_level <- quantile(step_1$frequency, probs = result)
  M_level <- quantile(step_1$monetary, probs = result)
  
  step_2 <- step_1 %>%
    mutate(R_score = case_when(.$recency_days >= R_level[1] ~ 1,
                               .$recency_days >= R_level[2] ~ 2,
                               .$recency_days >= R_level[3] ~ 3,
                               .$recency_days >= R_level[4] ~ 4,
                               TRUE ~ 5),
           F_score = case_when(.$frequency >= F_level[1] ~ 5,
                               .$frequency >= F_level[2] ~ 4,
                               .$frequency >= F_level[3] ~ 3,
                               .$frequency >= F_level[4] ~ 2,
                               TRUE ~ 1),
           M_score = case_when(.$monetary >= M_level[1] ~ 5,
                               .$monetary >= M_level[2] ~ 4,
                               .$monetary >= M_level[3] ~ 3,
                               .$monetary >= M_level[4] ~ 2,
                               TRUE ~ 1))
  step_2 %>% 
    left_join(
      target_data
    ) %>% 
    replace_na(replace = list(
      spend_90_total = 0,
      spend_90_flag = 0)
    ) %>% 
    mutate(spend_90_flag = as.factor(spend_90_flag))
}
train_pre_score <- generate_rfm(train, target_train)
test_pre_score <- generate_rfm(test, target_test)


# RFM Scoring 
generate_rfm_score <- function(pre_score_data, ...) {
  
  pre_score_data %>% 
    dplyr::group_by(...) %>% 
    dplyr::summarise(cust = n_distinct(customer_id),
                     total_monetary = sum(monetary)) %>% ungroup() %>% 
    dplyr::mutate(per_cus = total_monetary/cust,
                  effect = per_cus/per_cus[1],
                  prop_cus = cust/sum(cust),
                  prop_money = total_monetary/sum(total_monetary),
                  effect = prop_money/prop_cus)
}
train_R_score_table <- generate_rfm_score(train_pre_score, R_score)
train_F_score_table <- generate_rfm_score(train_pre_score, F_score)
train_M_score_table <- generate_rfm_score(train_pre_score, M_score)
R_score_effect <- sum(train_R_score_table$effect)
F_score_effect <- sum(train_F_score_table$effect)
M_score_effect <- sum(train_M_score_table$effect)
sum_effect <- sum(R_score_effect, F_score_effect, M_score_effect) 
weight <- c(R_score_effect/sum_effect, F_score_effect/sum_effect, M_score_effect/sum_effect)
RFM_function <- function(x, y, z, w){
  RFM_Score <- x*w[1] + y*w[2] + z*w[3]
  return(RFM_Score)
}
normalize <- function(x) {
  return(100*(x-min(x))/(max(x)-min(x)))
}
generator_RFM_score <- function(pre_score_data) {
  pre_score_data %>% 
  mutate(RFM_Score = RFM_function(.$R_score,
                                  .$F_score,
                                  .$M_score,
                                  w = weight),
         RFM_Score = round(normalize(RFM_Score)),
         campaign = as.factor(campaign),
         sameday_pur_flag = as.factor(sameday_pur_flag),
         campaign = replace_na(campaign, 0),
         RFM_Score_gr = ifelse(RFM_Score >= 90, 10,
                               ifelse(RFM_Score >= 80, 9,
                                      ifelse(RFM_Score >= 70, 8,
                                             ifelse(RFM_Score >= 60, 7,
                                                    ifelse(RFM_Score >= 50, 6,
                                                           ifelse(RFM_Score >= 40, 5,
                                                                  ifelse(RFM_Score >= 30, 4,
                                                                         ifelse(RFM_Score >= 20, 3,
                                                                                ifelse(RFM_Score >= 10, 2,
                                                                                       1))))))))))
}
train_RFM <- generator_RFM_score(train_pre_score)
test_RFM <- generator_RFM_score(test_pre_score)


hist(train_RFM$RFM_Score_gr)
train_RFM %>% 
  group_by(RFM_Score_gr) %>% 
  summarise(avr_freq = mean(frequency),
         avr_monetary = mean(monetary))

###### * Visualisation
There is a clear separation of customer  behavior in monetary amount to the frequency ratio. To me, this boundary indicates that there are some customers not willing to spend above this boundary which could be response of product cost or product itself or due to the service. Due to the lack of information and variables, I do not plan on investigating this further, however, it seems valid to find the slope to separate these two groups. 

a_plot <- ggplot(data = train_RFM, aes(x = RFM_Score, y = monetary, color = campaign)) +
  geom_point(position = "jitter", size = 0.7) +
  theme_bw() + scale_color_manual(values=wesanderson::wes_palette(name="Royal1", 2))
b_plot <- ggplot(data = train_RFM, aes(x = recency_days, y = monetary, color = campaign)) +
  geom_point(position = "jitter", size = 0.7) +
  theme_bw() + scale_color_manual(values=wesanderson::wes_palette(name="Royal1", 2))
c_plot <- ggplot(data = train_RFM, aes(x = frequency, y = monetary, color = campaign)) + 
  geom_point(position = "jitter", size = 0.7) +
  theme_bw() + scale_color_manual(values=wesanderson::wes_palette(name="Royal1", 2))
d_plot <- ggplot(data = train_RFM, aes(x = recency_days, y = frequency, color = campaign)) +
  geom_point(position = "jitter", size = 0.7) +
  theme_bw() + scale_color_manual(values=wesanderson::wes_palette(name="Royal1", 2))
gridExtra::grid.arrange(a_plot, b_plot, c_plot, d_plot)


c_plot

In comparison to the graph above, the RFM score has segmented customer spending behaviour more illustratively. However, customer lower than RFM score of 3 are more visually hidden. 
I will induce seasonal and customer interpurchase latency variables to support further segmenting these groups. 

a_plot

##### * With respect to RFM_gr

e_plot <- ggplot(data = train_RFM, aes(x = RFM_Score, y = monetary, color = RFM_Score_gr)) +
  geom_point(position = "jitter", size = 0.7) +
  theme_bw() 
f_plot <- ggplot(data = train_RFM, aes(x = recency_days, y = monetary, color = RFM_Score_gr)) +
  geom_point(position = "jitter", size = 0.7) +
  theme_bw() 
g_plot <- ggplot(data = train_RFM, aes(x = frequency, y = monetary, color = RFM_Score_gr)) + 
  geom_point(position = "stack", size = 0.7) +
  theme_bw() 
h_plot <- ggplot(data = train_RFM, aes(x = recency_days, y = frequency, color = RFM_Score_gr)) +
  geom_point(position = "jitter", size = 0.7) +
  theme_bw()
gridExtra::grid.arrange(e_plot, f_plot, g_plot, h_plot)

The correlation between monetary and frequency is absurd when it comes to segmentation, which results unequal weight balance between R,F,M components. Physically inducing more weight {effect} on recency could re-adjust these scales, however, I prefer retaining their natural distribution and discover for more explainable variables from the data, if possible. 

# Flag two cluster observed from c_plot which was found at monetary/frequency  = 57 
train_RFM_complete <- train_RFM %>% 
  mutate(money_freq_ratio = (monetary/frequency),
         spend_act = ifelse(money_freq_ratio < 57, 0, 1),
         spend_act = as.factor(spend_act),
         RFM_Score_gr = as.factor(RFM_Score_gr)) 
test_RFM_complete <- test_RFM %>% 
  mutate(money_freq_ratio = (monetary/frequency),
         spend_act = ifelse(money_freq_ratio < 57, 0, 1),
         spend_act = as.factor(spend_act),
         RFM_Score_gr = as.factor(RFM_Score_gr)) 
test_RFM_complete %>% 
  dplyr::filter(spend_act == 1) %>% 
  dplyr::group_by(RFM_Score_gr) %>% 
  dplyr::summarise(count = n(),
                   recency_days = mean(recency_days),
                   frequency = mean(frequency),
                   monetary = mean(monetary))
test_RFM_complete %>% 
  dplyr::filter(spend_act == 0) %>% 
  dplyr::group_by(RFM_Score_gr) %>% 
  dplyr::summarise(count = n(),
                   recency_days = mean(recency_days),
                   frequency = mean(frequency),
                   monetary = mean(monetary))
psych::pairs.panels(test_RFM_complete[, c("RFM_Score", "recency_days", "monetary", "frequency")])