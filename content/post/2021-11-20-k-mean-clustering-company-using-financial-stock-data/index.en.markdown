---
title: K-Mean Clustering Company using Financial Stock Data
author: Package Build
date: '2021-11-20'
slug: K-Mean Clustering Company using Financial Stock Data
categories:
  - R
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



# Purpose: 

B2B sales organisation wants to know which companies are similar to each other to help in identifying potential customers in various segments of the market. There are many techniques for market research but in here we will try to penetrate various market segments using companies stock price data. 

When it comes to market research or investment, looking at the returns of dozens of companies will be a tricky analysis to draw various insights. The cluster analysis process of dividing a common set of companies into groups (by range and scope) provides a more holistic perspective on the internal and external relationship of the relevant companies. Since stocks have a tendency to fluctuate together, grouping by the similarity in return trend seems an applicable clustering recipe in practice. 

# Reference:

The code workflow here is been devloped from University of Business Science 101 course & UC Business analytics R programming guide. 


# Agenda: 

#### [1] Pull Stock Price Data from Yahoo Finance using getSymbols  

#### [2] Data Preparation: Preparing data for clustering (User-Item or User-date format) + Normalisation 

#### [3] Determine Optimal Clusters: Identify the optimal number of clusters from various statistical approaches 

#### [4] Visualisation aid by UMAP: 2-Dimensional feature reduction + plotly 



$$ 
return_{daily} = \frac{price_{i}-price_{i-1}}{price_{i-1}}
$$

# The Concept of Clustering 

The task of clustering analysis is to divide the set of objects into homogeneous groups. The ideal grouping is where the arbitrary objects belonging to the same group are more similar to each other than arbitrary objects belonging different groups. 

There are two questions we must find before applying cluster analysis$^1$:

* How to define the similarity between the object - the distance metric that we use to identify the common traits carries some kind of semantic meaning of similarity?

* In what manner should one make use of the thus defined similarity in the process of grouping - does clustering provide any new insight into the data? 

### Why Would One Undergo Cluster Analysis 

One may have collected large data set at different experimental sites and resources. Data may stem from subjects related to one and another, and there are further possibilities of hidden variables, e.g. macro external influence or special events,  which in a way could expand the variance and much uninterpretable noise in the data. If one is unaware of such a hierarchical relationship or is absent in this domain of knowledge, it is advised to apply a clustering method prior to further analysis. 

For an example of its interesting application, cluster analysis on both the customers and their typical and the atypical product items helps to uncover hidden needs of the customer database and verify the hypotheses concerning these common user-item relationships: play an important role in the development of the recommendation system. 


# Methods for measuring distances 

The choice of distance matrix is a critical step in cluster. It determines how the similarity of two elements (x, y) is calculated and it will directly influence the shape of the cluster. 

#### Euclidean Distance: 

* Most commonly used and often a default setting in many distance matrix algorithm in R

$$
d_{euc}(x, y) = \sqrt{\sum_{i=1}^n(x_i-y_i)^2}
$$

#### Manhattan Distance: 

$$
d_{man}(x, y) = \sum_{i=1}^n|(x_i-y_i)|
$$

#### Correlation-based distance: 

* Pearson correlation: Measures the degree of a linear relationship between two profiles. It is a paramteric correlation which depends on the distribution of the data. 

* Kendall & Spearman correlation correlation are non-parametric and they are used to perform rank-based correlation analysis. (Outlier sensitivity can be mitigated by using Spearman's correlation instead of Pearson's correlation)

* Considers two objects to be similar if their features are highly correlated, even though the observed values may be far apart in terms of Euclidean distance. 

* Correlation-based distance often preferred over two above matrix in case for dealing with high dimensional data set, due to curse of dimensionality. 

#### What type of distance measure should we choose?

Despite the choice of distance measure has a strong influence on the clustering result, it is often arbitrary. 

But we must note that two things. 

[1] If we want to identify clusters of observations with the samll overall profiles regardless of their magnitudes, we shuld go with __correlation-based distance__ as a dissimilarity measure. In marketing, we can imagine a case where organisation like to identify group of shoppers with the same preference in terms of items, regardless of the volume of items they bought. 

[2] If Euclidean distance is chosen, then observations with high values of features will be clustered together. The same holds true for observations with low values of features. 

 

```r
library(tidyverse)
library(tidyquant)
library(quantmod)
library(broom)
library(umap)
library(plotly)
library(factoextra)
library(cluster)
```



```r
SP500_prices_tbl <- read_rds("/Users/seunghyunsung/Documents/GitHub/Modelbakery_backup/post3/sp500stock/sp_500_prices_tbl_2019.11_2021.11.rds")

SP500_index_tbl <- read_rds("/Users/seunghyunsung/Documents/GitHub/Modelbakery_backup/post3/sp500stock/SP500_index_list_tbl.rds")
```


```r
SP500_daily_returns_tbl <- SP500_prices_tbl %>% 
    select(symbol, date, adjusted) %>% 
    group_by(symbol) %>% 
    mutate(lag = lag(adjusted, order_by = date, n = 1)) %>% 
    filter(!is.na(lag)) %>% 
    mutate(diff = adjusted - lag) %>% 
    mutate(pct_return = diff/lag)  %>% ungroup() %>% 
    select(symbol, date, pct_return) 
```


## Convert to User-Item Format


```r
SP500_date_matrix_tbl <- SP500_daily_returns_tbl %>% 
  spread(date, pct_return, fill = 0)
```



```r
kmeans_obj <- SP500_date_matrix_tbl %>% 
    select(-symbol) %>% 
    kmeans(centers = 4, nstart = 20)

kmeans_obj %>% broom::glance()
```

```
## # A tibble: 1 × 4
##   totss tot.withinss betweenss  iter
##   <dbl>        <dbl>     <dbl> <int>
## 1  113.         88.2      24.7     3
```


## Step 4 - Find the optimal value of K


```r
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


```r
k_means_mapped_tbl %>% 
  unnest(glance) %>% 
  ggplot(aes(x = centers, y = tot.withinss)) +
  geom_point(colour = palette_light()[1], size = 3) +
  geom_line(colour = palette_light()[1], size = 1) +
  ggrepel::geom_label_repel(aes(label = centers, alpha = 3), colour = palette_light()[1]) +
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

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-7-1.png" width="672" />


```r
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

k_means_silhouette_mapped_tbl[-1,] %>% 
  ggplot(aes(centers, k_means)) +
  geom_point(colour = palette_light()[1], size = 3) +
  geom_line(colour = palette_light()[1], size = 1) +
  ggrepel::geom_label_repel(aes(label = centers, alpha = 3), colour = palette_light()[1]) +
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

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-8-1.png" width="672" />


```r
fviz_nbclust(SP500_date_matrix_tbl %>% select(-symbol), kmeans, method = "silhouette")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-9-1.png" width="672" />



```r
library(cluster)
library(factoextra)

fviz_nbclust(SP500_date_matrix_tbl %>% select(-symbol), kmeans, method = "wss",k.max = 20)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-10-1.png" width="672" />

```r
?fviz_nbclust
```



```r
# set.seed(42)
# gap_stat <- clusGap(SP500_date_matrix_tbl %>% select(-symbol),
#                     FUN = kmeans,
#                     nstart = 25,
#                     K.max = 10,
#                     B = 50)
```







