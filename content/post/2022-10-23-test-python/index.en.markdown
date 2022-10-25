---
title: Using python + R with Reticulate
author: Seung Hyun Sung
date: '2022-10-23'
slug: python
categories:
  - python
tags:
  - test
subtitle: ''
summary: ''
authors: []
lastmod: '2022-10-23T14:43:21+09:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

#### Purpose

The most popular data science languages are Python and R. Data scientists that learn to use the strengths of both languages are becoming credentials. Understanding the strengths and weaknesses of these languages and by shaping our data science workflow will make us work productively.

-   **EDA**, **Visualisation**, **Apps & Reporting**: Switch to R to use tidyverse, shiny and rmarkdown
-   **Machine Learning**: Switch to Python to leverage scikit learn and tensorflow

#### Reticulate Setup

The **reticulate** package lets you use Python and R together seamlessly in R code, in R Markdown documents, and in the RStudio IDE, and thus with HUGO blogdown here to upload on the webpage.

``` r
library(tidyverse)
library(reticulate)
```

The `use_condaenv` function expects an environment name, not the path to the python executable.
이 곳으로 파이썬 환경을 설정한다.

``` r
miniconda_path()
```

    ## [1] "C:/Users/sung9/AppData/Local/r-miniconda"

``` r
# reticulate::conda_create()
reticulate::use_condaenv("r-reticulate", required = TRUE)
py_config()
```

    ## python:         C:/Users/sung9/AppData/Local/r-miniconda/envs/r-reticulate/python.exe
    ## libpython:      C:/Users/sung9/AppData/Local/r-miniconda/envs/r-reticulate/python38.dll
    ## pythonhome:     C:/Users/sung9/AppData/Local/r-miniconda/envs/r-reticulate
    ## version:        3.8.13 | packaged by conda-forge | (default, Mar 25 2022, 05:59:00) [MSC v.1929 64 bit (AMD64)]
    ## Architecture:   64bit
    ## numpy:          C:/Users/sung9/AppData/Local/r-miniconda/envs/r-reticulate/Lib/site-packages/numpy
    ## numpy_version:  1.23.4
    ## 
    ## NOTE: Python version was forced by use_python function

#### Conda Installation

``` python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
```

``` python
df=pd.DataFrame([[1, 2], [3, 4], [4, 3], [2, 3]])
fig = plt.figure(figsize=(14,8))
for i in df.columns:
    ax=plt.subplot(2,1,i+1)
    df[[i]].plot(ax=ax)
    print(i)

plt.show()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-4-1.png" width="1344" />

``` python
from sklearn.ensemble import RandomForestClassifier
clf = RandomForestClassifier(random_state=0)

X = [[ 1,  2,  3],  # 2 samples, 3 features
     [11, 12, 13]]

y = [0, 1]  # classes of each sample

clf.fit(X, y)
```

<style>#sk-container-id-1 {color: black;background-color: white;}#sk-container-id-1 pre{padding: 0;}#sk-container-id-1 div.sk-toggleable {background-color: white;}#sk-container-id-1 label.sk-toggleable__label {cursor: pointer;display: block;width: 100%;margin-bottom: 0;padding: 0.3em;box-sizing: border-box;text-align: center;}#sk-container-id-1 label.sk-toggleable__label-arrow:before {content: "▸";float: left;margin-right: 0.25em;color: #696969;}#sk-container-id-1 label.sk-toggleable__label-arrow:hover:before {color: black;}#sk-container-id-1 div.sk-estimator:hover label.sk-toggleable__label-arrow:before {color: black;}#sk-container-id-1 div.sk-toggleable__content {max-height: 0;max-width: 0;overflow: hidden;text-align: left;background-color: #f0f8ff;}#sk-container-id-1 div.sk-toggleable__content pre {margin: 0.2em;color: black;border-radius: 0.25em;background-color: #f0f8ff;}#sk-container-id-1 input.sk-toggleable__control:checked~div.sk-toggleable__content {max-height: 200px;max-width: 100%;overflow: auto;}#sk-container-id-1 input.sk-toggleable__control:checked~label.sk-toggleable__label-arrow:before {content: "▾";}#sk-container-id-1 div.sk-estimator input.sk-toggleable__control:checked~label.sk-toggleable__label {background-color: #d4ebff;}#sk-container-id-1 div.sk-label input.sk-toggleable__control:checked~label.sk-toggleable__label {background-color: #d4ebff;}#sk-container-id-1 input.sk-hidden--visually {border: 0;clip: rect(1px 1px 1px 1px);clip: rect(1px, 1px, 1px, 1px);height: 1px;margin: -1px;overflow: hidden;padding: 0;position: absolute;width: 1px;}#sk-container-id-1 div.sk-estimator {font-family: monospace;background-color: #f0f8ff;border: 1px dotted black;border-radius: 0.25em;box-sizing: border-box;margin-bottom: 0.5em;}#sk-container-id-1 div.sk-estimator:hover {background-color: #d4ebff;}#sk-container-id-1 div.sk-parallel-item::after {content: "";width: 100%;border-bottom: 1px solid gray;flex-grow: 1;}#sk-container-id-1 div.sk-label:hover label.sk-toggleable__label {background-color: #d4ebff;}#sk-container-id-1 div.sk-serial::before {content: "";position: absolute;border-left: 1px solid gray;box-sizing: border-box;top: 0;bottom: 0;left: 50%;z-index: 0;}#sk-container-id-1 div.sk-serial {display: flex;flex-direction: column;align-items: center;background-color: white;padding-right: 0.2em;padding-left: 0.2em;position: relative;}#sk-container-id-1 div.sk-item {position: relative;z-index: 1;}#sk-container-id-1 div.sk-parallel {display: flex;align-items: stretch;justify-content: center;background-color: white;position: relative;}#sk-container-id-1 div.sk-item::before, #sk-container-id-1 div.sk-parallel-item::before {content: "";position: absolute;border-left: 1px solid gray;box-sizing: border-box;top: 0;bottom: 0;left: 50%;z-index: -1;}#sk-container-id-1 div.sk-parallel-item {display: flex;flex-direction: column;z-index: 1;position: relative;background-color: white;}#sk-container-id-1 div.sk-parallel-item:first-child::after {align-self: flex-end;width: 50%;}#sk-container-id-1 div.sk-parallel-item:last-child::after {align-self: flex-start;width: 50%;}#sk-container-id-1 div.sk-parallel-item:only-child::after {width: 0;}#sk-container-id-1 div.sk-dashed-wrapped {border: 1px dashed gray;margin: 0 0.4em 0.5em 0.4em;box-sizing: border-box;padding-bottom: 0.4em;background-color: white;}#sk-container-id-1 div.sk-label label {font-family: monospace;font-weight: bold;display: inline-block;line-height: 1.2em;}#sk-container-id-1 div.sk-label-container {text-align: center;}#sk-container-id-1 div.sk-container {/* jupyter's `normalize.less` sets `[hidden] { display: none; }` but bootstrap.min.css set `[hidden] { display: none !important; }` so we also need the `!important` here to be able to override the default hidden behavior on the sphinx rendered scikit-learn.org. See: https://github.com/scikit-learn/scikit-learn/issues/21755 */display: inline-block !important;position: relative;}#sk-container-id-1 div.sk-text-repr-fallback {display: none;}</style><div id="sk-container-id-1" class="sk-top-container"><div class="sk-text-repr-fallback"><pre>RandomForestClassifier(random_state=0)</pre><b>In a Jupyter environment, please rerun this cell to show the HTML representation or trust the notebook. <br />On GitHub, the HTML representation is unable to render, please try loading this page with nbviewer.org.</b></div><div class="sk-container" hidden><div class="sk-item"><div class="sk-estimator sk-toggleable"><input class="sk-toggleable__control sk-hidden--visually" id="sk-estimator-id-1" type="checkbox" checked><label for="sk-estimator-id-1" class="sk-toggleable__label sk-toggleable__label-arrow">RandomForestClassifier</label><div class="sk-toggleable__content"><pre>RandomForestClassifier(random_state=0)</pre></div></div></div></div></div>

``` python
clf.predict(X)
```

    ## array([0, 1])

``` python
from sklearn.cluster import AffinityPropagation
from sklearn.datasets import make_blobs

# #############################################################################
# Generate sample data
centers = [[1, 1], [-1, -1], [1, -1]]
X, labels_true = make_blobs(n_samples=300, centers=centers, cluster_std=0.5,
                            random_state=0)

# Compute Affinity Propagation
af = AffinityPropagation(preference=-50).fit(X)
cluster_centers_indices = af.cluster_centers_indices_
labels = af.labels_

n_clusters_ = len(cluster_centers_indices)

# #############################################################################
# Plot result
import matplotlib.pyplot as plt
from itertools import cycle

plt.close('all')
plt.figure(1)
plt.clf()

colors = cycle('bgrcmykbgrcmykbgrcmykbgrcmyk')
for k, col in zip(range(n_clusters_), colors):
    class_members = labels == k
    cluster_center = X[cluster_centers_indices[k]]
    plt.plot(X[class_members, 0], X[class_members, 1], col + '.')
    plt.plot(cluster_center[0], cluster_center[1], 'o', markerfacecolor=col,
             markeredgecolor='k', markersize=14)
    for x in X[class_members]:
        plt.plot([cluster_center[0], x[0]], [cluster_center[1], x[1]], col)

plt.title('Estimated number of clusters: %d' % n_clusters_)
plt.show()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-7-3.png" width="672" />
