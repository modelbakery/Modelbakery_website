

```{r}

```




Multicollinearity suspect: High entanglment in multiple dimension (variable removal candidate)

indus variable is the most problematic 

```{r}
summary_relationship_tbl %>% 
  filter(str_detect(label, pattern = "indus"))

summary_relationship_tbl %>% 
  filter(str_detect(label, pattern = "age"))

summary_relationship_tbl %>% 
  filter(str_detect(label, pattern = "nox"))
```

The regsubsets() function (part of the leaps library) performs best subset selection by identifying the best model that contains a given number of predictors, where best is quantified using RSS. The syntax is the same as for lm(). The summary() command outputs the best set of variables for each model size.

An asterisk ("*") indicates that a given variable is included in the corresponding model. For instance, this output indicates that the best two-variable model contains only Hits and CRBI. By default, regsubsets() only reports results up to the best eight-variable model. But the nvmax option can be used in order to return as many variables as are desired. Here we fit up to a 19-variable model:
  
  ```{r}
lm_fit_00edit <- lm(medv~., data = Boston); summary(lm_fit_00edit)

summary(lm_fit_00edit)[1:10]
summary(lm_fit_00edit)$r.squared # 0.7406427
summary(lm_fit_00edit)$adj.r.squared # 0.7337897
summary(lm_fit_00edit)$fstatistic # 108.0767

lm_fit_01edit <- lm(formula = medv ~ crim + zn + chas + nox + rm + dis + rad + tax + ptratio + black + lstat +indus, data = Boston); summary(lm_fit_01edit)
# Multiple R-squared:  0.7406,	Adjusted R-squared:  0.7348 
# F-statistic: 128.2 on 11 and 494 DF,  p-value: < 2.2e-16

vif(lm_fit_01edit) %>% 
  as_tibble() %>% 
  bind_cols(names(vif(lm_fit_01edit))) %>% 
  setNames(c("vif", "var_name")) %>% 
  arrange(desc(vif))
```
http://www.science.smith.edu/~jcrouser/SDS293/labs/lab8-r.html




```{r}
generator_univar_importance_tbl(Boston, "medv")

```

```{r}
summary_relationship_tbl %>% 
  filter(str_detect(label, pattern = "rad"))

regsubfit <- regsubsets(medv~.-tax,
                        data= Boston, 
                        intercept = T,
                        method = c("exhaustive", "backward", "forward", "seqrep"),
                        nvmax = 19)
reg_summary <- summary(regsubfit)


par(mfrow = c(2,2))
plot(reg_summary$rss, xlab = "Number of Variables", ylab = "RSS", type = "l")
plot(reg_summary$adjr2, xlab = "Number of Variables", ylab = "Adjusted RSq", type = "l")
```


```{r}
outlier_treatment <- function(x, na.rm = T) {
  x[x > quantile(x,.95,na.rm = na.rm)]<- quantile(x, .95,na.rm = na.rm)
  x[x < quantile(x,.05,na.rm = na.rm)]<- quantile(x, .05,na.rm = na.rm)
}
```

```{r}

lm_fit_dir <- lm(medv~rm + age, data = Boston); summary(lm_fit_dir)
plot(lm_fit_dir)
boxplot(Boston$medv)
boxplot(Boston$rm)
boxplot(Boston$age)

Boston %>% 
  mutate(rm_outlierT = rm %>% outlier_treatment()) %>% 
  ggplot(aes(medv, rm)) +
  geom_point()

Boston_medv_max <- Boston %>% filter(medv >= 50)
bind_rows(sapply(Boston_medv_max, mean), sapply(Boston, mean))
# lstat, chas
```

```{r}

```

