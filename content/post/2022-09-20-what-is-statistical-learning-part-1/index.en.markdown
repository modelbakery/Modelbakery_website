---
title: "What is statistical learning - Part 1"
author: "Package Build"
date: '2021-11-20'
subtitle: The concept of IID in Statistical Learning
slug: The concept of IID in Statistical Learning
categories: R
tags:
- Statistics
- R
summary: ''
authors: []
lastmod: '2021-11-20T19:35:42+09:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---



### Purpose: 

Statistical learning assumes the presence of a relationship between response $Y $ and (p-dimensional) predictors $X = (X_1,\ X_2,...,\ X_p)  $, under the assumption that these variables are Random Variables; its general form is as below: 

### Objective


#### [libraries]


```r
library(fs)
library(tidyverse)
library(janitor) 
library(remotes)
library(ecos)
library(lubridate)
library(ggfortify)
library(xts)
library(patchwork)
library(stargazer)
```

#### [GDP 총 생산량과 콜금리의 관계]

[1] ECOS 한국은행 API 활용한 데이터 추출
이때 필요한 key + code 값은 API 요쳥자 Key, state_code(통계표 코드), 
item_code1(통계항목 코드), cycle(시계열 단위)

한국은행 자료 코드는 아래에서 확인 할 수 있음
https://ecos.bok.or.kr/api/#/DevGuide/StatisticalCodeSearch

한국은행 OPEN API를 이용하기 위해서는 Key를 부여받아야하는데, 아래의 링크에서 신청해서 받을것
https://ecos.bok.or.kr/api/#/AuthKeyApply


```r
my_key <- c('V4386W138JSMBGB30HOF')
```


[1-1] 한국은행 OPEN API 접속하여 콜금리 시장금리 (월별, 분기별) 추출
  + 월별 및 분기자료 불러오기: 콜금리(1.3.2.2 시장금리(월, 분기, 년) -> 무담보콜금리 전체
  + statSearch(사용자 지명 코드, state_code(통계표 코드), item_code1(통계항목 코드), cycle(시계열 단위))


```r
call_m <- statSearch(api_key = my_key, stat_code = '721Y001',
           item_code1 = '1020000', cycle = 'M')

call_q <- statSearch(api_key = my_key, stat_code = '721Y001',
                     item_code1 = '1020000', cycle = 'Q')
```

불필요한 제거한 time과 data_value(수치)만 추출 및 문자속성인 time을 lubridate 패키지의 ym() 이용하여 날짜속성으로 변환 

```r
 call_m <- call_m %>% 
  select(time, data_value) %>% 
  mutate(time = lubridate::ym(time)) %>% 
  rename('call_m' = data_value,
         'date' = time)

 call_q <- call_q %>% 
   select(time, data_value) %>% 
   mutate(time = lubridate::yq(time)) %>% 
   rename('call_q' = data_value,
          'date' = time) 
```

시계열 자료는 xts함수를 이용해서 만든 후 autoplot을 활용하여 시계열 그래프 생성 

```r
tscall_m <- xts(call_m$call_m, order.by = call_m$date) 

tscall_m %>% 
  autoplot() + ggtitle("월별콜금리 (이코스 한국은행)") + xlab("년도") +ylab("%")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-5-1.png" width="672" />

```r
tscall_q <- xts(call_q$call_q, order.by = call_q$date) 

tscall_q %>% 
  autoplot() + ggtitle("분기별콜금리 (이코스 한국은행)") + xlab("년도") +ylab("%")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-5-2.png" width="672" />

[1-2] 월별 소비자 물가 지수 (CPI) 자료 불러오기: 4.2.1 소비자물가 지수(901Y009) -> 총지수(0) 

```r
cpi_m <- statSearch(api_key = my_key,
                    stat_code = '901Y009',
                    item_code1 = '0',
                    cycle = 'M')
# 불필요한 제거 및 필요한 변수 속성 변환 
rcpi_m <- cpi_m %>% 
  select(time, data_value) %>% 
  mutate(time = ym(time)) %>% 
  rename('cpi_m' = data_value,
         'date' = time) 
```


시계열 자료는 xts 함수 이용해서 만들기 및 시계열 그래프화 

```r
tscpi_m <- xts(rcpi_m$cpi_m, rcpi_m$date) 

g_tscpi_m <- tscpi_m %>% 
  autoplot() + ggtitle("CPI")
```

인플레이션 계산하기: 전년 동기대비 
  + lag함수를 사용시 에러 발생, stats 패키지의 lag를 쓴다는 명시가 필요함 
  + Inf = [{CPI(t) - CPI(t-12)}/CPI(t-12)]*100
  + patchwork 패키지를 활용한 autoplot 다각화 


```r
inf_m <- 100*(tscpi_m/stats::lag(tscpi_m, 12)-1)

g_inf_m <- inf_m %>% 
  autoplot() + ggtitle("Inflation") + xlab("년도") +ylab("%")
```


```r
g_tscpi_m / g_inf_m
```

```
## Warning: Removed 12 row(s) containing missing values (geom_path).
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-9-1.png" width="672" />

[3] 산업생산자료 가져오기: 산업생산자료의 경우 원계월과 계절조정을 선택하는데 있어서 item_code2를 사용 (8.1.3. 전산업생산지수 (농림어업제외)(901Y033) -> 전산업생산지수(A00)) -> 계절조정(2)


```r
rind_m <- statSearch(api_key = my_key, 
                    stat_code = "901Y033",
                    item_code1 = "A00",
                    item_code2 = "2",
                    cycle = "M")

ind_m <- rind_m %>% 
  select(time, data_value) %>% 
  mutate(time = ym(time)) %>% 
  rename('ind_m' = data_value, 
         'date'  = time)

tsind_m <- xts(ind_m$ind_m, ind_m$date) 
```


```r
tsind_m %>% 
  autoplot() + ggtitle("산업생산지수") + xlab("연도") 
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-11-1.png" width="672" />

GDP자료 가져오기 (2.1.2.2.2 국내총생산에 대한 지출(계절조정, 실질, 분기)(200Y008)) -> 국내총생산에 대한 지출(10601)

```r
rgdp <- statSearch(api_key = my_key,
                  stat_code = "200Y008",
                  item_code1 = "10601",
                  cycle = "Q")


gdp <- rgdp %>% 
  select(time, data_value) %>% 
  mutate(time = lubridate::yq(time)) %>% 
  rename('gdp'= data_value,
         'date' = time)


tsgdp <- xts(gdp$gdp, gdp$date) 
```


```r
tsgdp %>% 
  autoplot() +ggtitle("국내총생산") + xlab("년도") + ylab("/1,000,000,000")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-13-1.png" width="672" />

월별 xts자료들 merge하기 

```r
mergem <- merge(tscall_m, inf_m) %>% 
  merge(tsind_m) %>% 
  na.omit()

ols1 <- lm(log(tsind_m)~tscall_m + inf_m, mergem)
```


[해석] 금리 계수가 -0.12085로 나오는데 해석은 다음과 같다 
 + `\(ln(Y) = beta*X -> dlny/dx = beta -> (dy/y)*100/100*dx = beta -> %y/dx = 100*beta\)`
 + 금리는 %로 기록이 되어 있기 때문에, 금리가 1단위(1%p) 증가하면 생산은 -11.7% 감소한다고 해석. 


```r
head(mergem)
```

```
##            tscall_m    inf_m tsind_m
## 2000-01-01     4.77 1.890794    56.7
## 2000-02-01     5.00 1.770717    56.8
## 2000-03-01     5.10 2.111580    57.9
## 2000-04-01     5.10 1.444610    57.7
## 2000-05-01     5.13 1.103513    59.2
## 2000-06-01     5.14 2.216825    59.5
```

```r
autoplot(mergem)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-15-1.png" width="672" />

The plot suggests that one might be able to predict GDP using call-interest rates. However, the function $f $ which connects the output variables from the input variables is in general unknown. In short, the conditioned distribution of $Y $  given $X $, the blueprint, is unknown; consequently, statistical learning refers to a set of approaches for estimating $f $: ***prediction and inference***. 

As data scientists, our prime goal is to achieve $\hat{f} $ which yields accurate predictions for $Y $ but  $\hat{f} $ is often treated as a black box, in essence, depending on the modelling purposes and research areas the level of interpretability can be more or less important than its accuracy.  

---

### How? - the i.i.d Rule

In statistics, the idea is that some variables are independent and identically distributed (identical probability density function) in theory. In practice, we see random-looking variables and some much closer than others to i.i.d. 

- Independent: variables are statistically independent of one another hence no correlation
- identically distributed: identical probability density function meaning that the variable’s variance is the same.

We assume the i.i.d rule and validate it by the randomness of the epsilon, hence it is important the residue between observed data $Y $ and modelled data $\hat{Y} $ is not far from being independent of $X $  and has a mean 0 (i.i.d). For the raw residues, the modellers should apply weights (parameter adjustment) and filters (regularisation) to get i.i.d residues. (Perhaps, applying the grid search)   

**The challenge of the ML modelling usually sits here, that is minimizing sums of squares of residuals as well as CHECKING whether the residue does follow the i.i.d rule.**  

In this setting, since the error term averages to zero, we can predict $Y $ using 

$$
\hat{Y} = \hat{f}(X)
$$

---

### Predictions

The accuracy of the model $\hat{Y} $ as a prediction of $Y $depends on two quantities

- Reducible error
- Irreducible error

What these errors suggest is that no matter how well we estimate $f $ with the perfect estimate $\hat{Y} = f(X) $, we cannot reduce the error introduced by  $\epsilon $ 

Why? - the $\epsilon $ may contain unmeasured variables that are useful in predicting the $Y $ and also may also be from unmeasurable variation etc special events. 

Expected value + Variance 

The irreducible error will always provide an upper bound on the accuracy of our prediction for $Y. $ Where this bound is certainly always unknown in practice.


### Inference

Often analysts are interested in understanding quantitatively how much $Y $ is affected as a function of  $X $changes. The following questions will advise you on how to come about understanding their relationship. 

- Which predictors are associated with the response? Is it only the fraction of the available predictors or instances are substantially associated with $Y $
주요 변수 추출 → 차원 축소
- What is the relationship between the response and each predictor?
    - Correlation and Covariance
    - Multi-collinearity due to its complexity of $f $?
- Can the relationship be adequately summarised linearly, or is the relationship more complicated?
- Are you continuously referring back to the business problem?


