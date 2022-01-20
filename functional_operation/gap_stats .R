```{r}
set.seed(42)
gap_stat <- clusGap(SP500_date_matrix_tbl %>% select(-symbol),
                    FUN = kmeans,
                    nstart = 25,
                    K.max = 10,
                    B = 50)

fviz_gap_stat(gap_stat)
```