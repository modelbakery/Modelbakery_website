---
title: "What is statistical learning - Part 1"
subtitle: "The concept of IID in Statistical Learning"
author: "Package Build"
date: '2021-11-20'
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



# Purpose: 

Statistical learning assumes the presence of a relationship between response `\(Y\)` and (p-dimensional) predictors $X = (X_1,\ X_2,...,\ X_p)  $, under the assumption that these variables are Random Variables; its general form is as below: 

# Objective

[GDP 총 생산량과 콜금리의 관계]

The plot suggests that one might be able to predict GDP using call-interest rates. However, the function `\(f\)` which connects the output variables from the input variables is in general unknown. In short, the conditioned distribution of `\(Y\)`  given `\(X\)`, the blueprint, is unknown; consequently, statistical learning refers to a set of approaches for estimating `\(f\)`: ***prediction and inference***. 

As data scientists, our prime goal is to achieve `\(\hat{f}\)` which yields accurate predictions for `\(Y\)` but  `\(\hat{f}\)` is often treated as a black box, in essence, depending on the modelling purposes and research areas the level of interpretability can be more or less important than its accuracy.  

---

# How? - the i.i.d Rule

In statistics, the idea is that some variables are independent and identically distributed (identical probability density function) in theory. In practice, we see random-looking variables and some much closer than others to i.i.d. 

- Independent: variables are statistically independent of one another hence no correlation
- identically distributed: identical probability density function meaning that the variable’s variance is the same.

We assume the i.i.d rule and validate it by the randomness of the epsilon, hence it is important the residue between observed data `\(Y\)` and modelled data `\(\hat{Y}\)` is not far from being independent of `\(X\)`  and has a mean 0 (i.i.d). For the raw residues, the modellers should apply weights (parameter adjustment) and filters (regularisation) to get i.i.d residues. (Perhaps, applying the grid search)   

**The challenge of the ML modelling usually sits here, that is minimizing sums of squares of residuals as well as CHECKING whether the residue does follow the i.i.d rule.**  

In this setting, since the error term averages to zero, we can predict `\(Y\)`using 

$$
\hat{Y} = \hat{f}(X)
$$

---

# Predictions

The accuracy of the model `\(\hat{Y}\)` as a prediction of `\(Y\)`depends on two quantities

- Reducible error
- Irreducible error

What these errors suggest is that no matter how well we estimate `\(f\)` with the perfect estimate `\(\hat{Y} = f(X)\)`, we cannot reduce the error introduced by  `\(\epsilon\)` 

Why? - the `\(\epsilon\)` may contain unmeasured variables that are useful in predicting the `\(Y\)` and also may also be from unmeasurable variation etc special events. 

Expected value + Variance 

The irreducible error will always provide an upper bound on the accuracy of our prediction for `\(Y.\)` Where this bound is certainly always unknown in practice.


# Inference

Often analysts are interested in understanding quantitatively how much `\(Y\)` is affected as a function of  `\(X\)`changes. The following questions will advise you on how to come about understanding their relationship. 

- Which predictors are associated with the response? Is it only the fraction of the available predictors or instances are substantially associated with `\(Y\)`
주요 변수 추출 → 차원 축소
- What is the relationship between the response and each predictor?
    - Correlation and Covariance
    - Multi-collinearity due to its complexity of `\(f\)`?
- Can the relationship be adequately summarised linearly, or is the relationship more complicated?
- Are you continuously referring back to the business problem?


