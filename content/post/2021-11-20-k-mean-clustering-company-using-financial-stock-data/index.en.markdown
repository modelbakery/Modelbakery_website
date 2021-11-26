---
title: "K-Mean Clustering Company using Financial Stock Data"
author: "Package Build"
date: '2021-11-20'
slug: K-Mean Clustering Company using Financial Stock Data
categories: R
tags:
- Academic
- Clustering
- Distance Matrix
subtitle: ''
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

<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index.en_files/plotly-binding/plotly.js"></script>
<script src="{{< blogdown/postref >}}index.en_files/typedarray/typedarray.min.js"></script>
<script src="{{< blogdown/postref >}}index.en_files/jquery/jquery.min.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/crosstalk/css/crosstalk.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/crosstalk/js/crosstalk.min.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/plotly-htmlwidgets-css/plotly-htmlwidgets.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/plotly-main/plotly-latest.min.js"></script>

# Purpose:

B2B sales organisation wants to know which companies are similar to each other to help in identifying potential customers in various segments of the market. There are many techniques for market research but in here we will try to penetrate various market segments using companies stock price data.

When it comes to market research or investment, looking at the returns of dozens of companies will be a tricky analysis to draw various insights. The cluster analysis process of dividing a common set of companies into groups (by range and scope) provides a more holistic perspective on the internal and external relationship of the relevant companies. Since stocks have a tendency to fluctuate together, grouping by the similarity in return trend seems an applicable clustering recipe in practice.

# Reference:

The code workflow here is been devloped from University of Business Science 101 course & UC Business analytics R programming guide.

# Agenda:

#### \[1\] Pull Stock Price Data from Yahoo Finance using getSymbols

#### \[2\] Data Preparation: Preparing data for clustering (User-Item or User-date format) + Normalisation

#### \[3\] Determine Optimal Clusters: Identify the optimal number of clusters from various statistical approaches

#### \[4\] Visualisation aid by UMAP: 2-Dimensional feature reduction + plotly

$$ 
return_{daily} = \frac{price_{i}-price_{i-1}}{price_{i-1}}
$$

# The Concept of Clustering

The task of clustering analysis is to divide the set of objects into homogeneous groups. The ideal grouping is where the arbitrary objects belonging to the same group are more similar to each other than arbitrary objects belonging different groups.

There are two questions we must find before applying cluster analysis$^1$:

-   How to define the similarity between the object - the distance metric that we use to identify the common traits carries some kind of semantic meaning of similarity?

-   In what manner should one make use of the thus defined similarity in the process of grouping - does clustering provide any new insight into the data?

### Why Would One Undergo Cluster Analysis

One may have collected large data set at different experimental sites and resources. Data may stem from subjects related to one and another, and there are further possibilities of hidden variables, e.g. macro external influence or special events, which in a way could expand the variance and much uninterpretable noise in the data. If one is unaware of such a hierarchical relationship or is absent in this domain of knowledge, it is advised to apply a clustering method prior to further analysis.

For an example of its interesting application, cluster analysis on both the customers and their typical and the atypical product items helps to uncover hidden needs of the customer database and verify the hypotheses concerning these common user-item relationships: play an important role in the development of the recommendation system.

# Methods for measuring distances

The choice of distance matrix is a critical step in cluster. It determines how the similarity of two elements (x, y) is calculated and it will directly influence the shape of the cluster.

#### Euclidean Distance:

-   Most commonly used and often a default setting in many distance matrix algorithm in R

$$
d_{euc}(x, y) = \sqrt{\sum_{i=1}^n(x_i-y_i)^2}
$$

#### Manhattan Distance:

$$
d_{man}(x, y) = \sum_{i=1}^n|(x_i-y_i)|
$$

#### Correlation-based distance:

-   Pearson correlation: Measures the degree of a linear relationship between two profiles. It is a paramteric correlation which depends on the distribution of the data.

-   Kendall & Spearman correlation correlation are non-parametric and they are used to perform rank-based correlation analysis. (Outlier sensitivity can be mitigated by using Spearman’s correlation instead of Pearson’s correlation)

-   Considers two objects to be similar if their features are highly correlated, even though the observed values may be far apart in terms of Euclidean distance.

-   Correlation-based distance often preferred over two above matrix in case for dealing with high dimensional data set, due to curse of dimensionality.

#### What type of distance measure should we choose?

Despite the choice of distance measure has a strong influence on the clustering result, it is often arbitrary. But we must note two things:

\[1\] If we want to identify clusters of observations with the samll overall profiles regardless of their magnitudes, we shuld go with **correlation-based distance** as a dissimilarity measure. In marketing, we can imagine a case where organisation like to identify group of shoppers with the same preference in terms of items, regardless of the volume of items they bought.

\[2\] If Euclidean distance is chosen, then observations with high values of features will be clustered together. The same holds true for observations with low values of features.

# K-means Aglorithm

Kmeans algorithm is an iterative algorithm that tries to partition the dataset into pre-defined k distinct non-overlapping subgroups (clusters) where each data point belongs to only one group. It tries to make the intra-cluster data points as similar as possible while also keeping the clusters as different (far) as possible. It assigns data points to a cluster such that the sum of the squared distance between the data points and the cluster’s centroid (arithmetic mean of all the data points that belong to that cluster) is at the minimum. The less variation we have within clusters, the more homogeneous (similar) the data points are within the same cluster.

#### Basic Idea

The way that kmeans algorithm operates are as follow:

\[1\] Specify the number of clusters (K) to be created.

\[2\] Select random k objects from the data set as the initial cluster centers.

\[3\] Assigns each observation to their closest centroid, based on the Euclidean distance between the object and the centroid.

\[4\] For each of the k clusters **update the cluster centroid** by calculating the new mean values of all the data points in the cluster. The centroid of a `\(\ K_{th}\)` cluster is a vector of length p containing the means of all variables for the observations in the `\(\ K_{th}\)` cluster; p is the number of variables.

\[5\] Iteratively minimize the total within sum of squares. That is, iterate steps 3 and 4 until the cluster assignments stop changing or the maximum number of iterations is reached. Hence, there is a tendency of retaining reliability of the accuracy with greater number of iteration.

The approach kmeans follows to solve the problem is called Expectation-Maximization. The E-step is assigning the data points to the closest cluster. The M-step is computing the centroid of each cluster. Below is a break down of how we can solve it mathematically (feel free to skip it).

Sum of the squares deviation from the mean or the centroid.

\$\$
\_{i=1}<sup>n(x\_i-)</sup>2 \\

\_{i=1}^n\|(x\_i-)\| \\

\$\$

$$
\frac{\partial f}{\partial x}
$$

``` r
library(tidyverse)
library(tidyquant)
library(quantmod)
library(broom)
library(umap)
library(plotly)
library(factoextra)
library(cluster)
library(kableExtra)
```

``` r
SP500_prices_tbl <- read_rds("/Users/seunghyunsung/Documents/GitHub/Modelbakery_backup/post3/sp500stock/sp_500_prices_tbl_2019.11_2021.11.rds")

SP500_index_tbl <- read_rds("/Users/seunghyunsung/Documents/GitHub/Modelbakery_backup/post3/sp500stock/SP500_index_list_tbl.rds")
```

``` r
SP500_prices_tbl %>% head(20) %>% kbl() %>% kable_material()
```

<table class=" lightable-material" style="font-family: &quot;Source Sans Pro&quot;, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
symbol
</th>
<th style="text-align:left;">
date
</th>
<th style="text-align:right;">
open
</th>
<th style="text-align:right;">
high
</th>
<th style="text-align:right;">
low
</th>
<th style="text-align:right;">
close
</th>
<th style="text-align:right;">
volume
</th>
<th style="text-align:right;">
adjusted
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-11-21
</td>
<td style="text-align:right;">
78.97
</td>
<td style="text-align:right;">
78.97
</td>
<td style="text-align:right;">
77.31
</td>
<td style="text-align:right;">
78.30
</td>
<td style="text-align:right;">
2142200
</td>
<td style="text-align:right;">
77.19080
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-11-22
</td>
<td style="text-align:right;">
78.61
</td>
<td style="text-align:right;">
79.19
</td>
<td style="text-align:right;">
78.23
</td>
<td style="text-align:right;">
79.12
</td>
<td style="text-align:right;">
1869700
</td>
<td style="text-align:right;">
77.99919
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-11-25
</td>
<td style="text-align:right;">
79.45
</td>
<td style="text-align:right;">
80.46
</td>
<td style="text-align:right;">
79.30
</td>
<td style="text-align:right;">
80.26
</td>
<td style="text-align:right;">
2640800
</td>
<td style="text-align:right;">
79.12303
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-11-26
</td>
<td style="text-align:right;">
78.57
</td>
<td style="text-align:right;">
81.03
</td>
<td style="text-align:right;">
77.96
</td>
<td style="text-align:right;">
80.95
</td>
<td style="text-align:right;">
5329900
</td>
<td style="text-align:right;">
79.80327
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-11-27
</td>
<td style="text-align:right;">
81.08
</td>
<td style="text-align:right;">
81.34
</td>
<td style="text-align:right;">
80.69
</td>
<td style="text-align:right;">
81.08
</td>
<td style="text-align:right;">
1628000
</td>
<td style="text-align:right;">
79.93142
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-11-29
</td>
<td style="text-align:right;">
80.96
</td>
<td style="text-align:right;">
81.24
</td>
<td style="text-align:right;">
80.47
</td>
<td style="text-align:right;">
80.77
</td>
<td style="text-align:right;">
835800
</td>
<td style="text-align:right;">
79.62580
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-02
</td>
<td style="text-align:right;">
80.78
</td>
<td style="text-align:right;">
80.99
</td>
<td style="text-align:right;">
80.02
</td>
<td style="text-align:right;">
80.35
</td>
<td style="text-align:right;">
1775600
</td>
<td style="text-align:right;">
79.21176
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-03
</td>
<td style="text-align:right;">
79.52
</td>
<td style="text-align:right;">
80.11
</td>
<td style="text-align:right;">
79.17
</td>
<td style="text-align:right;">
80.10
</td>
<td style="text-align:right;">
1978200
</td>
<td style="text-align:right;">
78.96529
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-04
</td>
<td style="text-align:right;">
80.30
</td>
<td style="text-align:right;">
81.00
</td>
<td style="text-align:right;">
80.18
</td>
<td style="text-align:right;">
80.93
</td>
<td style="text-align:right;">
1690900
</td>
<td style="text-align:right;">
79.78355
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-05
</td>
<td style="text-align:right;">
80.89
</td>
<td style="text-align:right;">
81.74
</td>
<td style="text-align:right;">
80.50
</td>
<td style="text-align:right;">
81.53
</td>
<td style="text-align:right;">
1900000
</td>
<td style="text-align:right;">
80.37504
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-06
</td>
<td style="text-align:right;">
82.24
</td>
<td style="text-align:right;">
82.42
</td>
<td style="text-align:right;">
81.82
</td>
<td style="text-align:right;">
82.21
</td>
<td style="text-align:right;">
1783400
</td>
<td style="text-align:right;">
81.04540
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-09
</td>
<td style="text-align:right;">
82.34
</td>
<td style="text-align:right;">
82.47
</td>
<td style="text-align:right;">
81.55
</td>
<td style="text-align:right;">
81.62
</td>
<td style="text-align:right;">
1913800
</td>
<td style="text-align:right;">
80.46377
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-10
</td>
<td style="text-align:right;">
82.90
</td>
<td style="text-align:right;">
83.80
</td>
<td style="text-align:right;">
82.70
</td>
<td style="text-align:right;">
82.93
</td>
<td style="text-align:right;">
3067700
</td>
<td style="text-align:right;">
81.75521
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-11
</td>
<td style="text-align:right;">
82.93
</td>
<td style="text-align:right;">
83.47
</td>
<td style="text-align:right;">
82.57
</td>
<td style="text-align:right;">
83.42
</td>
<td style="text-align:right;">
1718300
</td>
<td style="text-align:right;">
82.23827
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-12
</td>
<td style="text-align:right;">
83.49
</td>
<td style="text-align:right;">
84.98
</td>
<td style="text-align:right;">
83.17
</td>
<td style="text-align:right;">
84.81
</td>
<td style="text-align:right;">
1920800
</td>
<td style="text-align:right;">
83.60857
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-13
</td>
<td style="text-align:right;">
84.67
</td>
<td style="text-align:right;">
84.74
</td>
<td style="text-align:right;">
83.59
</td>
<td style="text-align:right;">
83.71
</td>
<td style="text-align:right;">
1811200
</td>
<td style="text-align:right;">
82.52417
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-16
</td>
<td style="text-align:right;">
84.47
</td>
<td style="text-align:right;">
84.97
</td>
<td style="text-align:right;">
84.00
</td>
<td style="text-align:right;">
84.45
</td>
<td style="text-align:right;">
1371200
</td>
<td style="text-align:right;">
83.25369
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-17
</td>
<td style="text-align:right;">
84.76
</td>
<td style="text-align:right;">
84.86
</td>
<td style="text-align:right;">
83.78
</td>
<td style="text-align:right;">
83.95
</td>
<td style="text-align:right;">
1653200
</td>
<td style="text-align:right;">
82.76075
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-18
</td>
<td style="text-align:right;">
83.75
</td>
<td style="text-align:right;">
84.05
</td>
<td style="text-align:right;">
83.36
</td>
<td style="text-align:right;">
83.43
</td>
<td style="text-align:right;">
2025500
</td>
<td style="text-align:right;">
82.24812
</td>
</tr>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
2019-12-19
</td>
<td style="text-align:right;">
83.95
</td>
<td style="text-align:right;">
84.67
</td>
<td style="text-align:right;">
83.56
</td>
<td style="text-align:right;">
84.51
</td>
<td style="text-align:right;">
1696000
</td>
<td style="text-align:right;">
83.31284
</td>
</tr>
</tbody>
</table>

``` r
SP500_index_tbl %>% head(20) %>% kbl() %>% kable_material()
```

<table class=" lightable-material" style="font-family: &quot;Source Sans Pro&quot;, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
symbol
</th>
<th style="text-align:left;">
company
</th>
<th style="text-align:left;">
sector
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:left;">
Agilent Technologies Inc. 
</td>
<td style="text-align:left;">
Health Care
</td>
</tr>
<tr>
<td style="text-align:left;">
AAL
</td>
<td style="text-align:left;">
American Airlines Group Inc. 
</td>
<td style="text-align:left;">
Industrials
</td>
</tr>
<tr>
<td style="text-align:left;">
AAP
</td>
<td style="text-align:left;">
Advance Auto Parts Inc. 
</td>
<td style="text-align:left;">
Consumer Discretionary
</td>
</tr>
<tr>
<td style="text-align:left;">
AAPL
</td>
<td style="text-align:left;">
Apple Inc. 
</td>
<td style="text-align:left;">
Information Technology
</td>
</tr>
<tr>
<td style="text-align:left;">
ABBV
</td>
<td style="text-align:left;">
AbbVie Inc. 
</td>
<td style="text-align:left;">
Health Care
</td>
</tr>
<tr>
<td style="text-align:left;">
ABC
</td>
<td style="text-align:left;">
AmerisourceBergen Corporation
</td>
<td style="text-align:left;">
Health Care
</td>
</tr>
<tr>
<td style="text-align:left;">
ABMD
</td>
<td style="text-align:left;">
ABIOMED Inc. 
</td>
<td style="text-align:left;">
Health Care
</td>
</tr>
<tr>
<td style="text-align:left;">
ABT
</td>
<td style="text-align:left;">
Abbott Laboratories
</td>
<td style="text-align:left;">
Health Care
</td>
</tr>
<tr>
<td style="text-align:left;">
ACN
</td>
<td style="text-align:left;">
Accenture Plc Class A
</td>
<td style="text-align:left;">
Information Technology
</td>
</tr>
<tr>
<td style="text-align:left;">
ADBE
</td>
<td style="text-align:left;">
Adobe Inc. 
</td>
<td style="text-align:left;">
Information Technology
</td>
</tr>
<tr>
<td style="text-align:left;">
ADI
</td>
<td style="text-align:left;">
Analog Devices Inc. 
</td>
<td style="text-align:left;">
Information Technology
</td>
</tr>
<tr>
<td style="text-align:left;">
ADM
</td>
<td style="text-align:left;">
Archer-Daniels-Midland Company
</td>
<td style="text-align:left;">
Consumer Staples
</td>
</tr>
<tr>
<td style="text-align:left;">
ADP
</td>
<td style="text-align:left;">
Automatic Data Processing Inc. 
</td>
<td style="text-align:left;">
Information Technology
</td>
</tr>
<tr>
<td style="text-align:left;">
ADSK
</td>
<td style="text-align:left;">
Autodesk Inc. 
</td>
<td style="text-align:left;">
Information Technology
</td>
</tr>
<tr>
<td style="text-align:left;">
AEE
</td>
<td style="text-align:left;">
Ameren Corporation
</td>
<td style="text-align:left;">
Utilities
</td>
</tr>
<tr>
<td style="text-align:left;">
AEP
</td>
<td style="text-align:left;">
American Electric Power Company Inc. 
</td>
<td style="text-align:left;">
Utilities
</td>
</tr>
<tr>
<td style="text-align:left;">
AES
</td>
<td style="text-align:left;">
AES Corporation
</td>
<td style="text-align:left;">
Utilities
</td>
</tr>
<tr>
<td style="text-align:left;">
AFL
</td>
<td style="text-align:left;">
Aflac Incorporated
</td>
<td style="text-align:left;">
Financials
</td>
</tr>
<tr>
<td style="text-align:left;">
AIG
</td>
<td style="text-align:left;">
American International Group Inc. 
</td>
<td style="text-align:left;">
Financials
</td>
</tr>
<tr>
<td style="text-align:left;">
AIZ
</td>
<td style="text-align:left;">
Assurant Inc. 
</td>
<td style="text-align:left;">
Financials
</td>
</tr>
</tbody>
</table>

``` r
SP500_daily_returns_tbl <- SP500_prices_tbl %>% 
    select(symbol, date, adjusted) %>% 
    group_by(symbol) %>% 
    mutate(lag = lag(adjusted, order_by = date, n = 1)) %>% 
    filter(!is.na(lag)) %>% 
    mutate(diff = adjusted - lag) %>% 
    mutate(pct_return = diff/lag)  %>% ungroup() %>% 
    select(symbol, date, pct_return) 
```

## Convert to User-Item Format: here it would be Company-Return Format

``` r
SP500_date_matrix_tbl <- SP500_daily_returns_tbl %>% 
  spread(date, pct_return, fill = 0)
```

``` r
distance <- get_dist(SP500_date_matrix_tbl %>% select(-symbol))
fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-7-1.png" width="672" />

``` r
set.seed(42)

kmeans_obj_mapper <- function(center = 1){
   SP500_date_matrix_tbl %>% 
    select(-symbol) %>% 
    kmeans(centers =center, nstart = 30)
}

kmeans_overview <- tibble(center = 1:10) %>% 
  mutate(
    kmeans_obj_map = center %>% map(kmeans_obj_mapper),
    glance = kmeans_obj_map %>% map(broom::glance)
    )

kmeans_overview %>% unnest(glance) %>% 
  mutate(
    perc_tot.withiness = 
      (tot.withinss/totss) %>% scales::percent()
    ) %>% 
  select(-kmeans_obj_map) %>% 
  kbl() %>% kable_material()
```

<table class=" lightable-material" style="font-family: &quot;Source Sans Pro&quot;, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
center
</th>
<th style="text-align:right;">
totss
</th>
<th style="text-align:right;">
tot.withinss
</th>
<th style="text-align:right;">
betweenss
</th>
<th style="text-align:right;">
iter
</th>
<th style="text-align:left;">
perc\_tot.withiness
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
112.96239
</td>
<td style="text-align:right;">
0.00000
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
100.0%
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
96.68405
</td>
<td style="text-align:right;">
16.27834
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
85.6%
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
91.93936
</td>
<td style="text-align:right;">
21.02303
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
81.4%
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
88.21662
</td>
<td style="text-align:right;">
24.74577
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">
78.1%
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
84.92578
</td>
<td style="text-align:right;">
28.03662
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
75.2%
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
81.99051
</td>
<td style="text-align:right;">
30.97188
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
72.6%
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
80.38649
</td>
<td style="text-align:right;">
32.57590
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
71.2%
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
78.96666
</td>
<td style="text-align:right;">
33.99573
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
69.9%
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
77.52071
</td>
<td style="text-align:right;">
35.44168
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:left;">
68.6%
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
112.9624
</td>
<td style="text-align:right;">
76.16496
</td>
<td style="text-align:right;">
36.79743
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
67.4%
</td>
</tr>
</tbody>
</table>

## Step 4 - Find the optimal value of K

#### Direct Methods: Consists of optimizing a criterion, such as the within cluster sums of squares or the avergae silhouette.

#### Elbow Method

There are several k-means algorithms available. The basic idea behind the Elbow method aims to to minimize the Euclidean distances of all points with their nearest cluster centers, by minimizing total intra-cluster variation (within-cluster sum of squares, WSS).

$$
Total\ Variation = Variation\ Within + Variation\ Between \\
$$
$$
TSS = WSS + BSS\      where\  SS\ = Sum\ of\ Squares  
$$

``` r
set.seed(42)
kmeans_mapper <- function(center = 3) {
    SP500_date_matrix_tbl %>%
        select(-symbol) %>%
        kmeans(centers = center, nstart = 20)
}

cluster_tbl <- tibble(centers = 1:20)

k_means_mapped_tbl <- cluster_tbl %>% 
  mutate(k_means = centers %>% map(kmeans_mapper),
         glance  = k_means %>% map(glance))
```

The Elbow method looks at the total within sum of squares as a function of the number of clusters. With ever increasing the number of clusters (max at number of observations) the WSS will continuously descend in a linear manner. One should choose a number of clusters one before constant rate of WSS change is reached, that is adding another cluster does not significantly influence total WSS.

To note, the elbow method is sometimes ambiguous. In our SP500 return data set, it is difficult to spot optimal cluster k, with our naked eye. Hence, I got the pulse of local region 5\~10 to investigate further using alternative clustering approach.

``` r
k_means_mapped_tbl %>% 
  unnest(glance) %>% 
  ggplot(aes(x = centers, y = tot.withinss)) +
  geom_point(colour = palette_light()[1], size = 3) +
  geom_line(colour = palette_light()[1], size = 1) +
  ggrepel::geom_label_repel(aes(label = centers, alpha = 0.7), colour = palette_light()[1]) +
  theme_tq() +
  labs(
        x = "Number of Clusters K",
        y = "Total Within Sum of Square",
        title = "Scree Plot",
        subtitle = "Purpoe: Minimise difference in distance between the centers of clusters and each of the companies.
Scree Plot determines the optimal number of cluster for K-means",
        caption = "Scree Plot becomes linear (constant rate of change) between 5 and 10 centers for K; 
        hence we select 5~10 clusters to segement the customer base."
    ) +
  theme(legend.position = "none")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-10-1.png" width="672" />

#### Average Silhouette Method

-   Measures the quality of a clustering. It determines how well each object lies within its cluster. A high average silhouette width indicates a good clustering.

``` r
# function to compute average silhouette for k clusters
silhouette_mapper <- function(k) {
    df <- SP500_date_matrix_tbl %>% select(-symbol)
    
    k_means <- df %>%
        kmeans(centers = k, nstart = 20)
    
    ss <- silhouette(k_means$cluster, dist(df))
    if(k == 1){
      return(NA) 
    } else{
    mean(ss[, 3])
    }
}

k_means_silhouette_mapped_tbl <- cluster_tbl %>% 
  mutate(k_means = centers %>% map(silhouette_mapper)) %>% unnest(k_means)
```

#### \[2\] Silhouette Method: Visualisation

``` r
k_means_silhouette_mapped_tbl[-1,] %>% 
  ggplot(aes(centers, k_means)) +
  geom_point(colour = palette_light()[1], size = 3) +
  geom_line(colour = palette_light()[1], size = 1) +
  ggrepel::geom_label_repel(aes(label = centers, alpha = 0.7), colour = palette_light()[1]) +
  theme_tq() +
  labs(
        x = "Number of Clusters K",
        y = "Average Silhouette Width",
        title = "Scree Plot",
        subtitle = "Purpoe: Minimise difference in distance between the centers of clusters and each of the companies.
Scree Plot determines the optimal number of cluster for K-means",
        caption = "Scree Plot becomes linear (constant rate of change) between 5 and 10 centers for K; 
        hence we select 5~10 clusters to segement the customer base."
    ) +
  theme(legend.position = "none")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-12-1.png" width="672" />

#### Statistical Testing Methods: consists of comparing evidence against null hypothesis. An example is the gap analysis.

#### Gap Statistic Method

The gap analysis compares the total within intra-cluster variation for different values of k with their expected values under null reference distribution of the data. The estimate of the optimal clusters will be value that maximise the gap statistics. This means that the clustering strucutre is far away from the random uniform distribution of points.

#### Conclusion:

-   In order to retain the hierachical relationship with industry sector

## Visualising k-means clusters

#### Use UMAP for 2-D Projection

Once K-Means Clustering is performed, we can use UMPA (or PCA) to help us visualise each data point according to its cluster assignment. The problem that these observations (companies) are high dimension in space can be solved by applying a dimensionality reduction algorithm to output two most influencial variables respect to the originial variables.

``` r
umap_obj <- SP500_date_matrix_tbl %>% 
    select(-symbol) %>% 
    umap()

umap_result_tbl <- umap_obj$layout %>% 
    as_tibble() %>% 
    setNames(c("x", "y")) %>% 
    bind_cols(SP500_date_matrix_tbl %>% select(symbol))
```

``` r
# Get the k_means_obj from the 6th center
k_means_obj <- k_means_mapped_tbl %>% 
    filter(centers == 6) %>% 
    pull(k_means) %>%  pluck(1) 

umap_kmeans_SP500_result_tbl <- k_means_obj %>% 
    broom::augment(SP500_date_matrix_tbl %>% select(symbol)) %>%
    left_join(umap_result_tbl, by = "symbol") %>% 
    left_join(SP500_index_tbl %>% select(symbol, company, sector), by = "symbol")
```

``` r
indus_mapper <- function(cluster =1){
  foo <- umap_kmeans_SP500_result_tbl %>% 
  select(-c(x,y)) %>% 
  filter(.cluster == cluster) %>% 
  count(sector) %>% 
  mutate(indus_prop = n/sum(n),
         indus_prop_text = indus_prop %>% scales::percent()) %>%
  arrange(desc(indus_prop)) %>% 
  select(sector, indus_prop, indus_prop_text) %>% head(3) %>% 
  mutate(sector_prop = str_c(sector, str_glue("({indus_prop_text})"))) 
  if(is.na(foo[2,]) == TRUE) {
  foo %>% mutate(sector_text = str_glue("{sector_prop[1]}")) %>% 
  select(sector_text) %>% distinct(sector_text) 
  } else if(is.na(foo[3,]) == TRUE) {
  foo %>% mutate(sector_text = str_glue("{sector_prop[1]}
                                {sector_prop[2]}")) %>% 
  select(sector_text) %>% distinct(sector_text)   
  } else{
   foo %>% mutate(sector_text = str_glue("{sector_prop[1]}
                                {sector_prop[2]}
                                {sector_prop[3]}")) %>% 
  select(sector_text) %>% distinct(sector_text)   
  }
}

cluster_indus <-  tibble(.cluster = 1:6)

industry_text_tbl <- cluster_indus %>% 
  mutate(indus = .cluster %>% map(indus_mapper)) %>% unnest(indus) %>% 
  mutate(.cluster = as.factor(.cluster))
```

``` r
umap_kmeans_SP500_result_tbl %>% 
  left_join(industry_text_tbl, by = ".cluster") %>% 
    ggplot(aes(x, y, colour = .cluster)) +
    geom_point(alpha = 0.5) +
    ggrepel::geom_label_repel(data  = . %>% 
                              mutate(label = ifelse(symbol %in% c("APA", "AEE", "VTRS", "DFS", "TER", "DAL"), sector_text, "")),
                                     aes(label = label), 
                              size = 3,
                              min.segment.length =  1,
                              max.overlaps = getOption("ggrepel.max.overlaps", default = 100), show.legend = FALSE, alpha = 0.7) + 
    theme_tq() +
    scale_colour_tq() 
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-16-1.png" width="672" />

``` r
get_kmeans <- function(k = 3) {
    
    k_means_obj <- k_means_mapped_tbl %>%
        filter(centers == k) %>%
        pull(k_means) %>%
        pluck(1)
    
    umap_kmeans_results_tbl <- k_means_obj %>% 
        augment(SP500_date_matrix_tbl) %>%
        select(symbol, .cluster) %>%
    left_join(umap_result_tbl, by = "symbol") %>% 
    left_join(SP500_index_tbl %>% select(symbol, company, sector), by = "symbol")
    
    return(umap_kmeans_results_tbl)
}

plot_cluster <- function(k = 3) {
    
    g <- get_kmeans(k) %>%
        
        mutate(label_text = str_glue("Stock: {symbol}
                                     Company: {company}
                                     Sector: {sector}")) %>%
        
        ggplot(aes(x, y, color = .cluster, text = label_text)) +
        geom_point(alpha = 0.5) +
        theme_tq() +
        scale_color_tq()
    
    g %>%
        ggplotly(tooltip = "text")
    
}
```

We can plot the clusters interactively.

``` r
plot_cluster(k = 6)
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"data":[{"x":[0.134799731195288,0.341271894294205,0.292700183141796,0.302823445612932,0.269475558306897,0.388786172638587,0.220127695969089,0.182558427286689,0.140894383076076,0.242689281294229,0.345024151830997,0.352661312722739],"y":[4.60744275155199,4.25839354948374,4.57589226615404,4.39948018149833,4.52231459571891,4.30414054514478,4.4966481460898,4.60335432066293,3.90793972381549,4.50530539347665,4.37314041211785,4.24884861644846],"text":["Stock: APA<br />Company: APA Corp.<br />Sector: Energy","Stock: COP<br />Company: ConocoPhillips<br />Sector: Energy","Stock: DVN<br />Company: Devon Energy Corporation<br />Sector: Energy","Stock: EOG<br />Company: EOG Resources Inc.<br />Sector: Energy","Stock: FANG<br />Company: Diamondback Energy Inc.<br />Sector: Energy","Stock: HAL<br />Company: Halliburton Company<br />Sector: Energy","Stock: HES<br />Company: Hess Corporation<br />Sector: Energy","Stock: MRO<br />Company: Marathon Oil Corporation<br />Sector: Energy","Stock: OKE<br />Company: ONEOK Inc.<br />Sector: Energy","Stock: OXY<br />Company: Occidental Petroleum Corporation<br />Sector: Energy","Stock: PXD<br />Company: Pioneer Natural Resources Company<br />Sector: Energy","Stock: SLB<br />Company: Schlumberger NV<br />Sector: Energy"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(44,62,80,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(44,62,80,1)"}},"hoveron":"points","name":"1","legendgroup":"1","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[-1.82642596671931,-0.784467412619473,0.217025197485669,-1.62532182209773,-1.29401654109762,3.21493537813435,3.19886032900083,-0.389707764929338,-0.831766906571953,2.09336908454726,-0.989860722223573,-0.553642525407314,2.11729736987895,3.27128325617956,-2.102370304729,3.19660760415156,-0.559608143934472,-0.706109634802079,-0.967941267884924,-1.65713966131866,-0.395797982248484,-0.714689241376358,-0.59368470833181,-0.682949519790911,-0.267359920327734,0.185125320301337,-0.844712118827257,2.12088168811374,-0.235787381159061,-0.42866987528137,-0.0525385102161895,-0.579289734055828,-0.474767458958387,-0.380146433531818,0.15287087848267,3.29449263151261,-0.256032677354451,-0.674571050186035,-0.253367352460266,-0.775298190182466,0.518953961300577,-0.553854888438902,0.255182073341959,3.18195487877412,-0.680629433041059,-1.13397338043873,-1.76581427081849,2.03952077740572,-0.589347409352815,-0.781200071734389,2.12904471529964,3.06782322190396,-0.22847297768145,-2.06398997844503,-0.916317459105201,3.30952773489576,-0.239715452123209,2.07572116641673,3.33161180472118,3.22027206323389,3.25558596387828,-1.7523311610103,-0.156742194636075,2.22336827886045,-0.546201176723804,2.9827572680239,-0.222575494193195,-0.224726693769018,-0.331946327386998,-0.320987592240204,-0.996180403092727,-1.02720036986002,-1.05553473377363,-0.454237660041358,-0.314543716641741,-0.503113642772914,-0.155426501586465,-0.0837702230492283,-0.416098560752824,0.0746672105846993,-0.348364879744688,0.686367319420408,-0.76481369113337,0.74832984362378,3.27287010348917,0.240527195299034,-0.412238352447884,-0.309117177452972,-1.17020365349167,-1.04279567681728,-1.44479749291422,0.0675981439653275,-0.593151907500643,-0.0200721394684211,-1.79187957785383,-1.06165511699941,3.1405050149542,-0.152516555075237,3.09900270612421,-0.133184768346037,0.705676908653051,-0.256565857661211,-0.236969344082441,-0.461973237100032,-0.294326308828565,0.19141705657225,-0.426095952929717,-0.652353198045293,-0.747480557661443,-0.0961438668250234,2.16683107455596,-0.178089850046261,-0.560114098014549,2.13968618202722,-0.545002880118211,-0.584557792951326,-0.677713168138483,-0.375216017122663,-0.210818368145832,2.06467907858842,-0.122111778964091,3.06772939755133,-0.185679133923113,0.365499330884424,-0.682070113255909,-1.7112236074955,-0.512982695069343,-0.480302265142649,-2.22658055293726,-0.28185037423573,-0.647397217298697,-2.52639092082536,-0.954014564486285,-0.227426782911796,-1.62544815928342,0.347604053439534,3.34260492541733,-1.0702255013158,0.164845830613968,-0.496465408058483,-1.52322391558413,3.09166121614832,-1.68812463309369],"y":[-1.89355156318703,-2.64976374256246,-1.84680027778367,-2.12849064128911,-2.34453846471403,-1.8213410244918,-1.80929059271203,-2.7998988718853,-2.91146690632823,-2.1315723701168,-1.20667570326423,-1.1828294813959,-1.86572937275692,-1.81324254775009,-2.67367963278512,-1.96763385986465,-2.68956608108262,-2.53818308153048,-2.8244495861723,-2.12518547239323,-2.10266073542299,-2.7110537062187,-1.79745689317645,-1.30551734214194,-3.64126736284307,-1.75087279007142,-1.7190211714119,-2.08188263660791,-2.65081129264772,-3.36530750009094,-2.40398673052777,-2.32151927000066,-2.82767907835685,-3.48976550850805,-1.05701471435903,-1.83307367746947,-1.40668484104149,-2.95940056408994,-3.6759796813919,-1.00973787776893,-0.465171080866443,-2.94942684219575,-1.98029732903598,-1.8983493009316,-3.07997974758019,-1.59047142543015,-2.04920469353052,-2.17306817736485,-2.01370133122406,-3.23184463366954,-1.94059440251719,-1.66292529024562,-1.78125090596947,-2.76535324110011,-2.60915491353916,-1.97062186162687,-1.39636655831332,-2.15258983931158,-1.92991680967613,-1.28904181905217,-1.71571067205148,0.307674952289522,-2.08407881091602,-1.85448206824038,-1.34467921022944,-1.66794529792781,-2.98493635124015,-3.72583741467524,-3.48154241886698,-2.0961627605606,-1.72106747401282,-2.82832865852799,-1.35836196849652,-2.11486820720107,-2.503900715137,-1.03435529977042,-3.67142855322235,-2.414904887467,-3.37899820934581,-1.12826623558088,-3.62132700745799,-0.991467963993,-2.76575295529336,-1.03596981822361,-1.79608423944118,-1.91202558560536,-2.26241771142332,-3.37308400012884,-1.80480491792334,-1.13717597313286,-2.40907154590357,-2.04296107460097,-2.52205037637149,-3.23445323917843,-1.91210576181394,-1.7345051700708,-1.94725535058785,-3.29248495117166,-1.41303040223055,-2.55388734176892,-1.07534989590127,-3.02700211428968,-3.09277019939324,-2.70733884200083,-0.761133520273276,-2.27020524512384,-2.12315956229442,-2.4773001894301,-2.76999079527623,-2.63634574675212,-1.99489587903247,-2.08792661919429,-1.12107994969676,-1.75466815079318,-2.98010412460264,-2.01824632554903,-2.58466181647274,-1.256921221572,-1.3529745859741,-2.13261222162865,-3.71286216167878,-1.75720578764584,-1.81469050846585,-0.652289006961088,-3.00933543282884,-2.06998490141838,-2.31648904295059,-3.18363924466642,-2.24887342295336,-2.61755811058044,-1.6791265786479,-2.01487709050885,-2.99079108084557,-2.61541567669382,-1.75620966887549,-1.84222907499614,-1.9180875144986,-1.17578183712442,-1.6501389798215,-3.21622730524985,-2.23111702099404,-2.0651391611021,-1.56927502102959],"text":["Stock: A<br />Company: Agilent Technologies Inc.<br />Sector: Health Care","Stock: ABBV<br />Company: AbbVie Inc.<br />Sector: Health Care","Stock: ABC<br />Company: AmerisourceBergen Corporation<br />Sector: Health Care","Stock: ABMD<br />Company: ABIOMED Inc.<br />Sector: Health Care","Stock: ABT<br />Company: Abbott Laboratories<br />Sector: Health Care","Stock: AEE<br />Company: Ameren Corporation<br />Sector: Utilities","Stock: AEP<br />Company: American Electric Power Company Inc.<br />Sector: Utilities","Stock: AKAM<br />Company: Akamai Technologies Inc.<br />Sector: Information Technology","Stock: AMGN<br />Company: Amgen Inc.<br />Sector: Health Care","Stock: AMT<br />Company: American Tower Corporation<br />Sector: Real Estate","Stock: AON<br />Company: Aon Plc Class A<br />Sector: Financials","Stock: APD<br />Company: Air Products and Chemicals Inc.<br />Sector: Materials","Stock: ARE<br />Company: Alexandria Real Estate Equities Inc.<br />Sector: Real Estate","Stock: ATO<br />Company: Atmos Energy Corporation<br />Sector: Utilities","Stock: ATVI<br />Company: Activision Blizzard Inc.<br />Sector: Communication Services","Stock: AWK<br />Company: American Water Works Company Inc.<br />Sector: Utilities","Stock: BAX<br />Company: Baxter International Inc.<br />Sector: Health Care","Stock: BDX<br />Company: Becton Dickinson and Company<br />Sector: Health Care","Stock: BIIB<br />Company: Biogen Inc.<br />Sector: Health Care","Stock: BIO<br />Company: Bio-Rad Laboratories Inc. Class A<br />Sector: Health Care","Stock: BLL<br />Company: Ball Corporation<br />Sector: Materials","Stock: BMY<br />Company: Bristol-Myers Squibb Company<br />Sector: Health Care","Stock: BR<br />Company: Broadridge Financial Solutions Inc.<br />Sector: Information Technology","Stock: BRO<br />Company: Brown & Brown Inc.<br />Sector: Financials","Stock: CAG<br />Company: Conagra Brands Inc.<br />Sector: Consumer Staples","Stock: CAH<br />Company: Cardinal Health Inc.<br />Sector: Health Care","Stock: CBOE<br />Company: Cboe Global Markets Inc<br />Sector: Financials","Stock: CCI<br />Company: Crown Castle International Corp<br />Sector: Real Estate","Stock: CERN<br />Company: Cerner Corporation<br />Sector: Health Care","Stock: CHD<br />Company: Church & Dwight Co. Inc.<br />Sector: Consumer Staples","Stock: CHRW<br />Company: C.H. Robinson Worldwide Inc.<br />Sector: Industrials","Stock: CHTR<br />Company: Charter Communications Inc. Class A<br />Sector: Communication Services","Stock: CL<br />Company: Colgate-Palmolive Company<br />Sector: Consumer Staples","Stock: CLX<br />Company: Clorox Company<br />Sector: Consumer Staples","Stock: CMCSA<br />Company: Comcast Corporation Class A<br />Sector: Communication Services","Stock: CMS<br />Company: CMS Energy Corporation<br />Sector: Utilities","Stock: COO<br />Company: Cooper Companies Inc.<br />Sector: Health Care","Stock: COST<br />Company: Costco Wholesale Corporation<br />Sector: Consumer Staples","Stock: CPB<br />Company: Campbell Soup Company<br />Sector: Consumer Staples","Stock: CSCO<br />Company: Cisco Systems Inc.<br />Sector: Information Technology","Stock: CTRA<br />Company: Coterra Energy Inc.<br />Sector: Energy","Stock: CTXS<br />Company: Citrix Systems Inc.<br />Sector: Information Technology","Stock: CVS<br />Company: CVS Health Corporation<br />Sector: Health Care","Stock: D<br />Company: Dominion Energy Inc<br />Sector: Utilities","Stock: DG<br />Company: Dollar General Corporation<br />Sector: Consumer Discretionary","Stock: DGX<br />Company: Quest Diagnostics Incorporated<br />Sector: Health Care","Stock: DHR<br />Company: Danaher Corporation<br />Sector: Health Care","Stock: DLR<br />Company: Digital Realty Trust Inc.<br />Sector: Real Estate","Stock: DLTR<br />Company: Dollar Tree Inc.<br />Sector: Consumer Discretionary","Stock: DPZ<br />Company: Domino's Pizza Inc.<br />Sector: Consumer Discretionary","Stock: DRE<br />Company: Duke Realty Corporation<br />Sector: Real Estate","Stock: DUK<br />Company: Duke Energy Corporation<br />Sector: Utilities","Stock: DVA<br />Company: DaVita Inc.<br />Sector: Health Care","Stock: EA<br />Company: Electronic Arts Inc.<br />Sector: Communication Services","Stock: EBAY<br />Company: eBay Inc.<br />Sector: Consumer Discretionary","Stock: ED<br />Company: Consolidated Edison Inc.<br />Sector: Utilities","Stock: EFX<br />Company: Equifax Inc.<br />Sector: Industrials","Stock: EQIX<br />Company: Equinix Inc.<br />Sector: Real Estate","Stock: ES<br />Company: Eversource Energy<br />Sector: Utilities","Stock: ETR<br />Company: Entergy Corporation<br />Sector: Utilities","Stock: EVRG<br />Company: Evergy Inc.<br />Sector: Utilities","Stock: EW<br />Company: Edwards Lifesciences Corporation<br />Sector: Health Care","Stock: EXPD<br />Company: Expeditors International of Washington Inc.<br />Sector: Industrials","Stock: EXR<br />Company: Extra Space Storage Inc.<br />Sector: Real Estate","Stock: FAST<br />Company: Fastenal Company<br />Sector: Industrials","Stock: FE<br />Company: FirstEnergy Corp.<br />Sector: Utilities","Stock: GILD<br />Company: Gilead Sciences Inc.<br />Sector: Health Care","Stock: GIS<br />Company: General Mills Inc.<br />Sector: Consumer Staples","Stock: HRL<br />Company: Hormel Foods Corporation<br />Sector: Consumer Staples","Stock: HSY<br />Company: Hershey Company<br />Sector: Consumer Staples","Stock: ICE<br />Company: Intercontinental Exchange Inc.<br />Sector: Financials","Stock: INCY<br />Company: Incyte Corporation<br />Sector: Health Care","Stock: INFO<br />Company: IHS Markit Ltd.<br />Sector: Industrials","Stock: JKHY<br />Company: Jack Henry & Associates Inc.<br />Sector: Information Technology","Stock: JNJ<br />Company: Johnson & Johnson<br />Sector: Health Care","Stock: JNPR<br />Company: Juniper Networks Inc.<br />Sector: Information Technology","Stock: K<br />Company: Kellogg Company<br />Sector: Consumer Staples","Stock: KHC<br />Company: Kraft Heinz Company<br />Sector: Consumer Staples","Stock: KMB<br />Company: Kimberly-Clark Corporation<br />Sector: Consumer Staples","Stock: KO<br />Company: Coca-Cola Company<br />Sector: Consumer Staples","Stock: KR<br />Company: Kroger Co.<br />Sector: Consumer Staples","Stock: LHX<br />Company: L3Harris Technologies Inc<br />Sector: Industrials","Stock: LLY<br />Company: Eli Lilly and Company<br />Sector: Health Care","Stock: LMT<br />Company: Lockheed Martin Corporation<br />Sector: Industrials","Stock: LNT<br />Company: Alliant Energy Corp<br />Sector: Utilities","Stock: MCK<br />Company: McKesson Corporation<br />Sector: Health Care","Stock: MDLZ<br />Company: Mondelez International Inc. Class A<br />Sector: Consumer Staples","Stock: MKC<br />Company: McCormick & Company Incorporated<br />Sector: Consumer Staples","Stock: MKTX<br />Company: MarketAxess Holdings Inc.<br />Sector: Financials","Stock: MMC<br />Company: Marsh & McLennan Companies Inc.<br />Sector: Financials","Stock: MNST<br />Company: Monster Beverage Corporation<br />Sector: Consumer Staples","Stock: MO<br />Company: Altria Group Inc<br />Sector: Consumer Staples","Stock: MRK<br />Company: Merck & Co. Inc.<br />Sector: Health Care","Stock: MRNA<br />Company: Moderna Inc.<br />Sector: Health Care","Stock: MTD<br />Company: Mettler-Toledo International Inc.<br />Sector: Health Care","Stock: NDAQ<br />Company: Nasdaq Inc.<br />Sector: Financials","Stock: NEE<br />Company: NextEra Energy Inc.<br />Sector: Utilities","Stock: NEM<br />Company: Newmont Corporation<br />Sector: Materials","Stock: NI<br />Company: NiSource Inc<br />Sector: Utilities","Stock: NLOK<br />Company: NortonLifeLock Inc.<br />Sector: Information Technology","Stock: NOC<br />Company: Northrop Grumman Corporation<br />Sector: Industrials","Stock: OGN<br />Company: Organon & Co.<br />Sector: Health Care","Stock: ONL<br />Company: Orion Office REIT Inc.<br />Sector: Real Estate","Stock: ORCL<br />Company: Oracle Corporation<br />Sector: Information Technology","Stock: ORLY<br />Company: O'Reilly Automotive Inc.<br />Sector: Consumer Discretionary","Stock: OTIS<br />Company: Otis Worldwide Corporation<br />Sector: Industrials","Stock: PEP<br />Company: PepsiCo Inc.<br />Sector: Consumer Staples","Stock: PFE<br />Company: Pfizer Inc.<br />Sector: Health Care","Stock: PG<br />Company: Procter & Gamble Company<br />Sector: Consumer Staples","Stock: PGR<br />Company: Progressive Corporation<br />Sector: Financials","Stock: PLD<br />Company: Prologis Inc.<br />Sector: Real Estate","Stock: PM<br />Company: Philip Morris International Inc.<br />Sector: Consumer Staples","Stock: POOL<br />Company: Pool Corporation<br />Sector: Consumer Discretionary","Stock: PSA<br />Company: Public Storage<br />Sector: Real Estate","Stock: REGN<br />Company: Regeneron Pharmaceuticals Inc.<br />Sector: Health Care","Stock: RMD<br />Company: ResMed Inc.<br />Sector: Health Care","Stock: ROL<br />Company: Rollins Inc.<br />Sector: Industrials","Stock: ROP<br />Company: Roper Technologies Inc.<br />Sector: Industrials","Stock: RSG<br />Company: Republic Services Inc.<br />Sector: Industrials","Stock: SBAC<br />Company: SBA Communications Corp. Class A<br />Sector: Real Estate","Stock: SJM<br />Company: J.M. Smucker Company<br />Sector: Consumer Staples","Stock: SO<br />Company: Southern Company<br />Sector: Utilities","Stock: STE<br />Company: STERIS Plc<br />Sector: Health Care","Stock: T<br />Company: AT&T Inc.<br />Sector: Communication Services","Stock: TGT<br />Company: Target Corporation<br />Sector: Consumer Discretionary","Stock: TMO<br />Company: Thermo Fisher Scientific Inc.<br />Sector: Health Care","Stock: TMUS<br />Company: T-Mobile US Inc.<br />Sector: Communication Services","Stock: TSCO<br />Company: Tractor Supply Company<br />Sector: Consumer Discretionary","Stock: TYL<br />Company: Tyler Technologies Inc.<br />Sector: Information Technology","Stock: UPS<br />Company: United Parcel Service Inc. Class B<br />Sector: Industrials","Stock: VRSK<br />Company: Verisk Analytics Inc<br />Sector: Industrials","Stock: VRSN<br />Company: VeriSign Inc.<br />Sector: Information Technology","Stock: VRTX<br />Company: Vertex Pharmaceuticals Incorporated<br />Sector: Health Care","Stock: VZ<br />Company: Verizon Communications Inc.<br />Sector: Communication Services","Stock: WAT<br />Company: Waters Corporation<br />Sector: Health Care","Stock: WBA<br />Company: Walgreens Boots Alliance Inc<br />Sector: Consumer Staples","Stock: WEC<br />Company: WEC Energy Group Inc<br />Sector: Utilities","Stock: WLTW<br />Company: Willis Towers Watson Public Limited Company<br />Sector: Financials","Stock: WM<br />Company: Waste Management Inc.<br />Sector: Industrials","Stock: WMT<br />Company: Walmart Inc.<br />Sector: Consumer Staples","Stock: WST<br />Company: West Pharmaceutical Services Inc.<br />Sector: Health Care","Stock: XEL<br />Company: Xcel Energy Inc.<br />Sector: Utilities","Stock: ZTS<br />Company: Zoetis Inc. Class A<br />Sector: Health Care"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(227,26,28,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(227,26,28,1)"}},"hoveron":"points","name":"2","legendgroup":"2","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[-0.350797750327176,-1.39938208954072,0.292098331191462,-0.797554300414809,2.48198607190504,1.46553901461107,-0.789025044764744,-0.266218348772032,0.424222930140578,0.0868736582290106,-0.684630008350724,-0.776312699238535,0.830132529403941,-0.177900004240313,-1.25540485249207,3.1378390985673,-0.209088689181311,-0.470203816964702,-0.541432760153034,0.867235264755472,1.15738996760599,-0.537440389531508,-1.61622336528996,-0.283976110126376,0.228951372724565,-0.183704189997072,1.50859106849959,-1.4056411213558,0.928594806430937,1.44987160285177,-0.849267282436995,-0.0587261369604604,0.883888062195006,3.09266027709482,-0.906723126040798,-0.826755930996083,-0.397115617610571,-1.05324550016912,-0.563220413778756,0.0165584627052136,-0.354847473910981,-1.42929039134099,-0.603917113741612,-0.191012277423984,2.75517278045474,-0.230086390127385,3.19146125137184,-1.17799892651045,-0.0761882521928201,3.21051008548259,3.11643484549218,-0.186261880089103,3.01733198968461,-1.13142654674853,-0.844970181796762,-0.754291484280762,-1.95038452893883,-2.0110749282369,-2.09930898751857,-0.917354692947999,0.822260647069409,0.856633436145347,1.16128992201253,-0.15153778668692,0.540904311195991,-0.78375573687211,0.0296393829062511,-2.05063588920305,-1.32046513785237,-0.311200783502927,-0.935824177712351,-0.73216205132548,-0.650972188479187,0.645458290252423,0.387773639878077,0.40517057516647,-0.981004546530976,0.504651047954052,0.952397177730981,0.315434245406222,-0.30925792239871,-0.173535532963518,0.739814177584651,-1.63378793993284,-0.144884052225133,1.05197519266595,-1.10320776533196,-0.036117270991967,0.166769191690026,-0.694965183981636,0.100167563780146,0.0358688200060349,-0.756819836262143,0.453312751211907,-1.40506494650162,-1.24174872472416,-1.07063369932779,-0.701560516711702,0.481043958170933,-1.92751277601653,3.05495141882488,-0.704447224279227,-1.04086240486802,-1.70057416142446,-1.64110579249433,-0.141220752339858,0.041044387180281,-0.0885361366347852,-1.02109728717215,0.861655196121649,2.79050837984361,-0.629486713801442,-0.417596539980652,0.167772867727711,-1.4331475519182,0.242459744371601,0.627473980021369,0.69448577127339,2.97573112426676,-1.12067763466546,0.889017810178849,-1.00464278491292,-0.0761036569917333,3.07924866307893,2.97357893490073,-1.43995582496468,0.730561382292285,-0.0473623974060429,3.03882217042043,-0.470097428408501,3.15529196529509,-0.124544441822515,1.48912572459772,0.400316480897431,-0.15968703436415,1.11017657663767,-1.24192331154166,-0.643520401222968,-0.750792690320987,0.340707127054112,-1.76526641485973,3.12210063948817,-0.935129983817975,0.108072177911543,-0.304286638066297,-1.69943184131896,0.521234920716682,0.124246950796475,-0.606228263576722,-1.79407308663014,0.96840750894282,-1.46964124327344,-0.223646374574821,1.63967894823339,0.908695019789565,0.0219041244792004,3.1149181502968,0.928885016011943,-0.736715461982953,-2.00233894082023,-0.287918326572163,0.0984227587291939,-0.191924348971159,1.53720106621882,0.476383466966861,0.421604853446268,0.0428950821451806,-1.24562465973807,-1.67421771305767],"y":[-0.488326870667205,-0.631388580680698,0.397820972328628,-0.669833775730929,-0.548587835740061,0.453834886314802,-1.14699214703093,0.774332327486149,-0.310034213893701,0.319656569872728,0.608891137916257,0.553041838687698,-1.75780362728746,0.574100366665106,-0.0702977778392342,0.194342215066382,0.624682451245153,-0.520628337377449,0.0341254302035461,2.3137918226101,3.30154354044286,0.28796525722523,0.534940350730842,1.1640248100264,-2.17322917312374,1.0200581735544,0.47251683298734,-0.199759672357915,-1.77924934524632,0.763327487134865,-1.51076110428707,0.970496588244595,-1.84417521365767,-1.34047315215457,0.374444667568733,0.704228749186835,0.817478781997552,-0.014729664210116,0.594971736486403,1.58526825084618,0.995760748812195,1.2746885771483,0.688319571959368,1.21725641763183,-0.793640886063504,0.191027469190307,-1.46215336831144,0.0342766982299894,1.88018139719058,0.302120469195152,0.183722321250247,1.57548033628449,-1.3740752148917,1.20859068210842,0.370602237212608,-0.836401939181662,-0.00973231370763905,0.0609941846545801,0.0916611836740411,1.39928822968566,0.743449499942779,0.762327871489039,3.35417950499376,1.31977996855403,0.148709623254127,0.583351409249522,1.03121392407154,0.0525938986528607,-0.675332218923056,-0.151495361163903,-0.222604425259038,1.58615296767411,-0.520607240564242,-0.461763326568082,1.33528762233018,1.18708702840253,0.491161998639774,0.0802258786151384,-1.87952337574818,-0.40649260206819,0.0731989699428968,-0.615671882526488,2.18367852217176,-1.23560447497983,1.43568335467495,-0.62720917307108,-0.139783718455424,0.57245285966652,0.701763454563676,0.365920970356231,1.01696726405564,0.974290976131426,0.884398881983762,-0.893058933655251,1.34179333292635,-1.0242033795459,-0.663574817699297,-0.151357062476249,-0.213810428704249,-0.0433210472315617,-0.0872650948276441,0.120797416719493,-0.182533115289363,-1.14542205714443,0.346763255292169,1.65338665259583,-0.0848756602796497,-1.20468188131037,0.284437641038851,1.36293879868094,-0.867314430137038,0.96838924414009,0.0401835840040354,2.18114363029227,1.24392091389818,1.28584762192003,0.558867061696485,0.578721453833884,0.1292046992587,0.00144222160526075,0.722378629805533,-0.503587266336921,0.597510026806337,0.133623615749994,-1.19922355464149,1.34211744289999,0.767910738413732,0.966693582214721,-1.34109758181554,1.51461292572268,-1.42510290861386,1.30180892907919,0.469498242461575,0.882751754955442,1.47893570224329,1.65488102432321,-0.010614713092217,1.37537061812443,-0.509035204997857,0.893685270503933,-1.19635271646077,-1.45883112893289,-0.70007551835371,-0.252637752532962,1.69164511863463,0.477474415669025,-0.241146861262623,1.62386969164474,1.81335284100239,0.457322082712401,1.57691017446017,0.112902760594685,0.275715299416896,0.336673984850262,0.0588122845216219,1.20181489227809,0.203131356636014,-1.77960448395174,1.1832276762459,0.0231739457607332,1.66836922444517,-0.598013863783111,0.727133520300526,0.496360286490738,-0.661988058306157,0.0438510815516062,0.854082276692554,-0.202285971277763,0.563952990475311],"text":["Stock: AAP<br />Company: Advance Auto Parts Inc.<br />Sector: Consumer Discretionary","Stock: ACN<br />Company: Accenture Plc Class A<br />Sector: Information Technology","Stock: ADM<br />Company: Archer-Daniels-Midland Company<br />Sector: Consumer Staples","Stock: ADP<br />Company: Automatic Data Processing Inc.<br />Sector: Information Technology","Stock: AES<br />Company: AES Corporation<br />Sector: Utilities","Stock: AIZ<br />Company: Assurant Inc.<br />Sector: Financials","Stock: AJG<br />Company: Arthur J. Gallagher & Co.<br />Sector: Financials","Stock: ALB<br />Company: Albemarle Corporation<br />Sector: Materials","Stock: ALL<br />Company: Allstate Corporation<br />Sector: Financials","Stock: ALLE<br />Company: Allegion PLC<br />Sector: Industrials","Stock: AMCR<br />Company: Amcor PLC<br />Sector: Materials","Stock: AME<br />Company: AMETEK Inc.<br />Sector: Industrials","Stock: ANTM<br />Company: Anthem Inc.<br />Sector: Health Care","Stock: AOS<br />Company: A. O. Smith Corporation<br />Sector: Industrials","Stock: APH<br />Company: Amphenol Corporation Class A<br />Sector: Information Technology","Stock: AVB<br />Company: AvalonBay Communities Inc.<br />Sector: Real Estate","Stock: AVY<br />Company: Avery Dennison Corporation<br />Sector: Materials","Stock: AZO<br />Company: AutoZone Inc.<br />Sector: Consumer Discretionary","Stock: BBY<br />Company: Best Buy Co. Inc.<br />Sector: Consumer Discretionary","Stock: BEN<br />Company: Franklin Resources Inc.<br />Sector: Financials","Stock: BK<br />Company: Bank of New York Mellon Corporation<br />Sector: Financials","Stock: BLK<br />Company: BlackRock Inc.<br />Sector: Financials","Stock: BSX<br />Company: Boston Scientific Corporation<br />Sector: Health Care","Stock: BWA<br />Company: BorgWarner Inc.<br />Sector: Consumer Discretionary","Stock: CARR<br />Company: Carrier Global Corp.<br />Sector: Industrials","Stock: CAT<br />Company: Caterpillar Inc.<br />Sector: Industrials","Stock: CB<br />Company: Chubb Limited<br />Sector: Financials","Stock: CDW<br />Company: CDW Corp.<br />Sector: Information Technology","Stock: CI<br />Company: Cigna Corporation<br />Sector: Health Care","Stock: CINF<br />Company: Cincinnati Financial Corporation<br />Sector: Financials","Stock: CME<br />Company: CME Group Inc. Class A<br />Sector: Financials","Stock: CMI<br />Company: Cummins Inc.<br />Sector: Industrials","Stock: CNC<br />Company: Centene Corporation<br />Sector: Health Care","Stock: CNP<br />Company: CenterPoint Energy Inc.<br />Sector: Utilities","Stock: CPRT<br />Company: Copart Inc.<br />Sector: Industrials","Stock: CSX<br />Company: CSX Corporation<br />Sector: Industrials","Stock: CTAS<br />Company: Cintas Corporation<br />Sector: Industrials","Stock: CTSH<br />Company: Cognizant Technology Solutions Corporation Class A<br />Sector: Information Technology","Stock: CTVA<br />Company: Corteva Inc<br />Sector: Materials","Stock: DD<br />Company: DuPont de Nemours Inc.<br />Sector: Materials","Stock: DE<br />Company: Deere & Company<br />Sector: Industrials","Stock: DHI<br />Company: D.R. Horton Inc.<br />Sector: Consumer Discretionary","Stock: DIS<br />Company: Walt Disney Company<br />Sector: Communication Services","Stock: DOV<br />Company: Dover Corporation<br />Sector: Industrials","Stock: DTE<br />Company: DTE Energy Company<br />Sector: Utilities","Stock: ECL<br />Company: Ecolab Inc.<br />Sector: Materials","Stock: EIX<br />Company: Edison International<br />Sector: Utilities","Stock: EL<br />Company: Estee Lauder Companies Inc. Class A<br />Sector: Consumer Staples","Stock: EMR<br />Company: Emerson Electric Co.<br />Sector: Industrials","Stock: EQR<br />Company: Equity Residential<br />Sector: Real Estate","Stock: ESS<br />Company: Essex Property Trust Inc.<br />Sector: Real Estate","Stock: ETN<br />Company: Eaton Corp. Plc<br />Sector: Industrials","Stock: EXC<br />Company: Exelon Corporation<br />Sector: Utilities","Stock: FBHS<br />Company: Fortune Brands Home & Security Inc.<br />Sector: Industrials","Stock: FDX<br />Company: FedEx Corporation<br />Sector: Industrials","Stock: FFIV<br />Company: F5 Inc.<br />Sector: Information Technology","Stock: FIS<br />Company: Fidelity National Information Services Inc.<br />Sector: Information Technology","Stock: FISV<br />Company: Fiserv Inc.<br />Sector: Information Technology","Stock: FLT<br />Company: FLEETCOR Technologies Inc.<br />Sector: Information Technology","Stock: FMC<br />Company: FMC Corporation<br />Sector: Materials","Stock: FOX<br />Company: Fox Corporation Class B<br />Sector: Communication Services","Stock: FOXA<br />Company: Fox Corporation Class A<br />Sector: Communication Services","Stock: FRC<br />Company: First Republic Bank<br />Sector: Financials","Stock: FTV<br />Company: Fortive Corp.<br />Sector: Industrials","Stock: GD<br />Company: General Dynamics Corporation<br />Sector: Industrials","Stock: GLW<br />Company: Corning Inc<br />Sector: Information Technology","Stock: GPC<br />Company: Genuine Parts Company<br />Sector: Consumer Discretionary","Stock: GPN<br />Company: Global Payments Inc.<br />Sector: Information Technology","Stock: GRMN<br />Company: Garmin Ltd.<br />Sector: Consumer Discretionary","Stock: GWW<br />Company: W.W. Grainger Inc.<br />Sector: Industrials","Stock: HAS<br />Company: Hasbro Inc.<br />Sector: Consumer Discretionary","Stock: HCA<br />Company: HCA Healthcare Inc<br />Sector: Health Care","Stock: HD<br />Company: Home Depot Inc.<br />Sector: Consumer Discretionary","Stock: HII<br />Company: Huntington Ingalls Industries Inc.<br />Sector: Industrials","Stock: HON<br />Company: Honeywell International Inc.<br />Sector: Industrials","Stock: HPE<br />Company: Hewlett Packard Enterprise Co.<br />Sector: Information Technology","Stock: HPQ<br />Company: HP Inc.<br />Sector: Information Technology","Stock: HSIC<br />Company: Henry Schein Inc.<br />Sector: Health Care","Stock: HUM<br />Company: Humana Inc.<br />Sector: Health Care","Stock: IBM<br />Company: International Business Machines Corporation<br />Sector: Information Technology","Stock: IEX<br />Company: IDEX Corporation<br />Sector: Industrials","Stock: IFF<br />Company: International Flavors & Fragrances Inc.<br />Sector: Materials","Stock: IP<br />Company: International Paper Company<br />Sector: Materials","Stock: IQV<br />Company: IQVIA Holdings Inc<br />Sector: Health Care","Stock: IR<br />Company: Ingersoll Rand Inc.<br />Sector: Industrials","Stock: IRM<br />Company: Iron Mountain Inc.<br />Sector: Real Estate","Stock: IT<br />Company: Gartner Inc.<br />Sector: Information Technology","Stock: ITW<br />Company: Illinois Tool Works Inc.<br />Sector: Industrials","Stock: J<br />Company: Jacobs Engineering Group Inc.<br />Sector: Industrials","Stock: JBHT<br />Company: J.B. Hunt Transport Services Inc.<br />Sector: Industrials","Stock: JCI<br />Company: Johnson Controls International plc<br />Sector: Industrials","Stock: KMX<br />Company: CarMax Inc.<br />Sector: Consumer Discretionary","Stock: KSU<br />Company: Kansas City Southern<br />Sector: Industrials","Stock: LDOS<br />Company: Leidos Holdings Inc.<br />Sector: Industrials","Stock: LEN<br />Company: Lennar Corporation Class A<br />Sector: Consumer Discretionary","Stock: LH<br />Company: Laboratory Corporation of America Holdings<br />Sector: Health Care","Stock: LIN<br />Company: Linde plc<br />Sector: Materials","Stock: LOW<br />Company: Lowe's Companies Inc.<br />Sector: Consumer Discretionary","Stock: LUMN<br />Company: Lumen Technologies Inc.<br />Sector: Communication Services","Stock: MA<br />Company: Mastercard Incorporated Class A<br />Sector: Information Technology","Stock: MAA<br />Company: Mid-America Apartment Communities Inc.<br />Sector: Real Estate","Stock: MAS<br />Company: Masco Corporation<br />Sector: Industrials","Stock: MCD<br />Company: McDonald's Corporation<br />Sector: Consumer Discretionary","Stock: MCO<br />Company: Moody's Corporation<br />Sector: Financials","Stock: MDT<br />Company: Medtronic Plc<br />Sector: Health Care","Stock: MLM<br />Company: Martin Marietta Materials Inc.<br />Sector: Materials","Stock: MMM<br />Company: 3M Company<br />Sector: Industrials","Stock: MSI<br />Company: Motorola Solutions Inc.<br />Sector: Information Technology","Stock: NKE<br />Company: NIKE Inc. Class B<br />Sector: Consumer Discretionary","Stock: NLSN<br />Company: Nielsen Holdings Plc<br />Sector: Industrials","Stock: NRG<br />Company: NRG Energy Inc.<br />Sector: Utilities","Stock: NSC<br />Company: Norfolk Southern Corporation<br />Sector: Industrials","Stock: NTAP<br />Company: NetApp Inc.<br />Sector: Information Technology","Stock: NUE<br />Company: Nucor Corporation<br />Sector: Materials","Stock: NVR<br />Company: NVR Inc.<br />Sector: Consumer Discretionary","Stock: NWL<br />Company: Newell Brands Inc<br />Sector: Consumer Discretionary","Stock: NWS<br />Company: News Corporation Class B<br />Sector: Communication Services","Stock: NWSA<br />Company: News Corporation Class A<br />Sector: Communication Services","Stock: O<br />Company: Realty Income Corporation<br />Sector: Real Estate","Stock: ODFL<br />Company: Old Dominion Freight Line Inc.<br />Sector: Industrials","Stock: OMC<br />Company: Omnicom Group Inc<br />Sector: Communication Services","Stock: PAYX<br />Company: Paychex Inc.<br />Sector: Information Technology","Stock: PCAR<br />Company: PACCAR Inc<br />Sector: Industrials","Stock: PEAK<br />Company: Healthpeak Properties Inc.<br />Sector: Real Estate","Stock: PEG<br />Company: Public Service Enterprise Group Inc<br />Sector: Utilities","Stock: PHM<br />Company: PulteGroup Inc.<br />Sector: Consumer Discretionary","Stock: PKG<br />Company: Packaging Corporation of America<br />Sector: Materials","Stock: PNR<br />Company: Pentair plc<br />Sector: Industrials","Stock: PNW<br />Company: Pinnacle West Capital Corporation<br />Sector: Utilities","Stock: PPG<br />Company: PPG Industries Inc.<br />Sector: Materials","Stock: PPL<br />Company: PPL Corporation<br />Sector: Utilities","Stock: PWR<br />Company: Quanta Services Inc.<br />Sector: Industrials","Stock: RE<br />Company: Everest Re Group Ltd.<br />Sector: Financials","Stock: RHI<br />Company: Robert Half International Inc.<br />Sector: Industrials","Stock: ROK<br />Company: Rockwell Automation Inc.<br />Sector: Industrials","Stock: ROST<br />Company: Ross Stores Inc.<br />Sector: Consumer Discretionary","Stock: SBUX<br />Company: Starbucks Corporation<br />Sector: Consumer Discretionary","Stock: SEE<br />Company: Sealed Air Corporation<br />Sector: Materials","Stock: SHW<br />Company: Sherwin-Williams Company<br />Sector: Materials","Stock: SNA<br />Company: Snap-on Incorporated<br />Sector: Industrials","Stock: SPGI<br />Company: S&P Global Inc.<br />Sector: Financials","Stock: SRE<br />Company: Sempra Energy<br />Sector: Utilities","Stock: STX<br />Company: Seagate Technology Holdings PLC<br />Sector: Information Technology","Stock: STZ<br />Company: Constellation Brands Inc. Class A<br />Sector: Consumer Staples","Stock: SWK<br />Company: Stanley Black & Decker Inc.<br />Sector: Industrials","Stock: SYK<br />Company: Stryker Corporation<br />Sector: Health Care","Stock: TAP<br />Company: Molson Coors Beverage Company Class B<br />Sector: Consumer Staples","Stock: TDY<br />Company: Teledyne Technologies Incorporated<br />Sector: Information Technology","Stock: TEL<br />Company: TE Connectivity Ltd.<br />Sector: Information Technology","Stock: TFX<br />Company: Teleflex Incorporated<br />Sector: Health Care","Stock: TJX<br />Company: TJX Companies Inc<br />Sector: Consumer Discretionary","Stock: TRMB<br />Company: Trimble Inc.<br />Sector: Information Technology","Stock: TROW<br />Company: T. Rowe Price Group<br />Sector: Financials","Stock: TRV<br />Company: Travelers Companies Inc.<br />Sector: Financials","Stock: TSN<br />Company: Tyson Foods Inc. Class A<br />Sector: Consumer Staples","Stock: TT<br />Company: Trane Technologies plc<br />Sector: Industrials","Stock: UDR<br />Company: UDR Inc.<br />Sector: Real Estate","Stock: UNH<br />Company: UnitedHealth Group Incorporated<br />Sector: Health Care","Stock: UNP<br />Company: Union Pacific Corporation<br />Sector: Industrials","Stock: V<br />Company: Visa Inc. Class A<br />Sector: Information Technology","Stock: VMC<br />Company: Vulcan Materials Company<br />Sector: Materials","Stock: VTRS<br />Company: Viatris Inc.<br />Sector: Health Care","Stock: WHR<br />Company: Whirlpool Corporation<br />Sector: Consumer Discretionary","Stock: WRB<br />Company: W. R. Berkley Corporation<br />Sector: Financials","Stock: WU<br />Company: Western Union Company<br />Sector: Information Technology","Stock: XRAY<br />Company: DENTSPLY SIRONA Inc.<br />Sector: Health Care","Stock: XYL<br />Company: Xylem Inc.<br />Sector: Industrials","Stock: YUM<br />Company: Yum! Brands Inc.<br />Sector: Consumer Discretionary","Stock: ZBH<br />Company: Zimmer Biomet Holdings Inc.<br />Sector: Health Care"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(24,188,156,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(24,188,156,1)"}},"hoveron":"points","name":"3","legendgroup":"3","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[1.3241880098061,1.71249043272027,1.43558358372915,-0.32445770595469,1.83877484759886,2.05376547981354,1.3155182593591,0.0267359222143098,2.15302423603951,0.439896639686463,3.16244488396837,1.70912611042022,0.304741223180544,-0.00973107078034641,0.0526082803386534,1.97879376539107,1.90236618395969,2.02858208755047,0.391421254657038,2.10989104382511,1.00837971733981,1.08275531030066,-0.655393380520532,0.509930205227628,1.87892922852317,1.96621452886777,0.173610830972756,2.25278519294293,0.574396690992393,0.0391306611520461,1.88960149254264,3.03883087937066,1.10822970515937,1.08384477220054,0.216034829172238,1.24814035096295,0.978374431821512,1.61736525773156,0.419616944726395,1.69810663392473,2.13070038582273,2.42494541067136,1.72824040847115,1.15562796574962,1.31649412025064,1.33795661423822,1.91512627904786,3.00976502841586,0.20157932572329,1.07339560229414,0.354735570771603,-0.0187534645977143,1.85702763125023,2.42347357934859,2.08341563412446,1.1993846389092,0.520824445056977,2.32049932837617,2.29881164022279,1.38525454846856,0.208787567422353,-0.00568228584722652,0.786565823053216,1.16580422332412,1.47189990352993,1.09620475291189,1.51481509118675,1.74183737975286,0.0864839439988174,1.40540948073281,1.47489829392799,0.652350981600674,1.45960788252742,3.05747552851814,1.89612227767904,1.26116302784357,1.17020775180942,1.27100553744836,1.28374479007697,1.29731509221944,3.08175762497105,1.19422749884232,2.04276361765329,1.59940625383121,1.35012365922426,1.62589112584116,1.20679094993069,1.53684583736663,-0.0857322950784862,0.033993377712187,-0.733644182841331,1.16752738711981,-0.0728690044716309,1.45715927924318,0.961837740579902,1.0365140355744,0.810558082255795,3.11905410024776,3.01826015222685,-0.22224605726699,-3.83772958780265,3.0491105272407,1.53813401415991,0.121236892808146,0.777687042370721,0.213129479809593,0.505439455349547,1.5834844930252],"y":[2.06725925431851,2.87652000741919,3.06588303905199,2.09523498440443,2.72204752612082,2.5099951275553,3.35536892554539,1.99877333800381,1.79377899695892,4.08527233367331,0.611410909176292,3.4876153455457,1.70314194616603,2.13917923106081,2.45353372888528,3.854040330879,3.90272409369378,3.33342045587699,3.8640165480156,3.29046611960949,0.886679641514798,0.954614388602041,1.17481687506473,2.3654109066027,2.30667116085818,3.74677710672238,2.18157366885195,1.98371521316298,2.22637271004846,2.15701047252002,3.73877491858749,0.799668350635284,2.67552490354497,2.66851230175455,2.0222644188332,2.78329619383043,3.37470588185622,3.82847265544337,0.914078375034073,0.862339805385807,1.82680538052193,1.64521312476814,2.66199900089276,1.45293195487052,3.02728125123494,3.32694554620152,3.8221705562326,0.866678540128363,3.76112394484738,2.56731855747162,1.7338016910609,1.42928984727389,3.1359746091926,2.39335651701193,1.94896622972341,0.432106253397994,2.36718438813803,1.91780259990721,2.01384955788362,2.89366951699547,1.76124918819646,2.5444307121245,3.93310236306533,3.21682199959398,3.86726177061898,3.26469907129398,3.86053420013254,2.75169821623976,2.00339765379871,3.65530935246328,2.98282878208795,4.03788758798745,2.8870155381788,0.783811451297554,3.85065795998263,3.02013264888335,2.64490051937247,1.89466570079036,3.19835717863367,3.5824449624094,0.930417200643122,3.22016682917765,3.28659749720438,2.11547792413208,1.95615605650459,3.70969475486472,2.74393989266458,2.89057853841561,2.55981892069808,2.65517953054053,1.65514724543717,1.75229197664993,1.92721396893663,3.68789985040149,2.87283317194549,1.06783711545442,3.99821298114193,0.767609241338849,0.640474510844315,1.96657417711633,-0.708464771531868,0.547401491797547,3.57380796132535,3.69879820756705,2.4038447602629,1.51388607491315,3.95095552905884,3.9387425246208],"text":["Stock: AFL<br />Company: Aflac Incorporated<br />Sector: Financials","Stock: AIG<br />Company: American International Group Inc.<br />Sector: Financials","Stock: AMP<br />Company: Ameriprise Financial Inc.<br />Sector: Financials","Stock: APTV<br />Company: Aptiv PLC<br />Sector: Consumer Discretionary","Stock: AXP<br />Company: American Express Company<br />Sector: Financials","Stock: BA<br />Company: Boeing Company<br />Sector: Industrials","Stock: BAC<br />Company: Bank of America Corp<br />Sector: Financials","Stock: BBWI<br />Company: Bath & Body Works Inc.<br />Sector: Consumer Discretionary","Stock: BKNG<br />Company: Booking Holdings Inc.<br />Sector: Consumer Discretionary","Stock: BKR<br />Company: Baker Hughes Company Class A<br />Sector: Energy","Stock: BXP<br />Company: Boston Properties Inc.<br />Sector: Real Estate","Stock: C<br />Company: Citigroup Inc.<br />Sector: Financials","Stock: CBRE<br />Company: CBRE Group Inc. Class A<br />Sector: Real Estate","Stock: CE<br />Company: Celanese Corporation<br />Sector: Materials","Stock: CF<br />Company: CF Industries Holdings Inc.<br />Sector: Materials","Stock: CFG<br />Company: Citizens Financial Group Inc.<br />Sector: Financials","Stock: CMA<br />Company: Comerica Incorporated<br />Sector: Financials","Stock: COF<br />Company: Capital One Financial Corporation<br />Sector: Financials","Stock: CVX<br />Company: Chevron Corporation<br />Sector: Energy","Stock: DFS<br />Company: Discover Financial Services<br />Sector: Financials","Stock: DISCA<br />Company: Discovery Inc. Class A<br />Sector: Communication Services","Stock: DISCK<br />Company: Discovery Inc. Class C<br />Sector: Communication Services","Stock: DISH<br />Company: DISH Network Corporation Class A<br />Sector: Communication Services","Stock: DOW<br />Company: Dow Inc.<br />Sector: Materials","Stock: DRI<br />Company: Darden Restaurants Inc.<br />Sector: Consumer Discretionary","Stock: DXC<br />Company: DXC Technology Co.<br />Sector: Information Technology","Stock: EMN<br />Company: Eastman Chemical Company<br />Sector: Materials","Stock: EXPE<br />Company: Expedia Group Inc.<br />Sector: Consumer Discretionary","Stock: F<br />Company: Ford Motor Company<br />Sector: Consumer Discretionary","Stock: FCX<br />Company: Freeport-McMoRan Inc.<br />Sector: Materials","Stock: FITB<br />Company: Fifth Third Bancorp<br />Sector: Financials","Stock: FRT<br />Company: Federal Realty Investment Trust<br />Sector: Real Estate","Stock: GE<br />Company: General Electric Company<br />Sector: Industrials","Stock: GL<br />Company: Globe Life Inc.<br />Sector: Financials","Stock: GM<br />Company: General Motors Company<br />Sector: Consumer Discretionary","Stock: GPS<br />Company: Gap Inc.<br />Sector: Consumer Discretionary","Stock: GS<br />Company: Goldman Sachs Group Inc.<br />Sector: Financials","Stock: HBAN<br />Company: Huntington Bancshares Incorporated<br />Sector: Financials","Stock: HBI<br />Company: Hanesbrands Inc.<br />Sector: Consumer Discretionary","Stock: HIG<br />Company: Hartford Financial Services Group Inc.<br />Sector: Financials","Stock: HLT<br />Company: Hilton Worldwide Holdings Inc<br />Sector: Consumer Discretionary","Stock: HST<br />Company: Host Hotels & Resorts Inc.<br />Sector: Real Estate","Stock: HWM<br />Company: Howmet Aerospace Inc.<br />Sector: Industrials","Stock: IPG<br />Company: Interpublic Group of Companies Inc.<br />Sector: Communication Services","Stock: IVZ<br />Company: Invesco Ltd.<br />Sector: Financials","Stock: JPM<br />Company: JPMorgan Chase & Co.<br />Sector: Financials","Stock: KEY<br />Company: KeyCorp<br />Sector: Financials","Stock: KIM<br />Company: Kimco Realty Corporation<br />Sector: Real Estate","Stock: KMI<br />Company: Kinder Morgan Inc Class P<br />Sector: Energy","Stock: L<br />Company: Loews Corporation<br />Sector: Financials","Stock: LEG<br />Company: Leggett & Platt Incorporated<br />Sector: Consumer Discretionary","Stock: LKQ<br />Company: LKQ Corporation<br />Sector: Consumer Discretionary","Stock: LNC<br />Company: Lincoln National Corporation<br />Sector: Financials","Stock: LUV<br />Company: Southwest Airlines Co.<br />Sector: Industrials","Stock: LVS<br />Company: Las Vegas Sands Corp.<br />Sector: Consumer Discretionary","Stock: LW<br />Company: Lamb Weston Holdings Inc.<br />Sector: Consumer Staples","Stock: LYB<br />Company: LyondellBasell Industries NV<br />Sector: Materials","Stock: LYV<br />Company: Live Nation Entertainment Inc.<br />Sector: Communication Services","Stock: MAR<br />Company: Marriott International Inc. Class A<br />Sector: Consumer Discretionary","Stock: MET<br />Company: MetLife Inc.<br />Sector: Financials","Stock: MHK<br />Company: Mohawk Industries Inc.<br />Sector: Consumer Discretionary","Stock: MOS<br />Company: Mosaic Company<br />Sector: Materials","Stock: MPC<br />Company: Marathon Petroleum Corporation<br />Sector: Energy","Stock: MS<br />Company: Morgan Stanley<br />Sector: Financials","Stock: MTB<br />Company: M&T Bank Corporation<br />Sector: Financials","Stock: NTRS<br />Company: Northern Trust Corporation<br />Sector: Financials","Stock: PBCT<br />Company: People's United Financial Inc.<br />Sector: Financials","Stock: PFG<br />Company: Principal Financial Group Inc.<br />Sector: Financials","Stock: PH<br />Company: Parker-Hannifin Corporation<br />Sector: Industrials","Stock: PNC<br />Company: PNC Financial Services Group Inc.<br />Sector: Financials","Stock: PRU<br />Company: Prudential Financial Inc.<br />Sector: Financials","Stock: PSX<br />Company: Phillips 66<br />Sector: Energy","Stock: PVH<br />Company: PVH Corp.<br />Sector: Consumer Discretionary","Stock: REG<br />Company: Regency Centers Corporation<br />Sector: Real Estate","Stock: RF<br />Company: Regions Financial Corporation<br />Sector: Financials","Stock: RJF<br />Company: Raymond James Financial Inc.<br />Sector: Financials","Stock: RL<br />Company: Ralph Lauren Corporation Class A<br />Sector: Consumer Discretionary","Stock: RTX<br />Company: Raytheon Technologies Corporation<br />Sector: Industrials","Stock: SCHW<br />Company: Charles Schwab Corporation<br />Sector: Financials","Stock: SIVB<br />Company: SVB Financial Group<br />Sector: Financials","Stock: SPG<br />Company: Simon Property Group Inc.<br />Sector: Real Estate","Stock: STT<br />Company: State Street Corporation<br />Sector: Financials","Stock: SYF<br />Company: Synchrony Financial<br />Sector: Financials","Stock: SYY<br />Company: Sysco Corporation<br />Sector: Consumer Staples","Stock: TDG<br />Company: TransDigm Group Incorporated<br />Sector: Industrials","Stock: TFC<br />Company: Truist Financial Corporation<br />Sector: Financials","Stock: TPR<br />Company: Tapestry Inc.<br />Sector: Consumer Discretionary","Stock: TXT<br />Company: Textron Inc.<br />Sector: Industrials","Stock: UA<br />Company: Under Armour Inc. Class C<br />Sector: Consumer Discretionary","Stock: UAA<br />Company: Under Armour Inc. Class A<br />Sector: Consumer Discretionary","Stock: UHS<br />Company: Universal Health Services Inc. Class B<br />Sector: Health Care","Stock: ULTA<br />Company: Ulta Beauty Inc<br />Sector: Consumer Discretionary","Stock: URI<br />Company: United Rentals Inc.<br />Sector: Industrials","Stock: USB<br />Company: U.S. Bancorp<br />Sector: Financials","Stock: VFC<br />Company: V.F. Corporation<br />Sector: Consumer Discretionary","Stock: VIAC<br />Company: ViacomCBS Inc. Class B<br />Sector: Communication Services","Stock: VLO<br />Company: Valero Energy Corporation<br />Sector: Energy","Stock: VNO<br />Company: Vornado Realty Trust<br />Sector: Real Estate","Stock: VTR<br />Company: Ventas Inc.<br />Sector: Real Estate","Stock: WAB<br />Company: Westinghouse Air Brake Technologies Corporation<br />Sector: Industrials","Stock: WDC<br />Company: Western Digital Corporation<br />Sector: Information Technology","Stock: WELL<br />Company: Welltower Inc.<br />Sector: Real Estate","Stock: WFC<br />Company: Wells Fargo & Company<br />Sector: Financials","Stock: WMB<br />Company: Williams Companies Inc.<br />Sector: Energy","Stock: WRK<br />Company: WestRock Company<br />Sector: Materials","Stock: WY<br />Company: Weyerhaeuser Company<br />Sector: Real Estate","Stock: XOM<br />Company: Exxon Mobil Corporation<br />Sector: Energy","Stock: ZION<br />Company: Zions Bancorporation N.A.<br />Sector: Financials"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(204,190,147,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(204,190,147,1)"}},"hoveron":"points","name":"4","legendgroup":"4","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[-3.14329064324455,-3.0602385884152,-3.77781723146743,-3.08867068931046,-1.46575683466955,-3.91302041606431,-3.31274635432149,-2.93143790863769,-1.17321823784512,-3.24374099279441,-3.67433599099527,-2.77877835609713,-3.24584915969293,-1.45603282299125,-1.84604346652018,-3.13650133088686,-1.99574552179741,-2.32229534052633,-3.6265098528306,-2.71892393864236,-3.07278988601601,-3.26563875937616,-2.05063556153092,-3.02772484759963,-3.17866575965445,-1.6679242074647,-2.30406921026745,-1.92590464812822,-3.27320724919662,-3.03863445408544,-3.37012920056531,-1.82424748009928,-2.91858629760175,-3.85107078649819,-3.88292027806963,-3.88859133779866,-3.77061069661415,-2.06370019598852,-3.14900337110891,-2.63622183696145,-3.98263599323239,-2.93482557886859,-2.97297522230987,-3.29473688934022,-4.00093350013302,-2.62043995647438,-1.75876679102913,-2.72484028281583,-3.11880811716702,-3.57986882565368,-3.84202582155801,-3.15931188241755,-3.78745701443988,-1.90637934878458,-3.829094080944,-3.43704955689283,-2.07986702112567,-3.13121047310099,-3.51518831273436,-3.53147322115076,-1.51534221642894],"y":[-1.98256169155306,-1.93136355137101,-1.00853355591969,-1.67075840566887,0.26670111190649,-0.87246576638273,-1.55204214721547,-2.21315893011547,-0.88289402382507,-1.66917722239597,-1.07724264745563,-1.52959601169243,-1.72452087675884,-0.504227681733222,-1.41910570977012,-1.95870035415277,-1.32260171584466,-1.75408221431269,-0.939564986337664,-1.80586153612416,-2.13790267185468,-1.68709595575002,-0.711986541772309,-2.13800579504546,-2.01655430449042,-1.84282926128461,-1.83593579776534,-1.94718171699225,-1.36094124621431,-1.73123703646207,-1.12254165484358,0.314648247290959,-1.16553942542256,-0.879869203653468,-0.718627149780156,-0.853747181329452,-1.12926445430368,-1.48221685401944,-1.67662688739449,-1.57806460982318,-0.730101525458785,-2.21719076673107,-1.91025410512099,-1.69589911097865,-0.675955637292103,-1.28095824568205,-1.9954306681664,-1.57270049268422,-1.70744530950821,-1.17842717823699,-0.857338019711956,-1.62282823114634,-0.945020631663636,-2.11406006090491,-0.876121590229238,-1.75863017328404,-2.67373418100309,-2.09612281168376,-1.1595278380856,-1.28624946240448,-0.487089654535608],"text":["Stock: AAPL<br />Company: Apple Inc.<br />Sector: Information Technology","Stock: ADBE<br />Company: Adobe Inc.<br />Sector: Information Technology","Stock: ADI<br />Company: Analog Devices Inc.<br />Sector: Information Technology","Stock: ADSK<br />Company: Autodesk Inc.<br />Sector: Information Technology","Stock: ALGN<br />Company: Align Technology Inc.<br />Sector: Health Care","Stock: AMAT<br />Company: Applied Materials Inc.<br />Sector: Information Technology","Stock: AMD<br />Company: Advanced Micro Devices Inc.<br />Sector: Information Technology","Stock: AMZN<br />Company: Amazon.com Inc.<br />Sector: Consumer Discretionary","Stock: ANET<br />Company: Arista Networks Inc.<br />Sector: Information Technology","Stock: ANSS<br />Company: ANSYS Inc.<br />Sector: Information Technology","Stock: AVGO<br />Company: Broadcom Inc.<br />Sector: Information Technology","Stock: CDAY<br />Company: Ceridian HCM Holding Inc.<br />Sector: Information Technology","Stock: CDNS<br />Company: Cadence Design Systems Inc.<br />Sector: Information Technology","Stock: CMG<br />Company: Chipotle Mexican Grill Inc.<br />Sector: Consumer Discretionary","Stock: CRL<br />Company: Charles River Laboratories International Inc.<br />Sector: Health Care","Stock: CRM<br />Company: salesforce.com inc.<br />Sector: Information Technology","Stock: CTLT<br />Company: Catalent Inc<br />Sector: Health Care","Stock: DXCM<br />Company: DexCom Inc.<br />Sector: Health Care","Stock: ENPH<br />Company: Enphase Energy Inc.<br />Sector: Information Technology","Stock: ETSY<br />Company: Etsy Inc.<br />Sector: Consumer Discretionary","Stock: FB<br />Company: Meta Platforms Inc. Class A<br />Sector: Communication Services","Stock: FTNT<br />Company: Fortinet Inc.<br />Sector: Information Technology","Stock: GNRC<br />Company: Generac Holdings Inc.<br />Sector: Industrials","Stock: GOOG<br />Company: Alphabet Inc. Class C<br />Sector: Communication Services","Stock: GOOGL<br />Company: Alphabet Inc. Class A<br />Sector: Communication Services","Stock: HOLX<br />Company: Hologic Inc.<br />Sector: Health Care","Stock: IDXX<br />Company: IDEXX Laboratories Inc.<br />Sector: Health Care","Stock: ILMN<br />Company: Illumina Inc.<br />Sector: Health Care","Stock: INTC<br />Company: Intel Corporation<br />Sector: Information Technology","Stock: INTU<br />Company: Intuit Inc.<br />Sector: Information Technology","Stock: IPGP<br />Company: IPG Photonics Corporation<br />Sector: Information Technology","Stock: ISRG<br />Company: Intuitive Surgical Inc.<br />Sector: Health Care","Stock: KEYS<br />Company: Keysight Technologies Inc<br />Sector: Information Technology","Stock: KLAC<br />Company: KLA Corporation<br />Sector: Information Technology","Stock: LRCX<br />Company: Lam Research Corporation<br />Sector: Information Technology","Stock: MCHP<br />Company: Microchip Technology Incorporated<br />Sector: Information Technology","Stock: MPWR<br />Company: Monolithic Power Systems Inc.<br />Sector: Information Technology","Stock: MSCI<br />Company: MSCI Inc. Class A<br />Sector: Financials","Stock: MSFT<br />Company: Microsoft Corporation<br />Sector: Information Technology","Stock: MTCH<br />Company: Match Group Inc.<br />Sector: Communication Services","Stock: MU<br />Company: Micron Technology Inc.<br />Sector: Information Technology","Stock: NFLX<br />Company: Netflix Inc.<br />Sector: Communication Services","Stock: NOW<br />Company: ServiceNow Inc.<br />Sector: Information Technology","Stock: NVDA<br />Company: NVIDIA Corporation<br />Sector: Information Technology","Stock: NXPI<br />Company: NXP Semiconductors NV<br />Sector: Information Technology","Stock: PAYC<br />Company: Paycom Software Inc.<br />Sector: Information Technology","Stock: PKI<br />Company: PerkinElmer Inc.<br />Sector: Health Care","Stock: PTC<br />Company: PTC Inc.<br />Sector: Information Technology","Stock: PYPL<br />Company: PayPal Holdings Inc.<br />Sector: Information Technology","Stock: QCOM<br />Company: Qualcomm Inc<br />Sector: Information Technology","Stock: QRVO<br />Company: Qorvo Inc.<br />Sector: Information Technology","Stock: SNPS<br />Company: Synopsys Inc.<br />Sector: Information Technology","Stock: SWKS<br />Company: Skyworks Solutions Inc.<br />Sector: Information Technology","Stock: TECH<br />Company: Bio-Techne Corporation<br />Sector: Health Care","Stock: TER<br />Company: Teradyne Inc.<br />Sector: Information Technology","Stock: TSLA<br />Company: Tesla Inc<br />Sector: Consumer Discretionary","Stock: TTWO<br />Company: Take-Two Interactive Software Inc.<br />Sector: Communication Services","Stock: TWTR<br />Company: Twitter Inc.<br />Sector: Communication Services","Stock: TXN<br />Company: Texas Instruments Incorporated<br />Sector: Information Technology","Stock: XLNX<br />Company: Xilinx Inc.<br />Sector: Information Technology","Stock: ZBRA<br />Company: Zebra Technologies Corporation Class A<br />Sector: Information Technology"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(166,206,227,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(166,206,227,1)"}},"hoveron":"points","name":"5","legendgroup":"5","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[2.34062590549714,2.44986627724739,2.61555274554894,2.30675735916839,2.49447810622054,2.25786896513966,2.62353880530662,2.18519955764814,2.6728953785675,2.64441930912357,2.26948603681245],"y":[2.4945851267982,2.43013670243157,2.35814889140661,2.1205183534421,2.40655141375465,2.08502531711463,2.43634239747041,1.96959751667744,2.31133373242409,2.33357698448349,2.02820738218332],"text":["Stock: AAL<br />Company: American Airlines Group Inc.<br />Sector: Industrials","Stock: ALK<br />Company: Alaska Air Group Inc.<br />Sector: Industrials","Stock: CCL<br />Company: Carnival Corporation<br />Sector: Consumer Discretionary","Stock: CZR<br />Company: Caesars Entertainment Inc<br />Sector: Consumer Discretionary","Stock: DAL<br />Company: Delta Air Lines Inc.<br />Sector: Industrials","Stock: MGM<br />Company: MGM Resorts International<br />Sector: Consumer Discretionary","Stock: NCLH<br />Company: Norwegian Cruise Line Holdings Ltd.<br />Sector: Consumer Discretionary","Stock: PENN<br />Company: Penn National Gaming Inc.<br />Sector: Consumer Discretionary","Stock: RCL<br />Company: Royal Caribbean Group<br />Sector: Consumer Discretionary","Stock: UAL<br />Company: United Airlines Holdings Inc.<br />Sector: Industrials","Stock: WYNN<br />Company: Wynn Resorts Limited<br />Sector: Consumer Discretionary"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(31,120,180,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(31,120,180,1)"}},"hoveron":"points","name":"6","legendgroup":"6","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":40.1826484018265,"l":48.9497716894977},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(44,62,80,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-4.36811042141054,3.70978184669485],"tickmode":"array","ticktext":["-4","-2","0","2"],"tickvals":[-4,-2,0,2],"categoryorder":"array","categoryarray":["-4","-2","0","2"],"nticks":null,"ticks":"outside","tickcolor":"rgba(204,204,204,1)","ticklen":3.65296803652968,"tickwidth":0.22139200221392,"showticklabels":true,"tickfont":{"color":"rgba(44,62,80,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(204,204,204,1)","gridwidth":0.22139200221392,"zeroline":false,"anchor":"y","title":{"text":"x","font":{"color":"rgba(44,62,80,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-4.1425014229866,5.02410675986335],"tickmode":"array","ticktext":["-2.5","0.0","2.5","5.0"],"tickvals":[-2.5,0,2.5,5],"categoryorder":"array","categoryarray":["-2.5","0.0","2.5","5.0"],"nticks":null,"ticks":"outside","tickcolor":"rgba(204,204,204,1)","ticklen":3.65296803652968,"tickwidth":0.22139200221392,"showticklabels":true,"tickfont":{"color":"rgba(44,62,80,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(204,204,204,1)","gridwidth":0.22139200221392,"zeroline":false,"anchor":"x","title":{"text":"y","font":{"color":"rgba(44,62,80,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(44,62,80,1)","width":0.33208800332088,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(44,62,80,1)","family":"","size":11.689497716895},"y":0.913385826771654},"annotations":[{"text":".cluster","x":1.02,"y":1,"showarrow":false,"ax":0,"ay":0,"font":{"color":"rgba(44,62,80,1)","family":"","size":14.6118721461187},"xref":"paper","yref":"paper","textangle":-0,"xanchor":"left","yanchor":"bottom","legendTitle":true}],"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"17ec22bb71d0b":{"x":{},"y":{},"colour":{},"text":{},"type":"scatter"}},"cur_data":"17ec22bb71d0b","visdat":{"17ec22bb71d0b":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>

\`\`\`
